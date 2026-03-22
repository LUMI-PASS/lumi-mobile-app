export interface LocationData {
  latitude: number;
  longitude: number;
}

export type LocationSource = 'geo_watch' | 'geo_once';
export type LocationWithMeta = LocationData & {
  ts: number;
  source: LocationSource;
  accuracy?: number;
};

const isBrowser = typeof window !== 'undefined';
const isSecure = () =>
  isBrowser &&
  (window.isSecureContext || window.location.protocol === 'https:');

const LS_KEY = 'userLocation';

let current: LocationWithMeta | null = null;
let watchId: number | null = null;
const subscribers = new Set<(loc: LocationWithMeta) => void>();

function publish(loc: LocationWithMeta) {
  current = loc;
  persist(loc);
  for (const fn of subscribers) fn(loc);
}

function persist(loc: LocationWithMeta) {
  if (!isBrowser) return;
  try {
    localStorage.setItem(LS_KEY, JSON.stringify(loc));
  } catch {}
}

export function loadPersisted(): LocationWithMeta | null {
  if (!isBrowser) return null;
  try {
    const raw = localStorage.getItem(LS_KEY);
    if (!raw) return null;
    const p = JSON.parse(raw);
    if (
      p &&
      (p.source === 'geo_watch' || p.source === 'geo_once') &&
      typeof p.latitude === 'number' &&
      typeof p.longitude === 'number' &&
      typeof p.ts === 'number'
    ) {
      return p as LocationWithMeta;
    }
    localStorage.removeItem(LS_KEY);
  } catch {
  }
  return null;
}

const stored = loadPersisted();
if (stored) current = stored;

export function onLocationChange(
  cb: (loc: LocationWithMeta) => void
): () => void {
  subscribers.add(cb);
  if (current) cb(current);
  return () => subscribers.delete(cb);
}

export function startLocationWatch(opts?: {
  enableHighAccuracy?: boolean;
  maximumAgeMs?: number;
  timeoutMs?: number;
}) {
  if (!isBrowser || !isSecure() || !('geolocation' in navigator)) return;
  if (watchId != null) return;

  const {
    enableHighAccuracy = true,
    maximumAgeMs = 0,
    timeoutMs = 10_000,
  } = opts || {};

  watchId = navigator.geolocation.watchPosition(
    (pos) => {
      const loc: LocationWithMeta = {
        latitude: pos.coords.latitude,
        longitude: pos.coords.longitude,
        accuracy: pos.coords.accuracy,
        ts: Date.now(),
        source: 'geo_watch',
      };
      publish(loc);
      // console.log('[geo] watchPosition:', loc);
    },
    (err) => {
      // console.warn('[geo] watchPosition error:', err?.code, err?.message);
    },
    {
      enableHighAccuracy,
      maximumAge: maximumAgeMs,
      timeout: timeoutMs,
    }
  );

  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') {
      void getPreciseLocation({ freshWithinMs: 15_000 }).catch(() => {});
    }
  });
}

export function stopLocationWatch() {
  if (watchId != null && isBrowser && 'geolocation' in navigator) {
    navigator.geolocation.clearWatch(watchId);
  }
  watchId = null;
}

export async function getPreciseLocation(opts?: {
  freshWithinMs?: number;
  desiredAccuracy?: number;
  maxWaitMs?: number;
  requireSecure?: boolean;
}): Promise<LocationWithMeta> {
  const freshWithinMs = opts?.freshWithinMs ?? 20_000;
  const desiredAccuracy = opts?.desiredAccuracy ?? 100;
  const maxWaitMs = opts?.maxWaitMs ?? 8_000;
  const requireSecure = opts?.requireSecure ?? true;

  if (!isBrowser)
    throw new Error('Geolocation is only available in the browser.');
  if (requireSecure && !isSecure()) {
    throw new Error('Geolocation requires HTTPS (or localhost).');
  }
  if (!('geolocation' in navigator)) {
    throw new Error('Geolocation not supported in this browser.');
  }

  const now = Date.now();
  if (
    current &&
    now - current.ts <= freshWithinMs &&
    (current.accuracy == null || current.accuracy <= desiredAccuracy)
  ) {
    return current;
  }

  const best: { loc?: LocationWithMeta } = {};
  let tempWatchId: number | null = null;

  const gotGoodEnough = new Promise<LocationWithMeta>((resolve) => {
    tempWatchId = navigator.geolocation.watchPosition(
      (pos) => {
        const loc: LocationWithMeta = {
          latitude: pos.coords.latitude,
          longitude: pos.coords.longitude,
          accuracy: pos.coords.accuracy,
          ts: Date.now(),
          source: 'geo_watch',
        };
        if (
          !best.loc ||
          (loc.accuracy ?? Infinity) < (best.loc.accuracy ?? Infinity)
        ) {
          best.loc = loc;
        }
        if ((loc.accuracy ?? Infinity) <= desiredAccuracy) {
          resolve(loc);
        }
      },
      () => {
      },
      {
        enableHighAccuracy: true,
        maximumAge: 0,
        timeout: maxWaitMs,
      }
    );
  });

  const timed = new Promise<LocationWithMeta>((resolve) => {
    setTimeout(() => {
      if (best.loc) resolve(best.loc);
      else resolve(null as unknown as LocationWithMeta);
    }, maxWaitMs);
  });

  const result = await Promise.race([gotGoodEnough, timed]);

  if (tempWatchId != null) {
    navigator.geolocation.clearWatch(tempWatchId);
  }

  if (result && typeof result.latitude === 'number') {
    publish(result);
    return result;
  }

  try {
    const once = await new Promise<GeolocationPosition>((resolve, reject) => {
      navigator.geolocation.getCurrentPosition(resolve, reject, {
        enableHighAccuracy: true,
        maximumAge: 0,
        timeout: maxWaitMs,
      });
    });
    const loc: LocationWithMeta = {
      latitude: once.coords.latitude,
      longitude: once.coords.longitude,
      accuracy: once.coords.accuracy,
      ts: Date.now(),
      source: 'geo_once',
    };
    publish(loc);
    return loc;
  } catch (e) {
    throw new Error(
      'Failed to obtain geolocation. Check permissions and HTTPS.'
    );
  }
}

if (isBrowser) {
  startLocationWatch({
    enableHighAccuracy: true,
    maximumAgeMs: 0,
    timeoutMs: 10_000,
  });
}

export async function getLocation(): Promise<LocationData> {
  const loc = await getPreciseLocation();
  return { latitude: loc.latitude, longitude: loc.longitude };
}
