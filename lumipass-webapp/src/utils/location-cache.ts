import type { LocationData } from '../services/location-service';
import {
	getPreciseLocation,
	loadPersisted,
	startLocationWatch,
	onLocationChange,
} from '../services/location-service';

let bootstrapped = false;
export function initializeLocation(): void {
	if (bootstrapped) return;
	bootstrapped = true;
	startLocationWatch({
		enableHighAccuracy: true,
		maximumAgeMs: 0,
		timeoutMs: 10_000,
	});
	onLocationChange(() => {}); // keep the cache fresh
}

/** Non-blocking hint to refresh location in background */
export function warmLocation(opts?: {
	freshWithinMs?: number;
	desiredAccuracy?: number;
}) {
	if (!bootstrapped) initializeLocation();
	void getPreciseLocation({
		freshWithinMs: opts?.freshWithinMs ?? 20_000,
		desiredAccuracy: opts?.desiredAccuracy ?? 100,
		maxWaitMs: 8_000,
	}).catch(() => {});
}

/**
 * Return location in real time
 * @param forceRefresh If true, ignore existing reading and refetch.
 * @param freshWithinMs Max allowed age of reading (ms).
 * @param desiredAccuracy Max allowed accuracy (meters).
 */

/** Synchronous: returns last persisted reading (or null) */
export function getLastLocationSync(): LocationData | null {
  const p = loadPersisted();
  return p ? { latitude: p.latitude, longitude: p.longitude } : null;
}

export async function getCachedLocation(
	forceRefresh = false,
	freshWithinMs = 20_000,
	desiredAccuracy = 100
): Promise<LocationData> {
	if (!bootstrapped) initializeLocation();

	const loc = await getPreciseLocation({
		freshWithinMs,
		desiredAccuracy,
		maxWaitMs: forceRefresh ? 10_000 : 8_000,
	});

	return { latitude: loc.latitude, longitude: loc.longitude };
}

export const getLastPersistedLocation = loadPersisted;
