'use client';

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Button } from 'rizzui';
import { useTranslations } from 'next-intl';
import {
	PiArrowsInSimpleDuotone,
	PiArrowsOutSimpleDuotone,
	PiMapPinDuotone,
	PiNavigationArrowDuotone,
	PiWarningCircleDuotone,
} from 'react-icons/pi';
import { env } from '@/env.mjs';
import { loadGoogleMaps } from '@/services/google-maps-loader';
import { useDrawer } from '@/app/shared/drawer-views/use-drawer';
import CloseDrawerButton from '@/components/ui/buttons/close-drawer-button';
import { formatDistanceKm } from '@/utils/format-distance';
import { getCachedLocation, getLastLocationSync } from '@/utils/location-cache';
import cn from '@/utils/class-names';

export type ExploreMapBranch = {
	id: string;
	title?: string | null;
	address?: string | null;
	latitude?: number | string | null;
	longitude?: number | string | null;
	distance?: number | null;
};

export type ExploreMapState = {
	focusedBranchId: string | null;
	center: { lat: number; lng: number } | null;
	zoom: number | null;
	listScrollTop: number;
	isFullscreen: boolean;
};

type MapStatus = 'idle' | 'loading' | 'ready' | 'error';

type BranchPoint = ExploreMapBranch & { latitude: number; longitude: number };

type ExploreMapViewProps = {
	branches: ExploreMapBranch[];
	initialState?: ExploreMapState | null;
	onOpenBranch?: (
		branchId: string,
		state: ExploreMapState
	) => void | Promise<void>;
};

const FULLSCREEN_HISTORY_STATE_KEY = '__exploreMapFullscreen';

const toNumber = (value: unknown): number | null => {
	if (typeof value === 'number' && Number.isFinite(value)) return value;
	if (typeof value === 'string' && value.trim() !== '') {
		const parsed = Number(value);
		if (Number.isFinite(parsed)) return parsed;
	}
	return null;
};

const normalizeBranchId = (value: unknown): string | null => {
	if (typeof value === 'string' && value.trim() !== '') return value.trim();
	if (typeof value === 'number' && Number.isFinite(value)) return String(value);
	return null;
};

const normalizeMapState = (
	state: ExploreMapState | null | undefined
): ExploreMapState | null => {
	if (!state) return null;
	return {
		...state,
		focusedBranchId: normalizeBranchId(state.focusedBranchId),
	};
};

export default function ExploreMapView({
	branches,
	initialState,
	onOpenBranch,
}: ExploreMapViewProps) {
	const t = useTranslations('Explore');
	const { closeDrawer } = useDrawer();
	const apiKey = env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY;
	const safeInitialState = normalizeMapState(initialState);

	const mapRef = useRef<any>(null);
	const mapsRef = useRef<any>(null);
	const mapContainerRef = useRef<HTMLDivElement | null>(null);
	const listContainerRef = useRef<HTMLDivElement | null>(null);
	const branchItemRefs = useRef<Map<string, HTMLDivElement>>(new Map());
	const markersRef = useRef<any[]>([]);
	const markerByIdRef = useRef<Map<string, any>>(new Map());
	const userMarkerRef = useRef<any>(null);
	const initialStateRef = useRef<ExploreMapState | null>(safeInitialState);
	const mapRestoreAppliedRef = useRef(false);
	const listRestoreAppliedRef = useRef(false);
	const isMapFullscreenRef = useRef(Boolean(safeInitialState?.isFullscreen));
	const fullscreenHistoryEntryIdRef = useRef<string | null>(null);
	const openBranchTimerRef = useRef<number | null>(null);

	const [mapStatus, setMapStatus] = useState<MapStatus>('idle');
	const [focusedBranchId, setFocusedBranchId] = useState<string | null>(
		safeInitialState?.focusedBranchId ?? null
	);
	const [userLocation, setUserLocation] = useState<{ lat: number; lng: number } | null>(() => {
		const persisted = getLastLocationSync();
		if (!persisted) return null;
		return { lat: persisted.latitude, lng: persisted.longitude };
	});
	const [isLocatingUser, setIsLocatingUser] = useState(false);
	const [isMapFullscreen, setIsMapFullscreen] = useState<boolean>(
		Boolean(safeInitialState?.isFullscreen)
	);
	const [openingBranchId, setOpeningBranchId] = useState<string | null>(null);
	const userLocationRef = useRef<{ lat: number; lng: number } | null>(userLocation);

	const branchPoints = useMemo<BranchPoint[]>(
		() =>
			(branches ?? [])
				.map((branch) => {
					const branchId = normalizeBranchId(branch.id);
					if (!branchId) return null;
					const lat = toNumber(branch.latitude);
					const lng = toNumber(branch.longitude);
					if (lat == null || lng == null) return null;
					return {
						...branch,
						id: branchId,
						latitude: lat,
						longitude: lng,
					};
				})
				.filter(Boolean) as BranchPoint[],
		[branches]
	);

	const clearMarkers = useCallback(() => {
		for (const marker of markersRef.current) {
			marker.setMap(null);
		}
		markersRef.current = [];
		markerByIdRef.current.clear();
	}, []);

	const clearUserMarker = useCallback(() => {
		if (!userMarkerRef.current) return;
		userMarkerRef.current.setMap(null);
		userMarkerRef.current = null;
	}, []);

	const placeUserMarker = useCallback(
		(
			mapInstance?: any,
			locationOverride?: { lat: number; lng: number } | null
		) => {
			const maps = mapsRef.current;
			const map = mapInstance ?? mapRef.current;
			const location = locationOverride ?? userLocationRef.current;

			if (!maps || !map) return;

			if (!location) {
				if (userMarkerRef.current) {
					userMarkerRef.current.setMap(null);
				}
				return;
			}

			const userIcon = {
				path: maps.SymbolPath.CIRCLE,
				scale: 7,
				fillColor: '#1d4ed8',
				fillOpacity: 1,
				strokeColor: '#ffffff',
				strokeWeight: 2,
			};

			if (!userMarkerRef.current) {
				userMarkerRef.current = new maps.Marker({
					map,
					position: location,
					title: t('Map.MyLocation'),
					zIndex: 1000,
					icon: userIcon,
				});
				return;
			}

			userMarkerRef.current.setMap(map);
			userMarkerRef.current.setPosition(location);
			userMarkerRef.current.setTitle?.(t('Map.MyLocation'));
			userMarkerRef.current.setIcon(userIcon);
		},
		[t]
	);

	const resolveUserLocation = useCallback(
		async (forceRefresh = false) => {
			setIsLocatingUser(true);
			try {
				const location = await getCachedLocation(
					forceRefresh,
					forceRefresh ? 0 : 20_000,
					150
				);
				const normalized = { lat: location.latitude, lng: location.longitude };
				setUserLocation(normalized);
				placeUserMarker(undefined, normalized);
				return normalized;
			} catch {
				return null;
			} finally {
				setIsLocatingUser(false);
			}
		},
		[placeUserMarker]
	);

	const handleCenterToUserLocation = useCallback(async () => {
		const map = mapRef.current;
		if (!map) return;

		const location = userLocationRef.current ?? (await resolveUserLocation(true));
		if (!location) return;

		map.panTo(location);
		const currentZoom = map.getZoom?.() ?? 12;
		if (currentZoom < 15) map.setZoom(15);
	}, [resolveUserLocation]);

	const clearOpenBranchTimer = useCallback(() => {
		if (openBranchTimerRef.current != null) {
			window.clearTimeout(openBranchTimerRef.current);
			openBranchTimerRef.current = null;
		}
	}, []);

	const pushFullscreenHistoryState = useCallback(() => {
		if (typeof window === 'undefined') return;
		if (fullscreenHistoryEntryIdRef.current) return;

		const entryId = `${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
		const currentState =
			window.history.state && typeof window.history.state === 'object'
				? window.history.state
				: {};

		window.history.pushState(
			{
				...currentState,
				[FULLSCREEN_HISTORY_STATE_KEY]: entryId,
			},
			'',
			`${window.location.pathname}${window.location.search}${window.location.hash}`
		);
		fullscreenHistoryEntryIdRef.current = entryId;
	}, []);

	const exitMapFullscreen = useCallback(() => {
		if (typeof window === 'undefined') {
			setIsMapFullscreen(false);
			return;
		}

		if (fullscreenHistoryEntryIdRef.current) {
			window.history.back();
			return;
		}

		setIsMapFullscreen(false);
	}, []);

	const toggleMapFullscreen = useCallback(() => {
		if (isMapFullscreenRef.current) {
			exitMapFullscreen();
			return;
		}
		setIsMapFullscreen(true);
	}, [exitMapFullscreen]);

	const scrollBranchIntoView = useCallback(
		(branchId: string, behavior: ScrollBehavior = 'smooth'): boolean => {
			const container = listContainerRef.current;
			const item = branchItemRefs.current.get(branchId);
			if (!container || !item) return false;

			const containerRect = container.getBoundingClientRect();
			const itemRect = item.getBoundingClientRect();
			const containerHeight = container.clientHeight;
			if (containerHeight <= 0) return false;

			// Keep selected branch near center so marker click feedback is obvious.
			const nextTopUnclamped =
				container.scrollTop +
				(itemRect.top - containerRect.top) -
				(containerHeight - itemRect.height) / 2;
			const maxTop = Math.max(container.scrollHeight - containerHeight, 0);
			const nextTop = Math.min(Math.max(nextTopUnclamped, 0), maxTop);

			container.scrollTo({ top: nextTop, behavior });
			item.focus({ preventScroll: true });
			return true;
		},
		[]
	);

	const ensureBranchInView = useCallback(
		(branchId: string, behavior: ScrollBehavior = 'smooth') => {
			let attempts = 0;
			const maxAttempts = 5;

			const run = () => {
				const didScroll = scrollBranchIntoView(
					branchId,
					attempts === 0 ? behavior : 'auto'
				);
				attempts += 1;
				if (attempts >= maxAttempts) return;

				// Retry while refs/layout settle, and do a couple of settle passes after success.
				if (!didScroll || attempts <= 2) {
					window.setTimeout(() => {
						window.requestAnimationFrame(run);
					}, 45);
				}
			};

			run();
		},
		[scrollBranchIntoView]
	);

	const handleFocusBranch = useCallback(
		(
			branchId: string,
			options?: { scrollToList?: boolean; scrollBehavior?: ScrollBehavior }
		) => {
			setFocusedBranchId(branchId);

			const map = mapRef.current;
			const marker = markerByIdRef.current.get(branchId);
			if (map && marker) {
				map.panTo(marker.getPosition());
				const currentZoom = map.getZoom() ?? 12;
				if (currentZoom < 14) map.setZoom(14);
			}

			if (options?.scrollToList) {
				ensureBranchInView(branchId, options.scrollBehavior ?? 'smooth');
			}
		},
		[ensureBranchInView]
	);

	const getSnapshot = useCallback((): ExploreMapState => {
		const map = mapRef.current;
		const center = map?.getCenter?.();
		const lat = center?.lat?.();
		const lng = center?.lng?.();
		const zoom = map?.getZoom?.();

		return {
			focusedBranchId,
			center:
				typeof lat === 'number' && typeof lng === 'number' ? { lat, lng } : null,
			zoom: typeof zoom === 'number' ? zoom : null,
			listScrollTop: listContainerRef.current?.scrollTop ?? 0,
			isFullscreen: isMapFullscreen,
		};
	}, [focusedBranchId, isMapFullscreen]);

	const handleOpenBranch = useCallback(
		(branchId: string) => {
			if (!onOpenBranch || openingBranchId) return;
			clearOpenBranchTimer();
			setOpeningBranchId(branchId);
			try {
				const maybePromise = onOpenBranch(branchId, getSnapshot());
				if (
					maybePromise &&
					typeof (maybePromise as Promise<void>).then === 'function'
				) {
					void (maybePromise as Promise<void>).finally(() => {
						setOpeningBranchId((current) =>
							current === branchId ? null : current
						);
					});
					return;
				}

				// router.push is sync in App Router; keep loading visible while transition starts.
				openBranchTimerRef.current = window.setTimeout(() => {
					setOpeningBranchId((current) =>
						current === branchId ? null : current
					);
				}, 8000);
			} catch {
				setOpeningBranchId(null);
			}
		},
		[clearOpenBranchTimer, getSnapshot, onOpenBranch, openingBranchId]
	);

	const initMap = useCallback(async () => {
		if (!apiKey || !mapContainerRef.current || branchPoints.length === 0) return;
		setMapStatus('loading');

		try {
			const maps = await loadGoogleMaps(apiKey);
			mapsRef.current = maps;
			if (!mapContainerRef.current) return;

			if (!mapRef.current) {
				mapRef.current = new maps.Map(mapContainerRef.current, {
					center: {
						lat: branchPoints[0].latitude,
						lng: branchPoints[0].longitude,
					},
					zoom: 12,
					disableDefaultUI: true,
					mapTypeControl: false,
					streetViewControl: false,
					fullscreenControl: false,
					keyboardShortcuts: false,
					gestureHandling: 'greedy',
				});
			}

			const map = mapRef.current;
			clearMarkers();

			const bounds = new maps.LatLngBounds();
			for (const branch of branchPoints) {
				const marker = new maps.Marker({
					map,
					position: { lat: branch.latitude, lng: branch.longitude },
					title: branch.title || branch.address || branch.id,
				});
				marker.addListener('click', () => {
					handleFocusBranch(branch.id, { scrollToList: true });
				});
				markersRef.current.push(marker);
				markerByIdRef.current.set(branch.id, marker);
				bounds.extend(marker.getPosition());
			}

			const restored = initialStateRef.current;
			if (!mapRestoreAppliedRef.current && restored) {
				if (restored.center) {
					map.setCenter({
						lat: restored.center.lat,
						lng: restored.center.lng,
					});
				}
				if (typeof restored.zoom === 'number') {
					map.setZoom(restored.zoom);
				}
				if (restored.focusedBranchId) {
					handleFocusBranch(restored.focusedBranchId, {
						scrollToList: true,
						scrollBehavior: 'auto',
					});
				}
				mapRestoreAppliedRef.current = true;
			} else if (branchPoints.length === 1) {
				map.setCenter({
					lat: branchPoints[0].latitude,
					lng: branchPoints[0].longitude,
				});
				map.setZoom(14);
			} else {
				map.fitBounds(bounds, 70);
			}

			placeUserMarker(map);
			setMapStatus('ready');
		} catch {
			setMapStatus('error');
		}
	}, [apiKey, branchPoints, clearMarkers, handleFocusBranch, placeUserMarker]);

	useEffect(() => {
		if (!apiKey || branchPoints.length === 0) return;
		void initMap();
	}, [apiKey, branchPoints.length, initMap]);

	useEffect(() => {
		userLocationRef.current = userLocation;
		placeUserMarker(undefined, userLocation);
	}, [placeUserMarker, userLocation]);

	useEffect(() => {
		void resolveUserLocation(false);
	}, [resolveUserLocation]);

	useEffect(() => {
		if (!focusedBranchId || isMapFullscreen) return;
		ensureBranchInView(focusedBranchId, 'auto');
	}, [focusedBranchId, isMapFullscreen, ensureBranchInView]);

	useEffect(() => {
		if (listRestoreAppliedRef.current) return;
		const restored = initialStateRef.current;
		if (!restored) return;

		if (
			typeof restored.listScrollTop === 'number' &&
			listContainerRef.current &&
			restored.listScrollTop > 0
		) {
			listContainerRef.current.scrollTop = restored.listScrollTop;
		}
		listRestoreAppliedRef.current = true;
	}, []);

	useEffect(() => {
		isMapFullscreenRef.current = isMapFullscreen;
		if (isMapFullscreen) {
			pushFullscreenHistoryState();
		}
	}, [isMapFullscreen, pushFullscreenHistoryState]);

	useEffect(() => {
		if (typeof window === 'undefined') return;

		const handlePopState = () => {
			if (!isMapFullscreenRef.current) return;
			fullscreenHistoryEntryIdRef.current = null;
			setIsMapFullscreen(false);
		};

		window.addEventListener('popstate', handlePopState);
		return () => window.removeEventListener('popstate', handlePopState);
	}, []);

	useEffect(() => {
		const map = mapRef.current;
		if (!map) return;
		const center = map.getCenter?.();
		const lat = center?.lat?.();
		const lng = center?.lng?.();

		window.setTimeout(() => {
			const maps = (window as any).google?.maps;
			if (!maps?.event) return;
			maps.event.trigger(map, 'resize');
			if (typeof lat === 'number' && typeof lng === 'number') {
				map.setCenter({ lat, lng });
			}
		}, 30);
	}, [isMapFullscreen]);

	useEffect(() => {
		return () => {
			clearMarkers();
			clearUserMarker();
			clearOpenBranchTimer();
		};
	}, [clearMarkers, clearOpenBranchTimer, clearUserMarker]);

	return (
		<div className="flex h-full flex-col bg-white px-4 pb-4">
			<div className="relative mb-5 flex items-center">
				<h2 className="flex-1 text-center font-balsamiqSans text-2xl text-textGray">
					{t('Map.Title')}
				</h2>
				<CloseDrawerButton
					onClick={() => {
						if (isMapFullscreenRef.current) {
							exitMapFullscreen();
						}
						closeDrawer();
					}}
				/>
			</div>

			{!apiKey ? (
				<div className="rounded-2xl border border-amber-100 bg-amber-50 px-4 py-5 text-amber-800">
					<div className="flex items-start gap-2">
						<PiWarningCircleDuotone className="mt-0.5 size-5 shrink-0 text-inherit" />
						<div className="space-y-1">
							<p className="text-sm font-semibold">{t('Map.MissingKeyTitle')}</p>
							<p className="text-xs">{t('Map.MissingKeyDescription')}</p>
						</div>
					</div>
				</div>
			) : branchPoints.length === 0 ? (
				<div className="rounded-2xl border border-gray-100 bg-gray-50 px-4 py-5 text-gray-600">
					<p className="text-sm">{t('Map.NoBranches')}</p>
				</div>
			) : (
				<>
					<div
						className={cn(
							'relative overflow-hidden border border-gray-100 bg-gray-100',
							isMapFullscreen
								? 'fixed inset-0 z-[10001] h-screen rounded-none border-none'
								: 'h-[48vh] rounded-2xl'
						)}
					>
						<div ref={mapContainerRef} className="h-full w-full" />

						<div className="absolute bottom-3 right-3 z-[10002] flex flex-col gap-2">
							<Button
								size="sm"
								variant="flat"
								onClick={() => void handleCenterToUserLocation()}
								isLoading={isLocatingUser}
								title={t('Map.CenterToMyLocation')}
								aria-label={t('Map.CenterToMyLocation')}
								className="rounded-full bg-white/95 px-3 py-1.5 text-textGray shadow-sm"
							>
								<PiNavigationArrowDuotone className="size-4" />
							</Button>
							<Button
								size="sm"
								variant="flat"
								onClick={toggleMapFullscreen}
								className="rounded-full bg-white/95 px-3 py-1.5 text-textGray shadow-sm"
							>
								{isMapFullscreen ? (
									<PiArrowsInSimpleDuotone className="size-4" />
								) : (
									<PiArrowsOutSimpleDuotone className="size-4" />
								)}
							</Button>
						</div>

						{mapStatus === 'loading' && (
							<div className="absolute inset-0 grid place-content-center bg-white/75 text-sm font-medium text-textGray">
								{t('Map.Loading')}
							</div>
						)}

						{mapStatus === 'error' && (
							<div className="absolute inset-0 flex flex-col items-center justify-center gap-3 bg-white/90 px-4 text-center">
								<p className="text-sm text-red-600">{t('Map.LoadError')}</p>
								<Button
									size="sm"
									variant="outline"
									onClick={() => void initMap()}
									className="rounded-xl bg-white"
								>
									{t('Map.Retry')}
								</Button>
							</div>
						)}
					</div>

					<div
						className={cn(
							'mt-4 text-xs font-medium text-textGray',
							isMapFullscreen && 'opacity-0'
						)}
					>
						{t('Map.ResultsCount', { count: branchPoints.length })}
					</div>

					<div
						ref={listContainerRef}
						className={cn(
							'mt-2 flex-1 space-y-2 overflow-y-auto pb-4',
							isMapFullscreen && 'pointer-events-none opacity-0'
						)}
					>
						{branchPoints.map((branch) => (
							<div
								key={branch.id}
								ref={(node) => {
									if (node) {
										branchItemRefs.current.set(branch.id, node);
										return;
									}
									branchItemRefs.current.delete(branch.id);
								}}
								onClick={() => handleFocusBranch(branch.id)}
								onKeyDown={(e) => {
									if (e.key === 'Enter' || e.key === ' ') {
										e.preventDefault();
										handleFocusBranch(branch.id);
									}
								}}
								role="button"
								tabIndex={0}
								className={cn(
									'flex w-full items-start justify-between gap-3 rounded-xl border px-3 py-2 text-left transition',
									focusedBranchId === branch.id
										? 'border-mainPurple bg-mainPurple/5'
										: 'border-gray-100 bg-white'
								)}
							>
								<div className="min-w-0">
									<div className="flex items-center gap-1.5 text-sm font-semibold text-textGray">
										<PiMapPinDuotone className="size-4 shrink-0 text-mainPurple" />
										<span className="truncate">{branch.title || '-'}</span>
									</div>
									{branch.address && (
										<p className="mt-1 line-clamp-2 text-xs text-gray-500">
											{branch.address}
										</p>
									)}
								</div>
								<div className="shrink-0 space-y-2">
									<div className="rounded-lg bg-indigo-50 px-2 py-1 text-[11px] text-indigo-700">
										<div className="flex items-center gap-1">
											<PiNavigationArrowDuotone className="size-3" />
											<span>{formatDistanceKm(branch.distance) ?? '—'}</span>
										</div>
									</div>
									<Button
										size="sm"
										variant="flat"
										className="h-7 rounded-lg bg-mainPurple px-2 text-[11px] text-white"
										isLoading={openingBranchId === branch.id}
										disabled={Boolean(openingBranchId)}
										onClick={(e) => {
											e.stopPropagation();
											handleOpenBranch(branch.id);
										}}
									>
										{openingBranchId === branch.id
											? t('Map.GoToBranchLoading')
											: t('Map.GoToBranch')}
									</Button>
								</div>
							</div>
						))}
					</div>
				</>
			)}
		</div>
	);
}
