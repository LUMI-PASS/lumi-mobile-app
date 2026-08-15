# Cashback & Wallet — Implementation Plan

Spans all three Lumi repos:

| Repo | Path | Role |
|---|---|---|
| Backend | `new-lumi/lumi-mobile-backend` | NestJS monorepo-in-one-app: `src/api/*` (mobile), `src/console/api/*` (adminka, `/api/console/*`), `src/partner/api/*`, `src/settlement` |
| Dashboard | `new-lumi/lumi-adminka-frontend` | React 19 + Vite + MUI, `src/modules/<feature>/{api,hooks,types,ui}` |
| Mobile | `new-lumi/lumi-mobile-app` | Flutter, `lib/{data,domain,presentation,di,common}` |

Status at time of writing: **nothing cashback-related exists in any repo** (`grep -ri cashback` is empty everywhere). This is greenfield on top of an existing, fairly intricate payments stack.

---

## 1. What we're building

Three earn types, each with an independently configurable percentage set from the dashboard:

1. **Activity** — a one-off booking of a non-course activity.
2. **Trial lesson** — one or more trial lessons of a course/sub-course.
3. **Course** — a full course (or sub-course) enrolment.

Setting `1%` for trial lessons in the dashboard applies 1% to *every* trial-lesson purchase, platform-wide. The earned amount is credited to the user's **wallet**, and the wallet balance can be spent on future purchases.

### How the three types are actually distinguished

Do **not** invent a new field or trust the client. Every purchase is one `Order`; the type is derivable from what's already there (`src/models/order.schema.ts`, `src/models/activity.schema.ts`):

```
order.type === OrderType.ACTIVITY
  └── activity.is_course === false                       → EarnType.ACTIVITY
  └── activity.is_course === true
        ├── order.course_purchase === 'trial'            → EarnType.TRIAL_LESSON
        └── order.course_purchase === 'full'             → EarnType.COURSE

order.type === OrderType.SUBSCRIPTION | OrderType.COUPON  → no cashback (v1)
```

`is_course` is a flag on the **Activity**, not on its category — `CoursesService.isCourse()` (`src/api/courses/courses.service.ts:448`) is the authority. `ActivityCategoryType` (`free_play | timed_activity | required_booking`) has no `course` member, despite what a stale comment in `order.schema.ts` says. Resolve the type server-side in one helper and reuse it everywhere.

---

## 2. Decisions to make before coding

These change the schema, so settle them in step 0 (§6). Recommendations given; each is a one-line config change if you disagree.

| # | Question | Recommendation |
|---|---|---|
| D1 | **Who funds the cashback?** | Lumi's platform commission — same purse that funds promocodes and coupon plans. It must **never** reduce `order.settlement.partner_share`. See §3.4. |
| D2 | **Cap cashback at the class's margin?** | Yes, mirroring promocodes: cap at `share% − PAYLOV_FEE_PERCENT`, zero below `MIN_DISCOUNTABLE_SHARE_PERCENT`. Add an `ignore_share_ceiling` flag for deliberate loss-leader campaigns. |
| D3 | **Credit immediately on payment, or after the service is delivered?** | Credit immediately as **`pending`**, mature to **`available`** when `order.settlement.status === DONE` (the settlement cron already runs at activity end). Add a `maturation: 'instant' \| 'on_settlement'` switch in config, default `instant` for v1 — the ledger supports both with no migration. |
| D4 | **Base amount for the percentage** | `paid_amount − wallet_applied`. Cashback on money the wallet itself paid is a self-refilling loop. |
| D5 | **Cap on how much of an order the wallet can cover** | Support `max_redeem_percent` (default `100`). Cheap to add now, painful to retrofit. |
| D6 | **Can the balance go negative** after a refund of already-spent cashback? | No. Claw back what's there, record the shortfall on the ledger entry, surface it in the admin. |
| D7 | **Expiry** | Ledger carries `expires_at` (nullable, unused in v1). Expiry sweeper is post-v1. |
| D8 | **Rounding** | `Math.floor` on both earn *and* redemption, integer soum. Never over-credit, never over-redeem. |
| D9 | **Does `total_amount` stay "the cost", or become "what the gateway charges"?** | **Settle this first — it is the one decision that can break checkout outright.** See §3.4a. Recommendation: keep `total_amount` as the cost, add a persisted `payable_amount`, and update the three Paycom sites that currently assume `charged === total_amount`. |

D9 is not a style question. The Paycom merchant protocol implementation already
treats `order.total_amount` as *the amount Payme will quote back*, and validates
against it in two places before the payment is allowed to proceed. Introducing a
wallet that pays part of an order breaks that invariant. §3.4a spells out both
options and every site that has to move.

---

## 3. Backend

### 3.1 New models — `src/models/`

**`cashback-config.schema.ts`** — a singleton document (`key: 'default'`, unique) rather than a row per type, so one read serves the whole request and the admin edits one form.

```ts
export enum CashbackEarnType {
  ACTIVITY     = 'activity',
  TRIAL_LESSON = 'trial_lesson',
  COURSE       = 'course',
}

@Schema({ _id: false })
export class CashbackRule {
  @Prop({ required: true, min: 0, max: 100, default: 0 })
  percent: number          // 1 = 1%

  @Prop({ default: true })
  is_active: boolean

  @Prop({ type: Number, default: null })
  max_cashback_amount: number | null   // per-order cap, soum; null = uncapped

  @Prop({ min: 0, default: 0 })
  min_order_amount: number
}

@Schema({ timestamps: {...} })
export class CashbackConfig {
  @Prop({ required: true, unique: true, default: 'default' })
  key: string

  /** Master switch. Off ⇒ nothing accrues and the wallet cannot be spent. */
  @Prop({ default: false })
  is_enabled: boolean

  @Prop({ type: Map, of: CashbackRuleSchema, default: {} })
  rules: Map<CashbackEarnType, CashbackRule>

  @Prop({ min: 0, max: 100, default: 100 })
  max_redeem_percent: number           // D5

  @Prop({ default: false })
  ignore_share_ceiling: boolean        // D2

  @Prop({ enum: ['instant', 'on_settlement'], default: 'instant' })
  maturation: 'instant' | 'on_settlement'   // D3

  @Prop({ type: Number, default: null })
  expires_after_days: number | null    // D7, unused v1

  @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
  updated_by?: Types.ObjectId
}
```

Ship with `is_enabled: false` and all percentages `0` — the feature is dark until someone turns it on. That is the rollout kill-switch.

**`wallet.schema.ts`** — one per user, holds only the cached aggregates. Never the source of truth for history.

```ts
@Schema({ timestamps: {...} })
export class Wallet {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, unique: true })
  user_id: Types.ObjectId

  /** Spendable now, soum. Never negative (D6). */
  @Prop({ required: true, default: 0, min: 0 })
  balance: number

  /** Earned but not yet matured (D3). Not spendable. */
  @Prop({ required: true, default: 0, min: 0 })
  pending_balance: number

  /** Held by PENDING orders that intend to spend it. Not spendable. */
  @Prop({ required: true, default: 0, min: 0 })
  held_balance: number

  @Prop({ required: true, default: 0, min: 0 })
  lifetime_earned: number

  @Prop({ required: true, default: 0, min: 0 })
  lifetime_spent: number

  @Prop({ default: false })
  is_frozen: boolean       // admin can freeze a suspected abuser
}
```

`available = balance − held_balance`. Expose that, not `balance`, to the app.

**`wallet-transaction.schema.ts`** — the append-only ledger. **Never update an entry's amount; write a compensating entry.**

```ts
export enum WalletTxKind {
  EARN            = 'earn',             // + cashback accrued on a paid order
  EARN_MATURED    = 'earn_matured',     // pending → available (D3). amount MUST be 0.
  EARN_REVERSED   = 'earn_reversed',    // − order refunded/cancelled
  HOLD            = 'hold',             // − reserved by a PENDING order (moves held_balance)
  HOLD_RELEASED   = 'hold_released',    // + reservation released (moves held_balance)
  SPEND           = 'spend',            // − hold committed on payment (moves balance)
  SPEND_REFUNDED  = 'spend_refunded',   // + paid order cancelled, wallet part returned
  ADJUSTMENT      = 'adjustment',       // ± manual admin correction
  EXPIRED         = 'expired',          // − (post-v1)
}

@Schema({ timestamps: {...} })
export class WalletTransaction {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })  user_id: Types.ObjectId
  @Prop({ type: String, enum: WalletTxKind, required: true })   kind: WalletTxKind

  /** Signed, integer soum. Positive credits, negative debits. */
  @Prop({ required: true })                                     amount: number

  /**
   * Wallet.balance immediately after this entry, taken from the return value of
   * the `findOneAndUpdate` that moved it — never from a separate read, which
   * races. See the write-ordering note in §3.3.
   */
  @Prop({ required: true })                                     balance_after: number

  @Prop({ type: Types.ObjectId, ref: 'Order' })                 order_id?: Types.ObjectId
  @Prop({ type: Types.ObjectId, ref: 'Activity' })              activity_id?: Types.ObjectId
  @Prop({ type: String, enum: CashbackEarnType })               earn_type?: CashbackEarnType

  /** Percent and base snapshotted — the config will change; history must not. */
  @Prop({ type: Number })                                       percent?: number
  @Prop({ type: Number })                                       base_amount?: number

  /**
   * Which bucket this row belongs to. An EARN_REVERSED row inherits the status
   * of the earn it reverses, so the §3.7 sums need no per-kind branching.
   */
  @Prop({ enum: ['pending', 'available'], default: 'available' }) status: string
  @Prop({ type: Date })                                          expires_at?: Date

  /** `${kind}:${order_id}` — the unique index below is the idempotency guard. */
  @Prop({ required: true })                                      idempotency_key: string

  @Prop()                                                        note?: string
  @Prop({ type: Types.ObjectId, ref: 'AdminUser' })              created_by?: Types.ObjectId
  @Prop({ type: Number, default: 0 })                            shortfall?: number  // D6
}

WalletTransactionSchema.index({ idempotency_key: 1 }, { unique: true })
WalletTransactionSchema.index({ user_id: 1, created_at: -1 })
WalletTransactionSchema.index({ order_id: 1, kind: 1 })
WalletTransactionSchema.index({ status: 1, expires_at: 1 })
```

**Which counter each kind moves.** Get this wrong and the reconciliation script
(§3.7) reports permanent phantom drift. Two counters move independently, and a
hold→spend pair touches *both*, one after the other — it is not two debits of
the same money:

| Kind | `balance` | `held_balance` | `pending_balance` |
|---|---|---|---|
| `EARN` (status `available`) | `+amount` | — | — |
| `EARN` (status `pending`) | — | — | `+amount` |
| `EARN_MATURED` | `+base_amount` | — | `−base_amount` |
| `EARN_REVERSED`, earn still pending | — | — | `−amount` |
| `EARN_REVERSED`, earn already available | `−amount` (clamped at 0, D6) | — | — |
| `HOLD` | — | `+amount` | — |
| `HOLD_RELEASED` | — | `−amount` | — |
| `SPEND` | `−amount` | `−amount` | — |
| `SPEND_REFUNDED` | `+amount` | — | — |
| `ADJUSTMENT` / `EXPIRED` | `±amount` | — | — |

**Maturation is the one case where the row that moves the money isn't the row
that records it.** The `EARN_MATURED` entry carries `amount: 0` and puts the
moved sum in `base_amount`, so it is a pure audit breadcrumb and cannot
double-credit. The accounting is carried by flipping the original `EARN` row's
`status` from `pending` to `available` — which is why the §3.7 sums, keyed on
that status, come out right without special-casing anything. That status flip is
the **only** permitted update to a ledger row, and it is permitted precisely
because it doesn't touch `amount`. Nothing else on a row is ever rewritten.

`EARN_REVERSED` debits whichever bucket currently holds the earn — pending if it
never matured, `balance` if it did — never both. The D6 clamp applies only in
the second case, and the unrecoverable remainder goes in `shortfall`.

The unique index on `idempotency_key` is the single most important line in this plan. `markPaidAndFulfill` is reached from **five** rails (Paycom `PerformTransaction`, Paylov webhook, card-OTP confirm, saved-card charge, free/100%-off orders) and webhooks retry. A `E11000` on insert means "already credited" — catch it and return, don't throw.

### 3.2 New order fields — `src/models/order.schema.ts`

Additive, all optional, so every existing document stays valid:

```ts
/** Wallet balance applied to this order (soum). Held at creation, committed on payment. */
@Prop({ type: Number, default: 0, min: 0 })
wallet_amount?: number

/**
 * What the gateway is actually charged: `total_amount − wallet_amount`.
 * Persisted rather than recomputed because the Paycom webhook validates the
 * quoted amount against a stored field and has no access to the request that
 * created the order. Backfill as `total_amount` for existing rows. See §3.4a.
 */
@Prop({ type: Number, min: 0 })
payable_amount?: number

/** Cashback accrued for this order. Written by the earn step; null until paid. */
@Prop({ type: Number, default: 0, min: 0 })
cashback_amount?: number

@Prop({ type: String, enum: CashbackEarnType })
cashback_type?: CashbackEarnType
```

`total_amount` stays "what the order costs after discounts". `wallet_amount` is a **payment method**, not a discount — the gateway is charged `payable_amount`. Keeping them separate is what keeps fiscalisation and the partner split honest (§3.4).

Note that this is exactly the split D9 asks you to confirm: today, several places
in the Paycom module read `total_amount` *meaning* "the charged amount". Adding
`payable_amount` is only half the job — §3.4a lists the reads that must move.

### 3.3 New service — `src/services/cashback/`

`cashback.service.ts`, `cashback.module.ts` (global-ish, exported to orders/paycom/paylov/cards modules). Public surface:

```ts
getConfig(): Promise<CashbackConfig>                       // cached ~60s, singleton upserted on boot
resolveEarnType(order, activity): CashbackEarnType | null
previewEarn(activity, kind, baseAmount): Promise<number>   // for the app's "you'll earn X" line
ensureWallet(userId): Promise<Wallet>                      // upsert; every entry point calls this first
getWallet(userId): Promise<{ balance, pending, held, available, lifetime_* }>
listTransactions(userId, { page, limit, kind? })

// redemption
quoteRedemption(userId, payableAmount, requested?): Promise<number>  // clamped, server-authoritative
hold(userId, orderId, amount): Promise<void>          // atomic, throws if insufficient
releaseHold(orderId): Promise<void>                   // idempotent
commitHold(orderId): Promise<void>                    // hold → spend, idempotent

// accrual
accrueForPaidOrder(order, activity): Promise<number>  // idempotent, never throws
reverseForOrder(order, reason): Promise<void>         // idempotent, clamps at 0 (D6)
matureSettled(orderId): Promise<void>                 // D3, called by settlement cron
adminAdjust(userId, amount, note, adminId)
```

**The wallet document must exist before anything else runs.** A conditional
`updateOne` against a missing wallet reports `modifiedCount: 0`, which is
indistinguishable from "not enough money" — so a brand-new user's first
redemption would fail with *"Insufficient wallet balance"*, and their first
accrual would silently vanish. Every public method starts with `ensureWallet`
(`updateOne({ user_id }, { $setOnInsert: {...} }, { upsert: true })`). Don't try
to combine the upsert with the `$inc` — an upsert whose filter didn't match
creates the document *and* applies the increment, which is precisely the
double-credit you're guarding against.

**Atomicity without Mongo transactions.** Don't assume a replica set is available — the codebase never uses sessions (`grep -rn "startSession\|withTransaction" src` is empty). Guard every debit with a conditional update, and read the post-image back so the ledger's `balance_after` is the real one:

```ts
const wallet = await this.walletModel.findOneAndUpdate(
  { user_id: userId, is_frozen: false, $expr: { $gte: [{ $subtract: ['$balance', '$held_balance'] }, amount] } },
  { $inc: { held_balance: amount } },
  { returnDocument: 'after' },
)
if (!wallet) {
  // Distinguish the three failure modes — support cannot act on a single
  // "insufficient" for a wallet that is actually frozen.
  const w = await this.walletModel.findOne({ user_id: userId }).lean()
  if (!w)           throw new BadRequestException({ error_code: 'wallet_missing' })
  if (w.is_frozen)  throw new ForbiddenException({ error_code: 'wallet_frozen' })
  throw new BadRequestException({ error_code: 'wallet_insufficient' })
}
```

Then insert the ledger entry, stamping `balance_after` from `wallet`. If the insert fails on the unique index, roll the `$inc` back.

**Write ordering.** For **debits**, mutate the wallet first, then write the ledger — a crash in between leaves money held or spent but unrecorded, which reconciliation flags, rather than letting it be spent twice. For **credits**, do the same thing: wallet first, then ledger. An earlier draft of this plan said the opposite for credits, which is not implementable — `balance_after` is required and cannot be known before the balance moves. The under-crediting property that ordering was reaching for is preserved anyway, because the credit path is idempotent on `idempotency_key`: a crash between the two writes is repaired by the retry, and anything that never retries is caught by §3.7.

### 3.4 Where it hooks into the existing payment flow

Read `src/api/paycom/paycom.service.ts` and `src/api/orders/orders.service.ts` before touching anything — the flow already has more branches than it looks.

#### 3.4a The `total_amount` invariant — resolve D9 before writing any redemption code

The Paycom merchant protocol implementation does not merely *send*
`total_amount` to the gateway. It **validates against it on the way back in**,
and builds the fiscal receipt from it. Three reads currently encode the
assumption `charged === total_amount`:

| Site | Line | What it does |
|---|---|---|
| `checkPerformTransaction` | `paycom.service.ts:547` | `if (Math.round(order.total_amount * 100) !== amount) return err(INVALID_AMOUNT)` |
| `createTransaction` | `paycom.service.ts:576` | identical guard |
| `buildFiscalDetail` | `paycom.service.ts:383` | `totalTiyin: Math.round(order.total_amount * 100)` |

Charge the gateway `payable` while leaving these alone and Payme quotes back
`payable × 100`, fails the first guard, and the customer sees a broken
checkout — **every wallet-partial Payme order, 100% of the time**. It fails at
`CheckPerformTransaction`, before any cashback code runs, so it will not look
like a cashback bug. And `buildFiscalItems` is documented (`:468`) to emit items
whose net total "exactly equals the charged amount in tiyin" — on a
wallet-partial order that stops being true, so the receipt is wrong even when
the payment succeeds.

Two ways out. Pick one at the top of step 4 and write the choice into this section:

- **(a) `payable_amount` becomes the charged amount.** Persist it (§3.2) and
  change all three sites above to read it. `total_amount` keeps meaning "what
  the order cost", so `settlement.service.ts` and the partner split need no
  change. Cost: you are editing the merchant protocol, which is the most
  safety-critical code in the repo — every branch needs a test, and existing
  rows need `payable_amount` backfilled to `total_amount` so in-flight orders
  keep validating.
- **(b) The wallet reduces `total_amount`, like a discount.** Paycom is
  untouched and keeps working by construction. Cost: `total_amount` no longer
  means "what the partner sold it for", so every settlement and partner-share
  read has to switch to a new `gross_amount` field — the same surgery, moved
  into the money-split code, where a mistake silently underpays partners
  instead of loudly failing a checkout.

**Recommendation: (a).** A wrong amount fails closed and immediately; a wrong
partner split fails open and is discovered a month later in a reconciliation
meeting. Whichever you choose, add the assertion from §7 that the charged
amount and the validated amount are the same expression, so this can never
drift apart again.

#### 3.4b Accrual, redemption and reversal hooks

**Accrual — exactly one place.** `PaycomMerchantService.markPaidAndFulfill()` (`paycom.service.ts:638`) is the shared funnel for the non-Paycom rails, and `onOrderPaid()` (`paycom.service.ts:89`) is called by *both* it and the Paycom webhook (`:858`). Put the call in **`onOrderPaid`**, after the existing fulfilment, so no rail can skip it:

```ts
// end of onOrderPaid()
await this.cashback.commitHold(order._id)   // awaited — the money is already spent
void this.cashback.accrueForPaidOrder(order, activity).catch(e =>
  this.logger.warn(`cashback accrual failed for order ${order._id}: ${e?.message}`))
```

`commitHold` is awaited because the wallet money is already gone and the ledger
has to say so; `accrue` is best-effort like `registerFiscalReceipt` — a cashback
failure must never break a paid booking. Log it loudly; the reconciliation
script picks up stragglers.

**`commitHold` must not throw — idempotent is not enough.** `onOrderPaid` runs
*after* `markPaidAndFulfill` has already flipped the order to PAID (`:653`), and
the Paycom webhook calls it at `:858`. An exception propagates out of the
webhook as a 500, Payme retries, and the retry now hits the
`order.status === PAID → ORDER_UNAVAILABLE` guard at `:543` / `:572` — so a
transient wallet write failure converts a successful payment into a permanent
error for that customer. Swallow and log internally, exactly like
`registerFiscalReceipt` does:

```ts
async commitHold(orderId): Promise<void> {
  try { /* … */ } catch (e) {
    this.logger.error(`commitHold failed for order ${orderId}: ${e?.message}`)
    // deliberately not rethrown — reconciliation (§3.7) repairs it
  }
}
```

**Redemption — three checkout entry points**, all in `orders.service.ts`:

- `checkout()` (`:784`) — activities
- `courseCheckout(userId, activityId, 'trial' | 'full', dto)` (`:418`) — both course kinds
- `TransactionsService.purchaseSubscription()` — **out of scope v1**, reject `wallet_amount` there

In each, after the promocode / coupon-plan discount resolves and `totalAmount` is final:

```ts
let walletAmount = 0
if (dto.use_wallet) {
  walletAmount = await this.cashback.quoteRedemption(userId, totalAmount, dto.wallet_amount)
}
const payable = totalAmount - walletAmount

// … create the order, persisting wallet_amount and payable_amount …

if (walletAmount > 0) await this.cashback.hold(userId, order._id, walletAmount)
```

**Mind the sequencing.** `hold()` keys the ledger entry on `order._id`, but in
`checkout()` the order isn't created until `orders.service.ts:903` — well after
`totalAmount` goes final around `:849`. So quote first, create the order with
`wallet_amount` / `payable_amount` already on it, then hold. (Pre-generating the
ObjectId and holding first also works and closes a tiny race, at the cost of a
hold that can outlive a failed order creation — the stale-hold sweeper covers
that, so either is fine. Just don't write it in the order the pseudocode above
would suggest at a glance.)

Then `payable === 0` must join the **existing free-order path** — `isFreeOrder` already calls `markPaidAndFulfill(order, { paidAmount: 0 })` and returns a terminal PAID result with no `checkout_url`. Extend that condition to `payable <= 0` rather than writing a second free path.

Every gateway call must send `payable`, not `total_amount` — and per §3.4a, so must every place that *validates* what came back. The complete list:

| Direction | Site |
|---|---|
| out | `paycom.buildCheckoutUrl({ amountUzs })` — `orders.service.ts:774`, `:1030` |
| out | `paylovCheckout(order, totalAmount, dto)` — `orders.service.ts:769`, `:1026` |
| out | saved-card charge in `src/api/cards/cards.service.ts` |
| out | `coupon-payment.service.ts:51` — coupon orders earn and spend nothing in v1, so this one should keep using `total_amount`; it is listed so the audit is provably complete, not because it changes |
| **in** | `checkPerformTransaction` — `paycom.service.ts:547` |
| **in** | `createTransaction` — `paycom.service.ts:576` |
| **in** | `buildFiscalDetail` — `paycom.service.ts:383` |

Missing an outbound site charges the customer for the part the wallet already covered. Missing an inbound one rejects the payment outright (§3.4a).

**Ordering of money rules** — write this down in a comment, it will be asked repeatedly:

```
subtotal
  − promocode discount   XOR   coupon-plan discount   (they never stack; existing rule)
  = total_amount                                      (what the order costs)
  − wallet_amount                                     (a payment method, NOT a discount)
  = payable_amount                                    (what the gateway charges & validates)

wallet_amount  = floor(min(available,
                          requested ?? ∞,
                          total_amount × max_redeem_percent / 100))
cashback earned = floor(payable_amount × rule.percent / 100)  ← D4: the wallet part earns nothing
```

`max_redeem_percent` is a percentage **of `total_amount`** — the post-discount
cost of the order, not the pre-discount subtotal. Both clamps floor to integer
soum (D8): never over-credit, never over-redeem.

**The partner split must not move.** `src/settlement/settlement.service.ts` and `PartnerShareService` compute `partner_share` and `platform_commission` from the order. The partner sold the class at `total_amount` and must be paid on `total_amount` — the wallet-funded slice comes out of **Lumi's** commission, exactly like a coupon discount. Audit `settlement.service.ts` for anything reading `paid_amount` and make sure the split's base stays `total_amount`. Same for `registerFiscalReceipt` (`paycom.service.ts:680`): the OFD receipt reports the **sale**, and its `charged <= 0` early-return (it reads `order.paid_amount ?? order.total_amount`) will now trigger on fully-wallet-covered orders — confirm with accounting whether such a booking still needs a receipt. The *partial* case is the subtler one: per §3.4a the receipt items are built from `total_amount` while the customer's card was charged `payable_amount`, so somebody has to decide which number the fiscal receipt is supposed to carry. **Flag both cases to the finance side before launch** — this is a step 0 question, not a rollout detail.

**Share ceiling (D2).** `src/services/partner-share/partner-share.service.ts` already exports the constants and the ceiling helpers:

```ts
MIN_DISCOUNTABLE_SHARE_PERCENT = 5
PAYLOV_FEE_PERCENT             = 2.5
PROMOCODE_CAP_CEILING_PERCENT  = 30
```

Unless `ignore_share_ceiling` is set, clamp the effective cashback percent to `max(0, share% − PAYLOV_FEE_PERCENT)`, and to `0` when `share% <= MIN_DISCOUNTABLE_SHARE_PERCENT`. Reuse the existing helpers rather than recomputing. Note courses may carry a different share arrangement than activities — verify with `PartnerShareService.resolve()` on a real course before assuming symmetry.

**Reversal.** `OrdersService.cancelOrder()` (`:1396`) already handles gateway reversal and sets `refund_status: 'automatic' | 'manual' | 'none'`. Add, inside the same flow:

```ts
await this.cashback.releaseHold(order._id)        // order was PENDING
await this.cashback.reverseForOrder(order, reason) // order was PAID → claw back the earn
// and return the wallet-funded part: SPEND_REFUNDED for order.wallet_amount
```

A manual refund done outside the app (`refund_status: 'manual'`) will not pass through here — give the admin a manual-adjustment endpoint (§3.6) and say so in the runbook.

**Stale holds.** A PENDING order that is never paid holds balance forever. Add a sweeper alongside the existing settlement cron: release holds on orders still `PENDING` after N hours. `TRANSACTION_TIMEOUT_MS` in `paycom.service.ts:44` is 12 hours — the sweeper must run *longer* than that (24h is a safe default), or it will release a hold on an order Payme is still entitled to complete. Without a sweeper at all, users will report "my balance disappeared."

**Turning the feature off mid-flight.** `is_enabled: false` stops new accrual and
new redemption. It must **not** strand orders that are already holding balance:
`commitHold` and `releaseHold` always run regardless of the flag, and only
`quoteRedemption` / `hold` / `accrueForPaidOrder` check it. Otherwise flipping
the kill switch — the thing you reach for when something is going wrong —
freezes every in-flight customer's money.

### 3.5 Mobile API — `src/api/cashback/`

New module, follows the `Public`/`AuthGuard` conventions of its siblings. It
serves two path prefixes — `/api/cashback/*` (config) and `/api/wallet/*` (the
user's money) — so declare two controllers in the one module rather than trying
to make a single `@Controller` prefix cover both.

| Method | Path | Notes |
|---|---|---|
| `GET` | `/api/cashback/config` | Public. `{ is_enabled, rules: { activity, trial_lesson, course }, max_redeem_percent }`. Lets the app render "1% cashback" badges without hardcoding. Cache aggressively. |
| `GET` | `/api/wallet` | Auth. `{ balance, pending_balance, held_balance, available, lifetime_earned, lifetime_spent, currency: 'UZS' }` |
| `GET` | `/api/wallet/transactions?page=&limit=&kind=` | Auth. Paginated ledger, newest first. |
| `POST` | `/api/wallet/quote` | Auth. `{ amount }` → `{ redeemable }`. Optional; the booking sheet can compute it locally from `available` + `max_redeem_percent`, but a server quote avoids drift. |

`CheckoutDTO` (`src/api/orders/dto/checkout.dto.ts`) and `CourseCheckoutDTO` gain:

```ts
@ApiProperty({ required: false, description: 'Apply wallet balance to this order.' })
@IsOptional() @IsBoolean() @Type(() => Boolean)
use_wallet?: boolean

@ApiProperty({ required: false, description: 'Max wallet amount to apply (soum). Server clamps; omit to apply the maximum allowed.' })
@IsOptional() @IsInt() @Min(1)
wallet_amount?: number
```

The checkout response's `base` object gains `wallet_amount`, `payable_amount`, and `cashback_estimate` — the booking sheet needs all three to render its summary.

### 3.6 Console API — `src/console/api/cashback/`

Mirror `src/console/api/promocodes/` exactly (controller + service + module + dto, `@Roles(Role.MODERATOR)`, `{ data }` envelope, registered in `app.module.ts` next to `ConsolePromocodesModule`).

| Method | Path | Notes |
|---|---|---|
| `GET` | `/api/console/cashback/config` | Current singleton |
| `PATCH` | `/api/console/cashback/config` | The three percentages + flags. Stamps `updated_by`. |
| `GET` | `/api/console/cashback/wallets?page=&search=` | Wallet list joined to user phone/name, sortable by balance |
| `GET` | `/api/console/cashback/wallets/:userId/transactions` | One user's ledger |
| `POST` | `/api/console/cashback/wallets/:userId/adjust` | `{ amount, note }`, signed. Manual correction — the escape hatch for out-of-band refunds. Audited via `created_by`. |
| `PATCH` | `/api/console/cashback/wallets/:userId/freeze` | `{ is_frozen }` |
| `GET` | `/api/console/cashback/statistics?from=&to=` | Issued / redeemed / reversed / **outstanding liability** (`sum(balance + pending_balance)`), and a breakdown by earn type |

Outstanding liability is money Lumi owes its users. Whoever runs finance will want that number; put it on the dashboard from day one.

### 3.7 Reconciliation script — `src/console/scripts/`

A one-shot script that walks paid orders in a date range and reports any whose `cashback_amount` doesn't match a ledger `EARN` entry, plus any wallet failing either balance invariant. Run it after the first week. Best-effort accrual means drift is *possible* by design; this is how you find it.

**The two invariants, stated precisely.** `balance` and `held_balance` move
independently (see the table in §3.1), so a single "sum the ledger" check is
wrong — `HOLD` and `SPEND` are *not* two debits of the same money, and summing
them together reports permanent phantom drift on every order that ever used the
wallet:

```
balance         == Σ amount over status='available' rows,
                   kinds { EARN, EARN_MATURED, EARN_REVERSED, SPEND,
                           SPEND_REFUNDED, ADJUSTMENT, EXPIRED }
pending_balance == Σ amount over status='pending' rows,
                   kinds { EARN, EARN_REVERSED }
held_balance    == −Σ amount over kinds { HOLD, HOLD_RELEASED }
```

Two things make these come out clean. `EARN_MATURED` carries `amount: 0`, so it
is inert in the first sum and only documents the `pending → available` move —
which is actually recorded by flipping the `EARN` row's status (§3.1). And an
`EARN_REVERSED` row takes the **status of the earn it reverses**, so a reversal
of a not-yet-matured earn lands in the pending sum and one of a matured earn
lands in the balance sum, with no kind-specific branching in the script.

A third check worth running: every `HOLD` with no matching `HOLD_RELEASED` or
`SPEND` whose order is no longer `PENDING` — that is the stale-hold sweeper's
miss list, and the thing behind any "my balance disappeared" report.

---

## 4. Dashboard (`lumi-adminka-frontend`)

New module `src/modules/cashback/` following the `promocodes` layout precisely:

```
src/modules/cashback/
  api/cashback.ts            // axios + endpoints.cashback (add to src/utils/axios.ts)
  types/cashback.ts          // CashbackConfig, CashbackRule, Wallet, WalletTransaction, WalletTxKind
  hooks/useCashbackConfig.ts // react-query: config query + PATCH mutation w/ invalidation
  hooks/useWallets.ts        // paginated wallets, one user's ledger, adjust mutation
  ui/CashbackSettingsForm.tsx
  ui/WalletsList.tsx
  ui/WalletLedgerDrawer.tsx
  ui/CashbackStatCards.tsx
```

Wiring, same as every other module:

- `src/utils/axios.ts` → `endpoints.cashback = { config, wallets, statistics }`
- `src/routes/paths.ts` → `cashback: { root: `${ROOTS.DASHBOARD}/cashback` }`
- route + lazy page under `src/pages/dashboard/`, nav entry in the layout's nav config
- `src/locales` — UI copy (match the existing dashboard language)

**Settings screen layout** — one page, three cards:

1. **Master switch** — `is_enabled`, with a plain-language note that off means no accrual *and* no spending.
2. **Percentages** — three rows (Activity / Trial lesson / Course), each with `percent`, `is_active`, `max_cashback_amount`, `min_order_amount`. Show a live example under each: *"a 100 000 so'm booking earns 1 000 so'm"*. Inline warning when a percent exceeds the typical partner-share ceiling and `ignore_share_ceiling` is off — otherwise a moderator sets 10% and quietly gets 2.5% in production, and files a bug.
3. **Redemption & advanced** — `max_redeem_percent`, `maturation`, `ignore_share_ceiling` (behind a confirm — it means selling at a loss), `expires_after_days` (disabled, post-v1).

**Wallets screen**: searchable table (user, phone, available, pending, held, lifetime earned/spent, frozen), row click → ledger drawer with the manual-adjust form. Every adjustment demands a note.

**Statistics**: four stat tiles (issued, redeemed, reversed, outstanding liability) + a by-type breakdown, using whatever chart wrapper the dashboard already has. Reuse the date-range filter pattern from the existing dashboard module rather than inventing another.

---

## 5. Mobile (`lumi-mobile-app`)

Follow `CLAUDE.md` to the letter: enums with `unknown` fallback, `context.colors` roles, `AppText` getters, `Assets.icons.*`, `make gen` after any annotated change, strings via `translations.csv` (+ hand-written getters in `strings.g.dart`).

**Don't resurrect the old wallet.** A previous coin-based wallet lived at
`lib/presentation/app/main/subscreens/wallet/`, with `Tariff` "coin packs", a
`CoinFlow` ledger and a coin-gated booking sheet. It was deleted on the
`cashback` branch because none of it had a backend — `transaction/wallets/me`,
`transaction/coin-flows/me`, `POST bookings/` and `classes/:id/check-eligibility`
have no controller in the merged backend, and `WalletRoute` was registered but
was never a tab. Build fresh against the endpoints in §3.5; the `coin_lumi.png`
and `wallet_unselected.svg` assets were kept and can be reused.

### 5.1 Data layer

`lib/data/api_model/wallet/`:

- `wallet_balance.dart` — freezed + json_serializable
- `wallet_transaction.dart`
- `wallet_tx_kind.dart` — **plain enum with a `key` and a non-throwing `fromKey` returning `unknown`**, exactly like `notification_type.dart` in the reference app. The backend will add kinds (`expired`, new adjustments); an unmodelled one must render as a neutral row, not crash the ledger.
- `cashback_config.dart` — `{ isEnabled, activityPercent, trialLessonPercent, coursePercent, maxRedeemPercent }`

`lib/domain/repo/wallet/wallet_api.dart` — `@injectable`, Dio, unwrapping `data:` the way `orders_api.dart` does (the envelope is inconsistent across endpoints — copy the defensive `raw is Map && raw['data'] is …` pattern, don't assume).

`lib/domain/repo/wallet/wallet_repository.dart` + `lib/domain/impl/wallet_repository_impl.dart`, then `make gen` for `injection.config.dart`.

### 5.2 Wallet screen

`lib/presentation/app/profile/wallet/wallet_page.dart` + `cubit/`:

- Balance hero card (`FrostedCard` / `Container3d`, per the shared-widget rule) — available balance large, pending and held as secondary lines with a short explanation of each. "Held" *will* confuse people; label it "reserved for a pending order" and link to that order.
- Ledger list, paginated, newest first: icon by kind, signed amount, the activity/course name, date.
- Empty state explaining how cashback is earned, with the current percentages read from `/api/cashback/config`.
- `@RoutePage`, register in `lib/common/router/app_router.dart` next to `PaymentHistoryRoute`, then `make gen`.
- Entry point: a row in the profile menu, and the balance chip on the profile header.

### 5.3 Spending at checkout

Three sheets, all large and already dense — budget real time here:

- `lib/presentation/app/home/class_detail/widgets/booking_page.dart` (3222 lines) — activities
- `lib/presentation/app/home/course_detail/course_booking_page.dart` (1222 lines) — course full + trial
- `lib/presentation/app/home/class_detail/widgets/payment_sheets.dart` (1201 lines) — payment method selection

In the order summary, below the existing promocode/coupon rows, add a **"Use balance"** row: a switch plus "− 12 000 so'm" and the remaining balance. It must interact correctly with what's already there:

- The promocode field is hidden when the user has a coupon plan (`_hasCoupon`) — the wallet row is **not** subject to that rule. The wallet is a payment method, not a discount, and stacks with either.
- When the wallet covers the whole payable amount, the sheet must take the **existing 100%-off path** (`booking_page.dart:2062`) — the order comes back terminal `PAID` with no `checkout_url`, and the success screen shows without a webview. Don't build a second free-order branch.
- Send `use_wallet: true` (and `wallet_amount` only if you expose a partial-amount input; v1 recommendation is all-or-nothing) in the checkout call, and render the response's `wallet_amount` / `payable_amount` rather than the locally computed guess.

Mirror `lib/common/utils/coupon_discount.dart`: a small `lib/common/utils/cashback.dart` holding the client-side preview math and the redemption cap, with a comment that it mirrors the backend and must be kept in step. Same discipline the coupon ceiling already gets.

### 5.4 Earn surfaces

- Class / course detail: a "**1% cashback**" chip, percentage from the public config, hidden when `is_enabled` is false or the rule's percent is 0.
- Booking summary: "You'll earn ~X so'm" under the total — use the server's `cashback_estimate`, not a local calc.
- Booking success screen (`lib/presentation/app/home/booking_complete/`): "+X so'm added to your balance."
- Optional: reuse the existing push/in-app notification pipeline for the credit. Needs a `NotificationType` enum member with the usual `unknown`-safe handling.

### 5.5 Strings & assets

Add every new string to `assets/localization/translations.csv` (all supported locales), add typed getters to `lib/common/gen/strings.g.dart` **by hand** — remember `make gen` deletes and restores that file, and its deletion must never be committed. New wallet/cashback icons go under `assets/icons/` with `fill="currentColor"`, then `make gen`, then `Assets.icons.<name>.svg(...)`.

---

## 6. Steps

Sequential — finish one, then start the next. Everything ships behind
`is_enabled: false`, so nothing is user-visible in production until step 6 flips
it. Step 0 is not a build step; it is the conversation that has to happen first.

**Progress (2026-08-15).** Steps 1–3 are built and the backend halves are
deployed to production, still dark (`is_enabled: false`, all percentages 0).

| Step | State | Landed as |
|---|---|---|
| 1 — Wallet foundation | done | backend `0efe369`, mobile `e222ecb` |
| 2 — Percentage control | done | backend `19b4971`, adminka `469d5a6` |
| 3 — Accrual | done | backend `8f09cab`, mobile `c0148cc` |
| 4 — Redemption | done | backend `ad6e747`, mobile `1fb3833` |
| 5 — History | **next** | — |

**D9 was resolved as option (a).** `total_amount` keeps meaning "what the order
cost and what the partner is paid on"; a persisted `payable_amount` means "what
the gateway is charged". Settlement and `PartnerShareService` needed no change —
`computeSplit` reads `total_amount`, verified.

Two corrections to §3.4a worth carrying forward:

- **The call-site table was incomplete.** It misses Paycom's `GetStatement`,
  which reports each transaction's amount for Payme's own reconciliation. Left
  on `total_amount` it would flag every wallet-funded order as a mismatch.
- **`buildFiscalDetail` was never a choice.** Payme validates that the receipt's
  line total equals the transaction amount, so the receipt *must* report the
  charged amount. The wallet-funded slice therefore appears on the fiscal
  receipt as a discount. §3.4's "somebody has to decide which number the receipt
  carries" is settled by the protocol, not by preference — but the finance side
  should still be told that is what it now says.

Rather than the per-site edits the plan describes, there is one exported
`chargedAmountOf(order)` in `order.schema.ts`, and every outbound charge and
inbound guard calls it. §7 asks for a test asserting "the two sides cannot
drift apart"; with one expression, drift is unrepresentable rather than merely
tested for. `src/models/charged-amount.spec.ts` covers it.

**No backfill migration was needed.** `chargedAmountOf` falls back to
`total_amount` when `payable_amount` is absent, so pre-deploy rows — including
in-flight PENDING ones — resolve exactly as they did before. That is strictly
safer than a production write that could half-apply.

Step 3 added one thing this plan didn't name: `GET /api/cashback/preview`.
`/config` reports the *configured* percentage, but the share ceiling (§3.4b)
means a 10% rule can pay 3.5% on one class and 0 on another — so the app cannot
compute what a purchase earns, and a badge quoting the config would promise
money the accrual refuses. The preview endpoint returns the ceiling-clamped rate
for one activity; the app does only the arithmetic around it, mirrored in
`lib/common/utils/cashback.dart`.

| Step | Scope | Repos | Depends on |
|---|---|---|---|
| **0 — Decisions** | Settle D1–D8 with the business side. Confirm both fiscal-receipt questions (§3.4) with finance. Nail down the funding purse. **D9 (§3.4a) can wait until step 4** — see the note below. | — | — |
| **1 — Wallet foundation** | The 3 schemas, `CashbackService` primitives (`ensureWallet`, atomic credit/debit, ledger writes), `GET /api/wallet` + `/api/wallet/transactions`, and the admin adjust endpoint. Mobile: models, api, repo, cubit, balance screen, profile entry point. Unit tests on the atomicity guards. | Backend + Mobile | 0 |
| **2 — Percentage control** | Console CRUD + statistics, adminka `cashback` module (settings form, wallets list, liability tile). Admins can configure and watch — with nothing accruing yet. | Backend + Dashboard | 1 |
| **3 — Accrual** | `resolveEarnType`, `accrueForPaidOrder` hooked into `onOrderPaid`, share-ceiling clamp, order fields. Mobile: earn surfaces (cashback chip, "you'll earn ~X", success screen). Ships with percentages at 0 → no behaviour change in prod. | Backend + Mobile | 2 |
| **4 — Redemption** | **D9 first.** `hold` / `commit` / `release`, DTO fields, all three checkout paths, the full §3.4 call-site table (inbound validation as well as outbound charges), free-order path extension, stale-hold sweeper, `cancelOrder` reversal + clamping. Mobile: "Use balance" in the three sheets, full-coverage free path. The riskiest step by a wide margin — it edits the merchant protocol. Budget for the amount-agreement tests, not just the happy path. | Backend + Mobile | 3, and D9 settled |
| **5 — History** | Mobile ledger screen: paginated, newest first, icon and copy per `WalletTxKind`, attribution to the activity/course each entry came from. Pure UI over data steps 1–4 already write. | Mobile | 4 |
| **6 — Rollout** | Reconciliation script, runbook. Then enable with a small percentage, watch the outstanding-liability tile, ramp. | All | 5 |

**Why redemption sits between accrual and history.** A history screen fed only
by `EARN` rows is half a ledger — you cannot design or test the row rendering,
the sign handling, or the "reserved for a pending order" state without real
`HOLD` / `SPEND` / `SPEND_REFUNDED` entries to look at. Building history last
means building it once, against the complete set of kinds.

**Why D9 is not a step-0 blocker in this ordering.** Accrual does not change
what the gateway is charged, so steps 1–3 never touch `payable_amount` and never
go near the Paycom amount guards. That is the main advantage of this sequence
over an accrual-then-redemption-then-mobile one: three shippable steps land
before anyone opens the merchant protocol. It is still the hardest decision in
the plan — it just belongs at the top of step 4 rather than gating the start.

**Two things in step 1 that are easy to skip and expensive to retrofit:**

1. **Write the ledger from the first credit**, even though nothing reads it
   until step 5. A `balance` number alone makes every movement between steps 3
   and 5 unattributable, and there is no way to reconstruct where it came from
   afterwards. The ledger is the source of truth (§3.1); `Wallet` is a cache.
2. **Ship the admin adjust endpoint in step 1**, even though it is otherwise
   step-2 dashboard work. Without it every wallet reads `0` until step 3 lands
   and the mobile screen cannot be QA'd at all. With it, you seed a test balance
   by hand on day one.

---

## 7. Testing

**Backend (Jest, `jest.config.ts` is already set up):**

- `resolveEarnType` over the full matrix: activity, flat course trial, sub-course trial, flat course full, sub-course full, legacy order with no `course_purchase`, subscription, coupon.
- Idempotency: call `accrueForPaidOrder` five times on one order → exactly one `EARN` entry, one credit. Same for `commitHold`, `releaseHold`, `reverseForOrder`.
- Concurrency: two parallel `hold()` calls for a balance that only covers one → exactly one succeeds, `held_balance` correct.
- Share ceiling: 10% configured on a class with a 6% share → 3.5% applied; on a 4% share → 0; with `ignore_share_ceiling` → 10%.
- Money ordering: promocode + wallet on one order → `payable` and `partner_share` both correct; check `partner_share` is computed off `total_amount`, not `payable`.
- Full coverage: wallet ≥ payable → order terminal PAID, no gateway call, tickets assigned.
- Reversal with the cashback already spent → balance clamps at 0, `shortfall` recorded.
- **Paycom amount agreement (§3.4a), the regression this plan exists to prevent:** build an order with a partial wallet payment, then assert that the amount handed to `buildCheckoutUrl` and the amount `checkPerformTransaction` / `createTransaction` accept are the same number. Assert on the *expression*, not a literal, so the two sides cannot drift apart again.
- Fiscal items on a wallet-partial order: `sum(price × count − discount)` equals whatever §3.4a decided the receipt reports.
- `commitHold` throwing internally must not propagate out of `onOrderPaid` — simulate a wallet write failure and assert the webhook still returns success.
- Ledger invariants: run the §3.7 checks as an assertion at the end of every money test, so a bad `balance_after` or a miscounted `HOLD` fails the suite rather than production.
- First-touch wallet: a user with no wallet document earns, then redeems — no `wallet_missing` leaking to the client, no double-credit from the upsert.
- A frozen wallet returns `wallet_frozen`, not `wallet_insufficient`.

**Manual, on staging, before enabling:** buy one of each of the three types end-to-end through Paylov and through direct Payme; cancel a paid one; refund manually and correct via the admin adjust endpoint; verify the ledger reads sensibly and the reconciliation script is clean.

**Do not run the Flutter app to test** (per `CLAUDE.md`) — hand the build to whoever does device QA.

---

## 8. Risks

| Risk | Mitigation |
|---|---|
| **Paycom rejects every wallet-partial order** (`INVALID_AMOUNT` at `paycom.service.ts:547` / `:576`) | The highest-severity item here, and invisible until a real payment is attempted — it fails before any cashback code runs, so it won't look like a cashback bug. Resolve D9, move all three inbound reads (§3.4a), add the amount-agreement test from §7. |
| Double-crediting on webhook retry | Unique `idempotency_key` index; catch `E11000` as success |
| A gateway call still charging `total_amount` | Work the call-site table in §3.4 rather than a from-memory grep — it lists the inbound validation sites as well as the outbound charges. Add a test asserting the charged amount equals `payable_amount`. |
| `commitHold` failure turns a paid order into a permanent error | Never rethrow out of `onOrderPaid`; the Payme retry would hit `ORDER_UNAVAILABLE` |
| Reconciliation reports phantom drift and gets ignored | Use the per-counter invariants in §3.7, not one combined ledger sum — a check that cries wolf is worse than no check |
| First-time user can't redeem, or their first cashback vanishes | `ensureWallet` upsert at every entry point; distinct `wallet_missing` / `wallet_frozen` / `wallet_insufficient` error codes |
| Kill switch freezes in-flight customers' money | `commitHold` / `releaseHold` ignore `is_enabled`; only accrual and new redemption check it |
| Partner over/under-paid | Settlement split base stays `total_amount`; add a settlement test with a wallet-funded order |
| Cashback sold below margin | Share ceiling on by default; dashboard warning; `ignore_share_ceiling` behind a confirm |
| Balance "disappears" into stale holds | Sweeper cron + `held_balance` shown separately in the app with an explanation |
| Fiscal receipt wrong on wallet-covered orders | Resolve with finance in step 0; `registerFiscalReceipt`'s `charged <= 0` guard needs an explicit answer |
| Abuse (buy → earn → cancel → keep) | Reversal on cancel; `is_frozen`; consider D3 `on_settlement` maturation if abuse shows up |
| Uncontrolled liability growth | Liability tile on the dashboard from day one; start at a low percentage |

---

## 9. Deploy

Per this repo's `CLAUDE.md`: **the GitHub auto-deploy webhook is dead** — it rebuilds the old `mobile-backend` / `adminka-backend` / `partner-backend` containers, which Caddy no longer routes to. A green webhook means nothing. Every backend deploy is manual:

```bash
ssh root@82.118.227.32
cd /opt/lumi/repos/mobile && git pull origin main
cd /opt/lumi && docker compose up -d --build --no-deps merged-backend
```

Deploy order that keeps prod safe at every step: **backend (dark, `is_enabled: false`) → dashboard → configure with percentages still 0 → mobile release → flip the switch to a small percentage → watch liability → ramp.**

Roll back by setting `is_enabled: false`. No deploy needed — accrual and redemption both stop, and existing balances are preserved rather than lost.
