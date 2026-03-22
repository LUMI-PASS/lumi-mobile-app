let mapsLoaderPromise: Promise<any> | null = null;

const SCRIPT_ID = 'google-maps-sdk';
const GOOGLE_MAPS_JS_URL = 'https://maps.googleapis.com/maps/api/js';

const waitForGoogleMaps = (timeoutMs = 12000): Promise<any> =>
	new Promise((resolve, reject) => {
		const started = Date.now();
		const poll = () => {
			if (typeof window !== 'undefined' && (window as any).google?.maps) {
				resolve((window as any).google.maps);
				return;
			}
			if (Date.now() - started > timeoutMs) {
				reject(new Error('GOOGLE_MAPS_LOAD_TIMEOUT'));
				return;
			}
			window.setTimeout(poll, 80);
		};
		poll();
	});

export const loadGoogleMaps = async (apiKey: string): Promise<any> => {
	if (typeof window === 'undefined') {
		throw new Error('GOOGLE_MAPS_BROWSER_ONLY');
	}
	if (!apiKey) {
		throw new Error('GOOGLE_MAPS_MISSING_KEY');
	}
	if ((window as any).google?.maps) {
		return (window as any).google.maps;
	}

	if (!mapsLoaderPromise) {
		mapsLoaderPromise = new Promise((resolve, reject) => {
			const existing = document.getElementById(
				SCRIPT_ID
			) as HTMLScriptElement | null;
			if (existing) {
				waitForGoogleMaps().then(resolve).catch(reject);
				return;
			}

			const script = document.createElement('script');
			script.id = SCRIPT_ID;
			script.async = true;
			script.defer = true;
			script.src = `${GOOGLE_MAPS_JS_URL}?key=${encodeURIComponent(apiKey)}&v=weekly`;
			script.onload = () => {
				waitForGoogleMaps().then(resolve).catch(reject);
			};
			script.onerror = () => {
				reject(new Error('GOOGLE_MAPS_LOAD_FAILED'));
			};
			document.head.appendChild(script);
		}).catch((err) => {
			mapsLoaderPromise = null;
			throw err;
		});
	}

	return mapsLoaderPromise;
};

