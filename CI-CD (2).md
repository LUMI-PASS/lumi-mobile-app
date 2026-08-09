# Lumi CI/CD & Production Infrastructure (NOT MOBILE)

How code goes from `git push` to running container, where everything lives, and how to
debug it when it breaks.

Server state in this doc was verified against `82.118.227.32` on **2026-08-02**.

---

## 0. Read this first: pushing to `main` does NOT deploy production

Since the backend merge (2026-07-11) all production traffic is served by the
**`merged-backend`** container. The GitHub auto-deploy webhook was never updated — it
still rebuilds the *old* `mobile-backend` / `adminka-backend` / `partner-backend`
containers, which Caddy no longer routes any traffic to.

So a push to `main` produces a green webhook delivery, a successful Docker build, and
**zero change in production**. This has silently bitten several deploys.

**Every production deploy is manual:**

```bash
ssh root@82.118.227.32
cd /opt/lumi/repos/mobile && git pull origin main
cd /opt/lumi && docker compose up -d --build --no-deps merged-backend
```

Details and verification steps in [§3 Deploying](#3-deploying).

---

## 1. Topology

One bare-metal server runs everything in Docker Compose. Since the merge there is **one
NestJS app and one database** — the three former backends are three route trees inside it.

```
                                  Cloudflare DNS
                                        │
                                        ▼
                  ┌──────────────────────────────────────────┐
                  │  82.118.227.32   (Hetzner / "lumi-prod")  │
                  │                                          │
                  │   ┌─── Caddy (TLS) :80 :443 ───────────┐  │
                  │   │                                    │  │
                  │   │  mobile-api.lumipass.uz  ─┐        │  │
                  │   │  app.lumipass.uz         ─┤        │  │
                  │   │  api.adminka.lumipass.uz ─┼─► merged-backend:3000
                  │   │  api.partner.lumipass.uz ─┘        │  │
                  │   │                                    │  │
                  │   │  deploy.lumipass.uz      ─► webhook:9000
                  │   │  db.lumipass.uz          ─► mongo-express:8081
                  │   │  dev-mobile-api…         ─► mobile-backend-dev:3000
                  │   └────────────────────────────────────┘  │
                  │                                           │
                  │  ┌─ MongoDB 7 ──────────────────────────┐ │
                  │  │  lumi_backend  (prod)                │ │
                  │  │  lumi_dev      (dev container)       │ │
                  │  │  bound to 127.0.0.1:27017 only       │ │
                  │  └──────────────────────────────────────┘ │
                  └───────────────────────────────────────────┘
```

### Route namespacing

Caddy rewrites per hostname so **no client had to change** when the backends merged:

| Hostname | Incoming path | Reaches the app as |
|---|---|---|
| `mobile-api.lumipass.uz`, `app.lumipass.uz` | `/api/*` | `/api/*` — **FROZEN**, the shipped Flutter app depends on these paths |
| `api.adminka.lumipass.uz` | `/api/*` | `/api/console/*` |
| `api.partner.lumipass.uz` | `/api/*` | `/api/partner/*` |
| any of the above | `/uploads/*` | `/uploads/*` — never namespaced |

Config: `/opt/lumi/caddy/Caddyfile` (pre-merge copy kept as `Caddyfile.pre-merge.bak`).
The repo's `deploy/Caddyfile` is a reference copy — editing it deploys nothing.

Each tree verifies JWTs with its **own** secret (`JWT_SECRET`, `CONSOLE_JWT_SECRET`,
`PARTNER_JWT_SECRET`). The three original backends had three different secrets and staff
tokens never expire — collapsing them to one secret locks out every staff user.

### Frontends

Netlify, not this server:

| Frontend | Netlify site | Custom domain | Repo |
|---|---|---|---|
| Adminka panel | `adminka-frontend` | `adminka.lumipass.uz` | `LUMI-PASS/lumi-adminka-frontend` |
| Partner panel | `b2b-adminka` | `partner.lumipass.uz` | `LUMI-PASS/lumi-b2b-frontend` |

---

## 2. What's actually running

`docker compose ps` in `/opt/lumi`, 2026-08-02:

| Service | Live? | Notes |
|---|---|---|
| `merged-backend` | **YES** | container `lumi-merged-backend` — serves ALL production traffic |
| `caddy` | yes | TLS + reverse proxy, ports 80/443 |
| `mongo` | yes | mongo:7, bound `127.0.0.1:27017` |
| `mongo-express` | yes | `db.lumipass.uz` |
| `prometheus` | yes | port 9090 |
| `grafana` | yes | port 3001 |
| `webhook` | yes | `deploy.lumipass.uz`, but see §0 — its hooks target dead services |
| `mobile-backend-dev` | yes | `dev-mobile-api.lumipass.uz`, DB `lumi_dev` |
| `partners-bot` | yes | separate Telegram bot service, own repo + own hook |
| `mobile-backend` | **dead weight** | pre-merge container, receives no traffic |
| `adminka-backend` | **dead weight** | pre-merge container, receives no traffic |
| `partner-backend` | **dead weight** | pre-merge container, receives no traffic |

The three dead-weight containers still build and restart — they just aren't routed. They
are the reason a webhook deploy looks successful while prod stays unchanged. Leave them
running or remove them deliberately; don't half-remove them while the hooks still name
them.

**Never run a second instance with the live Telegram bot token.** That is what took the
partner bot offline previously — Telegram drops the older poller. The dev container's
token is forced empty for this reason.

---

## 3. Deploying

### Production backend (the only path that ships code)

```bash
ssh root@82.118.227.32

# 1. Pull the code. NOTE: repos/mobile — that is the build context for merged-backend.
cd /opt/lumi/repos/mobile
git pull origin main

# 2. Rebuild the container that actually serves traffic.
cd /opt/lumi
docker compose up -d --build --no-deps merged-backend
```

Takes ~3–4 min: `npm install` + `nest build` run inside the container.

`--no-deps` is **required**. Without it, compose cascade-recreates `mongo`, and killing
mongo before a journal flush has wiped recent writes.

### Two layout quirks that cost people an hour each

- `merged-backend` **builds from `./repos/mobile`** but takes its **env from
  `./repos/merged/.env`**. Both paths are load-bearing; they are not a typo.
- **`/opt/lumi/repos/merged/` is not a git repo.** It is a leftover rsync from a laptop.
  Editing code there ships nothing. Only `/opt/lumi/repos/mobile` is a real clone
  (`LUMI-PASS/lumi-mobile-backend`, branch `main`).

### Verify the deploy actually landed

```bash
docker compose ps merged-backend                     # expect "Up (n) seconds"
docker compose logs --tail=80 merged-backend         # expect "Nest application successfully started", no 409s
curl -o /dev/null -w "%{http_code}\n" https://mobile-api.lumipass.uz/api/categories
```

Use `/api/categories` for the smoke test. **`/api/activities` is not a route** and 404s
misleadingly — a 404 there means nothing about whether the app is healthy.

For anything non-trivial, run `tools/golden/golden.js` first — it diffs every endpoint
prod-vs-build and has caught real regressions (a `.populate()` that silently changed
behaviour when a mongoose `ref` was added).

### After editing a `.env`

```bash
docker compose up -d --force-recreate merged-backend
```

`docker compose restart` does **not** re-read env files — compose reads `env_file` at
container-create time only.

### Frontends

Netlify's GitHub App is installed on the `LUMI-PASS` org. Push to `main` →
`npm ci && npm run build` (Node 20) → publish `dist/`. This path still works normally.

Env vars live in the **Netlify dashboard**, not `netlify.toml`:

| Site | Dashboard env vars |
|---|---|
| `adminka-frontend` | `VITE_BASE_URL=https://api.adminka.lumipass.uz`, `VITE_MOBILE_BASE_URL=https://mobile-api.lumipass.uz`, `VITE_MOBILE_ADMIN_KEY=…` |
| `b2b-adminka` | `VITE_BASE_URL=https://api.partner.lumipass.uz` |

When you rotate `ADMIN_API_KEY` on the backend you must also update
`VITE_MOBILE_ADMIN_KEY` on `adminka-frontend`, then "Clear cache and deploy site".

### The webhook, for reference

Still wired and still firing — just at the wrong targets.

| Repo | Hook URL | Rebuilds | Routed? |
|---|---|---|---|
| `LUMI-PASS/lumi-mobile-backend` | `…/hooks/deploy-mobile` | `mobile-backend` | no |
| `LUMI-PASS/lumi-adminka-backend` | `…/hooks/deploy-adminka` | `adminka-backend` | no |
| `LUMI-PASS/lumi-b2b-backend` | `…/hooks/deploy-partner` | `partner-backend` | no |
| partners-bot repo | `…/hooks/deploy-partners-bot` | `partners-bot` | **yes** — this one is real |

`/opt/lumi/webhook/deploy.sh` accepts only `mobile|adminka|partner|partners-bot`; there is
no `merged` case. Making push-to-main deploy production again means adding a `merged` case
(repo dir `mobile`, compose service `merged-backend`) plus a matching hook in
`hooks.yaml` and a GitHub webhook. Until someone does that, §0 stands.

The webhook image is custom-built — `thecatlady/webhook:latest` ships without `git` and
`docker-cli`, so deploys fail on the stock image:

```dockerfile
# /opt/lumi/webhook/Dockerfile
FROM thecatlady/webhook:latest
USER root
RUN apk add --no-cache git openssh-client docker-cli docker-cli-compose ca-certificates
```

Tag `lumi-webhook:local`; rebuild with `dc build webhook && dc up -d webhook`. The
container has `/var/run/docker.sock` plus the host's `/root/.git-credentials` and
`/root/.gitconfig` mounted in — don't unmount those.

---

## 4. Status, logs, monitoring

A `dc` alias is set in `~/.bashrc` on the server: `dc = cd /opt/lumi && docker compose`.

```bash
dc ps                                  # everything, with uptime
dc logs -f merged-backend              # live prod logs
dc logs --tail=100 merged-backend
dc logs --tail=50 webhook              # why a hook did / didn't fire
```

Logs are structured JSON (pino) with a per-request `reqId`, also returned in the
`x-request-id` response header — grep by it to trace one request end to end. Level via
`LOG_LEVEL`.

From anywhere, no SSH:

```bash
curl -o /dev/null -w "%{http_code}\n" https://mobile-api.lumipass.uz/api/categories   # 200 = alive
curl -s https://mobile-api.lumipass.uz/metrics | head                                 # Prometheus metrics, public
```

Dashboards (public ports, password-protected):

| | URL | Auth |
|---|---|---|
| Grafana | `http://82.118.227.32:3001` | admin / see creds file |
| Prometheus | `http://82.118.227.32:9090` | basic auth, user `lumi` |

Credentials: `/root/lumi-monitoring-creds.txt` on the server. Grafana auto-provisions the
Prometheus datasource and the "Lumi Mobile Backend" dashboard. Prometheus scrapes
`mobile-backend:3000/metrics` — **note it still points at the pre-merge service name**;
if that container is ever removed, update `/opt/lumi/monitoring/prometheus.yml` to
`merged-backend:3000` or metrics go dark.

Prod configs live in `/opt/lumi/monitoring/` and are hand-written. The repo's
`monitoring/` directory targets `shared-network` + `backend:3000` and is for **local use
only** — see `monitoring/README.md` and `docker-compose.local.yml`.

---

## 5. File layout on the server

```
/opt/lumi/
├── docker-compose.yml              # Single source of truth for all services
├── caddy/
│   ├── Caddyfile                   # Reverse-proxy + auto-TLS + merge rewrites
│   └── Caddyfile.pre-merge.bak
├── monitoring/                     # Prometheus + Grafana configs (PROD versions)
├── repos/
│   ├── mobile/                     # ← THE real clone. Build context for merged-backend.
│   ├── merged/                     # ← NOT a git repo. Only .env here is used.
│   ├── mobile-dev/                 #    dev container's tree
│   ├── partners-bot/               #    still auto-deployed by its own hook
│   ├── adminka/                    #    pre-merge, dead
│   └── partner/                    #    pre-merge, dead
├── repos-frontend/                 # Local clones of frontend repos (debugging only)
├── webhook/
│   ├── Dockerfile                  # lumi-webhook:local
│   ├── hooks.yaml                  # hook definitions + HMAC secrets (chmod-protected)
│   └── deploy.sh                   # The script every hook executes
├── seed-admins.sh                  # Re-seeds owner/admin/moderator staff users
├── backups/                        # *.pre-drop.gz — the dropped pre-merge databases
└── data/                           # Persistent volumes — DO NOT DELETE
    ├── mongo/
    ├── caddy/                      # TLS certs + autosaved Caddy config
    ├── prometheus/                 # chowned 65534
    └── grafana/                    # chowned 472

/root/
├── .lumi-tokens                    # GITHUB_PAT / CLOUDFLARE_TOKEN / NETLIFY_TOKEN, chmod 600
├── .git-credentials                # GitHub PAT for git pull inside the webhook container
├── firebase-sa.json                # Firebase service account (chmod 600)
├── lumi-monitoring-creds.txt       # Grafana + Prometheus passwords
├── rotated-secrets-…txt            # Secrets from the 2026-05-02 rotation
└── secrets-backup-…/               # Pre-rotation copies of compose / hooks / .env files
```

---

## 6. Connecting to production MongoDB

Mongo is bound to `127.0.0.1:27017` — not exposed publicly. Tunnel in:

```bash
# On your laptop; keep this terminal open while connected
ssh -L 27017:127.0.0.1:27017 root@82.118.227.32
```

Then:

```
mongodb://lumi:<MONGO_PASSWORD>@localhost:27017/lumi_backend?authSource=admin
```

`lumi_backend` is production. `lumi_dev` belongs to the dev container. The pre-merge
`lumi_mobile` / `lumi_adminka` / `lumi_partner` databases were dropped after backup to
`/opt/lumi/backups/*.pre-drop.gz`. `admin`, `config` and `local` are MongoDB system DBs.

Password: `/root/rotated-secrets-…txt`, or `grep MONGO_INITDB_ROOT_PASSWORD
/opt/lumi/docker-compose.yml` on the server. Never commit it.

Two collections trip people up: staff live in **`admin_users`**
(`ADMIN_USERS_COLLECTION=admin_users`), app users in **`users`**. They cannot be merged —
the `{login}` and `{phone}` unique indexes can't coexist in one collection.

Browser alternative: `db.lumipass.uz` (mongo-express).

---

## 7. Default staff logins

Seeded into `admin_users` for testing. Login at `https://adminka.lumipass.uz`:

| Login | Password | Role |
|---|---|---|
| `owner` | `Ow#9Lx2$mP7!kRvQ` | owner |
| `admin` | `Ad@5Jn8#fW3!yTzX` | admin |
| `moderator` | `Mo$4Ht6@bN1!rKpY` | moderator |

Bcrypt-hashed (12 rounds) in the DB. Re-seed after data loss with
`ssh root@82.118.227.32 '/opt/lumi/seed-admins.sh'`.

These are real working production credentials sitting in a git repo. Rotate them before
granting repo access to anyone who shouldn't have admin panel access.

---

## 8. Troubleshooting

**Deployed, webhook was green, but nothing changed in prod.** See §0 — you rebuilt
`mobile-backend`, which serves no traffic. Rebuild `merged-backend` manually.

**Backend boot loop with `Authentication failed`.** Mongo password drifted between
`docker-compose.yml` and the `.env`, or you edited `.env` and ran `dc restart` (which
doesn't reload env). Fix: `dc up -d --force-recreate merged-backend`.

**App crash-loops at startup with a Telegraf error.** An empty `TELEGRAM_BOT_TOKEN`
throws at construction and `main.ts` exits on unhandled rejections. Either set a valid
token or leave the bot disabled the supported way.

**All staff suddenly logged out of one panel.** That tree's JWT secret changed. Console
and partner trees each verify with their own secret — see §1.

**Webhook fired but build didn't happen.** `dc logs --tail=50 webhook`. Usually
`git: not found` or `docker: not found`, meaning the image reverted to
`thecatlady/webhook:latest`. Rebuild: `dc build webhook && dc up -d webhook`.

**`caddy reload` fails: "no configuration file provided".** You're not in `/opt/lumi`.
Use the `dc` alias or `cd` first.

**Cert is from `acme-staging-v02` (browser shows untrusted).** Caddy fell back to staging
after too many failed retries. `dc down && rm -rf data/caddy/data/caddy/acme/*
data/caddy/config/* && dc up -d`.

**Can't connect to Mongo over the SSH tunnel.** On the server, `ss -tlnp | grep 27017`
should show `127.0.0.1:27017` LISTEN. If missing, the port mapping got reverted — re-add
`ports: ["127.0.0.1:27017:27017"]` under `mongo:` and `dc up -d mongo`.

**"Cannot GET /xxx" with `x-powered-by: Express`.** NestJS responding correctly — the app
is alive, the route just doesn't exist. Remember the namespacing: an adminka route is
`/api/console/*` inside the app even though the browser sends `/api/*`.
`grep -rh "@Controller(" /opt/lumi/repos/mobile/src/` lists the real routes.

**Image URLs in API responses are dead.** Check `PUBLIC_BASE_URL`. It was once
`app.lumipass.uz`, which has no DNS record, so every returned image URL 404'd. It should
be `mobile-api.lumipass.uz`.

---

## 9. Rotating secrets

Generate with `openssl rand -hex 32` (webhook secrets, API keys) or
`openssl rand -base64 24` (passwords). Back up first:

```bash
dc exec mongo mongodump --username lumi --password <PASSWORD> \
  --authenticationDatabase admin --out /data/db/backup-$(date +%F-%H%M%S)
cp -r /opt/lumi /root/lumi-backup-$(date +%F)
```

Order matters:

1. **Mongo password** — `db.changeUserPassword`, then update
   `MONGO_INITDB_ROOT_PASSWORD` in compose and `DATABASE_PASSWORD` in the `.env`, then
   `dc up -d --force-recreate merged-backend`. (Recreating mongo itself isn't needed —
   that compose var is read only on first init.)
2. **JWT secrets** — edit `.env`, `dc up -d --force-recreate merged-backend`. Invalidates
   all sessions for whichever tree's secret you changed.
3. **Webhook secrets** — edit `webhook/hooks.yaml`, `dc restart webhook`, then update each
   GitHub repo's webhook secret to match.
4. **Admin API key** — edit `.env`, force-recreate, then update `VITE_MOBILE_ADMIN_KEY` in
   the Netlify dashboard for `adminka-frontend` and trigger a redeploy.
5. **GitHub PAT** — new token at github.com → Settings → Developer settings → PATs
   (scopes `repo` + `admin:repo_hook`), then update `/root/.git-credentials`.

---

## 10. What's NOT auto-deployed

- **The production backend itself** — see §0. This is the big one.
- **Caddyfile** — edit `/opt/lumi/caddy/Caddyfile`, then
  `dc exec caddy caddy reload --config /etc/caddy/Caddyfile` (no downtime).
- **docker-compose.yml** — edit, then `dc up -d` (recreates only changed services).
- **Webhook Dockerfile / hooks.yaml** — `dc build webhook && dc up -d webhook` for the
  image; `dc restart webhook` for hooks-only changes.
- **`.env` files** — edit, then `dc up -d --force-recreate <service>`.
- **Prometheus / Grafana configs** in `/opt/lumi/monitoring/` — restart the service.

### Debugging webhook deliveries

1. **GitHub** → repo → Settings → Webhooks → the deploy webhook → Recent Deliveries.
   Response code, payload, response body, and a "Redeliver" button.
2. **Server** → `dc logs -f webhook` — full git pull + docker build output in real time.

Remember that a 200 here means the *hook* succeeded, not that production changed.
