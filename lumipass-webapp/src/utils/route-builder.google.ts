import { getLastLocationSync, warmLocation } from '@/utils/location-cache';
export type LatLng = { latitude: number; longitude: number };
type TravelMode = 'driving' | 'walking' | 'bicycling' | 'transit';

export function buildGoogleDirectionsUrl(
	origin: LatLng,
	destination: LatLng,
	opts?: { mode?: TravelMode }
) {
	const base = 'https://www.google.com/maps/dir';
	const path = `${origin.latitude},${origin.longitude}/${destination.latitude},${destination.longitude}`;
	const qs = new URLSearchParams();
	if (opts?.mode) qs.set('travelmode', opts.mode);
	const query = qs.toString();
	return query ? `${base}/${path}?${query}` : `${base}/${path}`;
}

function buildGoogleDirectionsUrlFromDestination(
	destination: LatLng,
	opts?: { origin?: LatLng; mode?: TravelMode }
) {
	const qs = new URLSearchParams();
	qs.set('api', '1');
	qs.set('destination', `${destination.latitude},${destination.longitude}`);
	if (opts?.origin) qs.set('origin', `${opts.origin.latitude},${opts.origin.longitude}`);
	if (opts?.mode) qs.set('travelmode', opts.mode);
	return `https://www.google.com/maps/dir/?${qs.toString()}`;
}

export async function openGoogleDirectionsToBranch(
	branch: {
		latitude?: number | null;
		longitude?: number | null;
		address?: string;
	},
	opts?: {
		mode?: TravelMode;
		onError?: (
			code: 'POPUP_BLOCKED' | 'NO_LOCATION' | 'NO_BRANCH_COORDS'
		) => void;
	}
): Promise<string> {
	const onError = opts?.onError;

	const latitude = Number(branch?.latitude);
	const longitude = Number(branch?.longitude);

	if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
		if (branch?.address && typeof window !== 'undefined') {
			const fallback = `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(branch.address)}`;
			const ok = window.open(fallback, '_blank');
			if (!ok) onError?.('POPUP_BLOCKED');
			return fallback;
		}
		onError?.('NO_BRANCH_COORDS');
		return '';
	}

	const lastLocation = getLastLocationSync();
	const hasValidLastLocation =
		typeof lastLocation?.latitude === 'number' &&
		typeof lastLocation?.longitude === 'number';

	const url = buildGoogleDirectionsUrlFromDestination(
		{ latitude, longitude },
		{
			origin: hasValidLastLocation
				? {
						latitude: lastLocation.latitude,
						longitude: lastLocation.longitude,
					}
				: undefined,
			mode: opts?.mode,
		}
	);

	// Keep location cache fresh without blocking map open.
	warmLocation();

	if (typeof window !== 'undefined') {
		const ok = window.open(url, '_blank');
		if (!ok) onError?.('POPUP_BLOCKED');
	}
	return url;
}
