'use client';

import React, { useEffect, useState, useRef, useCallback } from 'react';
import {
	ActionIcon,
	Badge,
	Button,
	Empty,
	EmptyProductBoxIcon,
	Input,
} from 'rizzui';
import {
	PiMagnifyingGlass,
	PiMapPinAreaDuotone,
	PiSlidersLight,
	PiX,
	PiXBold,
} from 'react-icons/pi';
import { ArrowPathIcon } from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';
import { debounce } from 'lodash';
import ClassCard from '@/components/ui/widgets/class-card';
import BranchCard from '@/components/ui/widgets/branch-card';
import DrawerButton from '@/components/ui/buttons/drawer-button';
import ExploreFilterView from '@app/shared/views/explore-filter-view';
import { getAllCategories, exploreClasses } from '@/services/api';
import { Link, useRouter } from '@/i18n/routing';
import { routes } from '@/config/routes';
import cn from '@/utils/class-names';
import {
	ListGridSkeleton,
	InlineLoaderSkeleton,
} from '@/components/ui/skeletons';
import { useSearchParams } from 'next/navigation';
import ExploreCategoriesView from '../views/explore-categories-view';
import ExploreMapView, {
	type ExploreMapBranch,
	type ExploreMapState,
} from '../views/explore-map-view';
import { FilterState } from '@/types';
import { useTranslations } from 'next-intl';
import { useDrawer } from '@/app/shared/drawer-views/use-drawer';

const EXPLORE_MAP_RETURN_KEY = 'explore:map:return';
const EXPLORE_MAP_STATE_KEY = 'explore:map:state';

const parseJson = <T,>(raw: string | null): T | null => {
	if (!raw) return null;
	try {
		return JSON.parse(raw) as T;
	} catch {
		return null;
	}
};

const normalizeId = (value: unknown): string | null => {
	if (typeof value === 'string') {
		const trimmed = value.trim();
		return trimmed.length > 0 ? trimmed : null;
	}
	if (typeof value === 'number' && Number.isFinite(value)) {
		return String(value);
	}
	return null;
};

const mergeUniqueById = <T extends { id?: unknown }>(
	prev: T[],
	next: T[],
	append: boolean
): T[] => {
	const source = append ? [...prev, ...next] : [...next];
	const byId = new Map<string, T>();

	for (const item of source) {
		const id = normalizeId(item?.id);
		if (!id) continue;
		byId.set(id, item);
	}

	return Array.from(byId.values());
};

export default function ExplorePageContent() {
	const t = useTranslations('Explore');
	const tDrawers = useTranslations('Drawers.Explore');

	const [activeTab, setActiveTab] = useState<'classes' | 'centers'>('classes');

	const [urlReady, setUrlReady] = useState(false);
	const [searchTerm, setSearchTerm] = useState('');
	const [isLoading, setIsLoading] = useState(true);
	const [loadingMore, setLoadingMore] = useState(false);
	const [catsLoading, setCatsLoading] = useState(false);
	const [error, setError] = useState<string | null>(null);
	const [categories, setCategories] = useState<any[]>([]);

	const [selectedCategory, setSelectedCategory] = useState<string | null>(null);

	const [classesData, setClassesData] = useState<any[]>([]);
	const [branchesData, setBranchesData] = useState<any[]>([]);
	const [mapBranches, setMapBranches] = useState<ExploreMapBranch[]>([]);
	const [classesPage, setClassesPage] = useState(1);
	const [branchesPage, setBranchesPage] = useState(1);
	const [classesTotalPages, setClassesTotalPages] = useState(1);
	const [branchesTotalPages, setBranchesTotalPages] = useState(1);
	const [hasMoreClasses, setHasMoreClasses] = useState(true);
	const [hasMoreBranches, setHasMoreBranches] = useState(true);
	const [sortOption, _setSortOption] = useState<string | null>(null);

	const [selectedBranchId, setSelectedBranchId] = useState<string | null>(null);
	const [selectedBranchName, setSelectedBranchName] = useState<string | null>(
		null
	);

	const [selectedFilters, setSelectedFilters] = useState<FilterState>({
		fromDate: null,
		toDate: null,
		age: null,
		gender: null,
		minPrice: null,
		maxPrice: null,
	});

	const [appliedFilters, setAppliedFilters] = useState<FilterState>({
		fromDate: null,
		toDate: null,
		age: null,
		gender: null,
		minPrice: null,
		maxPrice: null,
	});

	const router = useRouter();
	const searchParams = useSearchParams();
	const { openDrawer } = useDrawer();

	const ignoreUrlCategoryRef = useRef(false);
	const searchInputRef = useRef<HTMLInputElement>(null);
	const bootstrappedRef = useRef(false);
	const mapRestoreHandledRef = useRef(false);

	// NEW: sentinel + observer refs
	const loadMoreRef = useRef<HTMLDivElement | null>(null);
	const ioRef = useRef<IntersectionObserver | null>(null);

	const appliedFiltersCount = (() => {
		let c = 0;
		if (appliedFilters.gender) c += 1; // 1 for any gender
		if (appliedFilters.age !== null) c += 1; // 1 for age
		if (appliedFilters.fromDate || appliedFilters.toDate) c += 1; // 1 for date range (any side set)
		if (appliedFilters.minPrice !== null || appliedFilters.maxPrice !== null)
			c += 1; // 1 for price range
		return c + Number(!!selectedCategory) + Number(!!selectedBranchId);
	})();

	// Read URL
	useEffect(() => {
		const cat =
			searchParams?.get('category') ?? searchParams?.get('category_id');
		setSelectedCategory((prev) => (cat !== prev ? cat || null : prev));

		const tabParam = searchParams?.get('tab');
		if (tabParam === 'classes' || tabParam === 'centers')
			setActiveTab(tabParam);

		const branch = searchParams?.get('branch_id');
		const branchName = searchParams?.get('branch_name');
		setSelectedBranchId(branch);
		setSelectedBranchName(branchName ?? null);

		setUrlReady(true);
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [searchParams]);

	const handleCategorySelect = (categoryId: string) => {
		setSelectedCategory(categoryId);
		const params = new URLSearchParams(searchParams?.toString() ?? '');
		params.set('category', categoryId);
		router.replace(`${routes.explore}?${params.toString()}`);
	};

	const handleRemoveCategory = () => {
		ignoreUrlCategoryRef.current = true;
		setSelectedCategory(null);
		const params = new URLSearchParams(searchParams?.toString() ?? '');
		params.delete('category');
		params.delete('category_id');
		router.replace(`${routes.explore}?${params.toString()}`);
		resetAndFetchData();
	};

	useEffect(() => {
		const fetchCategories = async () => {
			try {
				setCatsLoading(true);
				const response = await getAllCategories();
				setCategories(response.data || []);
			} catch {
				toast.error(t('FailedToLoadCategories'));
			} finally {
				setCatsLoading(false);
			}
		};
		fetchCategories();
	}, [t]);

	useEffect(() => {
		if (!urlReady) return;
		if (!bootstrappedRef.current) {
			bootstrappedRef.current = true;
			fetchData(1, false);
		}
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [urlReady]);

	useEffect(() => {
		if (!urlReady) return;
		resetAndFetchData();
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [
		urlReady,
		activeTab,
		searchTerm,
		selectedCategory,
		appliedFilters.fromDate,
		appliedFilters.toDate,
		appliedFilters.age,
		appliedFilters.gender,
		appliedFilters.minPrice,
		appliedFilters.maxPrice,
		sortOption,
		selectedBranchId,
	]);

	const debouncedSearch = useCallback(
		debounce((value: string) => setSearchTerm(value), 500),
		[]
	);
	useEffect(() => () => debouncedSearch.cancel(), [debouncedSearch]);

	const clearApplied = (target: 'gender' | 'age' | 'date' | 'price') => {
		setAppliedFilters((prev) => {
			const next = { ...prev };
			if (target === 'gender') next.gender = null;
			if (target === 'age') next.age = null;
			if (target === 'date') {
				next.fromDate = null;
				next.toDate = null;
			}
			if (target === 'price') {
				next.minPrice = null;
				next.maxPrice = null;
			}
			return next;
		});
		setSelectedFilters((prev) => {
			const next = { ...prev };
			if (target === 'gender') next.gender = null;
			if (target === 'age') next.age = null;
			if (target === 'date') {
				next.fromDate = null;
				next.toDate = null;
			}
			if (target === 'price') {
				next.minPrice = null;
				next.maxPrice = null;
			}
			return next;
		});
	};

	const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
		debouncedSearch(e.target.value);
	};

	const handleClearSearch = () => {
		setSearchTerm('');
		if (searchInputRef.current) searchInputRef.current.value = '';
	};

	const handleTabChange = (tab: 'classes' | 'centers') => {
		setActiveTab(tab);
		const params = new URLSearchParams(searchParams?.toString() ?? '');
		if (tab === 'centers') {
			params.delete('branch_id');
			params.delete('branch_name');
			setSelectedBranchName(null);
			setSelectedBranchId(null);
		}
		router.replace(`${routes.explore}?${params.toString()}`);
		if (tab === 'classes' && classesData.length === 0) fetchData(1, false);
		if (tab === 'centers' && branchesData.length === 0) fetchData(1, false);
	};

	const resetAndFetchData = () => {
		if (activeTab === 'classes') {
			setClassesPage(1);
			setClassesData([]);
			setHasMoreClasses(true);
		} else {
			setBranchesPage(1);
			setBranchesData([]);
			setHasMoreBranches(true);
		}
		fetchData(1, false);
	};

	// ---------- Data fetching ----------
	const fetchData = async (pageNum = 1, append = false) => {
		if (pageNum === 1) setIsLoading(true);
		else setLoadingMore(true);

		setError(null);

		try {
			const params: Record<string, string | number> = {
				page: pageNum,
				limit: 10,
			};
			let effectiveCategory: string | null = null;
			if (selectedCategory !== null) {
				effectiveCategory = selectedCategory;
			} else if (!ignoreUrlCategoryRef.current) {
				const urlCat =
					searchParams?.get('category') ?? searchParams?.get('category_id');
				effectiveCategory = urlCat ?? null;
			}

			if (searchTerm) params.search = searchTerm;
			if (effectiveCategory) params.category_id = String(effectiveCategory);

			if (appliedFilters.fromDate) params.from_date = appliedFilters.fromDate!;
			if (appliedFilters.toDate) params.to_date = appliedFilters.toDate!;
			if (appliedFilters.age !== null) params.age = appliedFilters.age!;
			if (appliedFilters.gender) params.class_gender = appliedFilters.gender!;
			if (appliedFilters.minPrice !== null)
				params.min_price = appliedFilters.minPrice!;
			if (appliedFilters.maxPrice !== null)
				params.max_price = appliedFilters.maxPrice!;
			if (sortOption) params.sort_by = sortOption;

			if (activeTab === 'classes' && selectedBranchId) {
				const branchId =
					selectedBranchId ?? searchParams?.get('branch_id') ?? null;
				if (branchId) params.branch_id = branchId;
			}

			const response = await exploreClasses(params);
			const rawBranchResults = Array.isArray(response?.data?.branches?.data)
				? response.data.branches.data
				: [];
			const branchResults: any[] = [];
			for (const item of rawBranchResults) {
				const id = normalizeId(item?.id);
				if (!id) continue;
				branchResults.push({ ...item, id });
			}

			if (activeTab === 'classes') {
				const rawClasses = Array.isArray(response?.data?.classes?.data)
					? response.data.classes.data
					: [];
				const classes: any[] = [];
				for (const item of rawClasses) {
					const id = normalizeId(item?.id);
					if (!id) continue;
					classes.push({ ...item, id });
				}
				setClassesData((prev) => mergeUniqueById(prev, classes, append));
				const pages = response?.data?.classes?.pages ?? 1;
				setClassesTotalPages(pages);
				setHasMoreClasses(pageNum < pages);
				setClassesPage(pageNum);
				if (pageNum === 1 || !append) {
					setMapBranches(mergeUniqueById([], branchResults, false));
				}
			} else {
				setBranchesData((prev) => mergeUniqueById(prev, branchResults, append));
				const pages = response?.data?.branches?.pages ?? 1;
				setBranchesTotalPages(pages);
				setHasMoreBranches(pageNum < pages);
				setBranchesPage(pageNum);
				setMapBranches((prev) => mergeUniqueById(prev, branchResults, append));
			}
		} catch (err: any) {
			setError(err.message || 'Failed to load data');
			toast.error(
				t(
					activeTab === 'classes'
						? 'FailedToLoadClasses'
						: 'FailedToLoadCenters'
				)
			);
		} finally {
			setIsLoading(false);
			setLoadingMore(false);
			ignoreUrlCategoryRef.current = false;
		}
	};

	// Helper: can we load more now?
	const canLoadMore = useCallback(() => {
		if (isLoading || loadingMore) return false;
		return activeTab === 'classes' ? hasMoreClasses : hasMoreBranches;
	}, [activeTab, isLoading, loadingMore, hasMoreClasses, hasMoreBranches]);

	const loadMore = useCallback(() => {
		if (!canLoadMore()) return;

		if (activeTab === 'classes') {
			const nextPage = classesPage + 1;
			if (nextPage <= classesTotalPages) {
				// set page & fetch append
				setClassesPage(nextPage);
				fetchData(nextPage, true);
			}
		} else {
			const nextPage = branchesPage + 1;
			if (nextPage <= branchesTotalPages) {
				setBranchesPage(nextPage);
				fetchData(nextPage, true);
			}
		}
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [
		activeTab,
		classesPage,
		classesTotalPages,
		branchesPage,
		branchesTotalPages,
		canLoadMore,
	]);

	// ---------- IntersectionObserver sentinel (robust infinite scroll) ----------
	useEffect(() => {
		if (!loadMoreRef.current) return;

		// Clear any previous observer (avoid duplicate triggers)
		if (ioRef.current) {
			ioRef.current.disconnect();
			ioRef.current = null;
		}

		const observer = new IntersectionObserver(
			(entries) => {
				const entry = entries[0];
				if (!entry?.isIntersecting) return;
				// Only trigger when we truly can load more
				if (canLoadMore()) {
					loadMore();
				}
			},
			{
				root: null, // viewport
				rootMargin: '600px', // start preloading before the user hits bottom
				threshold: 0,
			}
		);

		observer.observe(loadMoreRef.current);
		ioRef.current = observer;

		return () => {
			observer.disconnect();
			ioRef.current = null;
		};
	}, [
		canLoadMore,
		loadMore,
		activeTab,
		classesData.length,
		branchesData.length,
	]);

	// ---------- Window scroll fallback (kept, but guarded) ----------
	useEffect(() => {
		const onScroll = () => {
			if (!canLoadMore()) return;
			const nearBottom =
				window.innerHeight + window.scrollY >=
				document.documentElement.scrollHeight - 200;
			if (nearBottom) {
				loadMore();
			}
		};
		window.addEventListener('scroll', onScroll, { passive: true });
		return () => window.removeEventListener('scroll', onScroll);
	}, [canLoadMore, loadMore]);

	// Optional container scroll handler (kept for compatibility)
	const handleScroll = (e: React.UIEvent<HTMLDivElement>) => {
		const el = e.currentTarget;
		const atBottom = el.scrollHeight - el.scrollTop - el.clientHeight < 8;
		if (atBottom && canLoadMore()) {
			loadMore();
		}
	};

	const neutralFilters: FilterState = {
		fromDate: null,
		toDate: null,
		age: null,
		gender: null,
		minPrice: null,
		maxPrice: null,
	};

	const filterView = (
		<ExploreFilterView
			initialFilters={selectedFilters}
			onApply={(filters: FilterState) => {
				setAppliedFilters(filters);
				setSelectedFilters(filters);
			}}
			onSelect={(filters: FilterState) => setSelectedFilters(filters)}
			onReset={() => {
				setSelectedFilters(neutralFilters);
				setAppliedFilters(neutralFilters);
			}}
		/>
	);

	const handleOpenBranchFromMap = useCallback(
		(branchId: string, state: ExploreMapState) => {
			if (typeof window !== 'undefined') {
				const currentUrl = `${window.location.pathname}${window.location.search}`;
				sessionStorage.setItem(
					EXPLORE_MAP_RETURN_KEY,
					JSON.stringify({
						url: currentUrl,
						ts: Date.now(),
					})
				);
				sessionStorage.setItem(EXPLORE_MAP_STATE_KEY, JSON.stringify(state));
			}
			router.push(routes.branchDetails(branchId));
		},
		[router]
	);

	const openMapDrawer = useCallback(
		(initialState?: ExploreMapState | null) => {
			openDrawer({
				view: (
					<ExploreMapView
						branches={mapBranches}
						initialState={initialState ?? undefined}
						onOpenBranch={handleOpenBranchFromMap}
					/>
				),
				placement: 'bottom',
				height: '92vh',
				containerClassName: 'max-w-full w-full md:max-w-[620px]',
			});
		},
		[openDrawer, mapBranches, handleOpenBranchFromMap]
	);

	useEffect(() => {
		if (mapRestoreHandledRef.current) return;
		if (!urlReady || isLoading || mapBranches.length === 0) return;
		if (typeof window === 'undefined') return;

		const returnMeta = parseJson<{ url?: string; ts?: number }>(
			sessionStorage.getItem(EXPLORE_MAP_RETURN_KEY)
		);
		if (!returnMeta) return;

		const currentUrl = `${window.location.pathname}${window.location.search}`;
		const isSameUrl = returnMeta.url === currentUrl;
		const isFresh =
			typeof returnMeta.ts === 'number' &&
			Date.now() - returnMeta.ts < 30 * 60 * 1000;

		sessionStorage.removeItem(EXPLORE_MAP_RETURN_KEY);
		mapRestoreHandledRef.current = true;

		if (!isSameUrl || !isFresh) {
			sessionStorage.removeItem(EXPLORE_MAP_STATE_KEY);
			return;
		}

		const restoredMapState = parseJson<ExploreMapState>(
			sessionStorage.getItem(EXPLORE_MAP_STATE_KEY)
		);
		sessionStorage.removeItem(EXPLORE_MAP_STATE_KEY);
		openMapDrawer(restoredMapState);
	}, [urlReady, isLoading, mapBranches.length, openMapDrawer]);

	return (
		<div className="flex min-h-screen flex-col bg-transparent" onScroll={handleScroll}>
				<div className="flex-1 px-4 pb-24 pt-8">
					<h1 className="app-page-title mb-4">
						{t('Title')}
					</h1>

				{/* Search + Filter row */}
				<div className="mb-4 flex items-center justify-between gap-2">
					<Input
						ref={searchInputRef}
						prefix={
							<PiMagnifyingGlass
								size={22}
								className="text-lightGray group-focus-within:text-primary"
							/>
						}
						suffix={
							searchTerm ? (
								<ActionIcon
									size="sm"
									variant="text"
									onClick={handleClearSearch}
									className="text-gray-500"
								>
									<PiX size={18} />
								</ActionIcon>
							) : null
						}
						type="text"
						inputMode="text"
						placeholder={t('SearchPlaceholder')}
						onChange={handleSearchChange}
						className="focus-within:ring-none w-full overflow-hidden rounded-2xl border-none bg-white/80 text-lg text-gray-700 outline-none ring-0 shadow-sm focus-within:outline-none focus:outline-none"
						inputClassName="group h-14 rounded-2xl border border-mainPurple/15 bg-white/90 outline-none ring-0"
						rounded="lg"
					/>

					<div className="relative">
						<DrawerButton
							modalView={filterView}
							placement="bottom"
							height="78vh"
							className="grid h-[52px] w-14 place-content-center rounded-2xl bg-mainPurple shadow-[0_8px_20px_rgba(166,82,199,0.32)]"
						>
							<PiSlidersLight size={28} className="text-white" />
						</DrawerButton>

						{appliedFiltersCount > 0 && (
							<Badge
								className="absolute -right-1 -top-1 border border-white/90 bg-white text-mainPurple ring-grayBg"
								enableOutlineRing
								variant="outline"
								size="sm"
							>
								{appliedFiltersCount}
							</Badge>
						)}
					</div>
				</div>

				{/* Applied filters chips */}
				{appliedFiltersCount > 0 && (
					<div className="mb-2 flex flex-wrap gap-2">
						{appliedFilters.gender && (
							<Badge
								variant="outline"
								className={cn(
									'flex items-center gap-1 bg-white/80 py-0.5 pl-2 pr-1',
									appliedFilters.gender === 'MALE'
										? 'border-indigo-300 text-indigo-700'
										: appliedFilters.gender === 'FEMALE'
											? 'border-pink-300 text-pink-600'
											: 'border-purple-300 text-mainPurple'
								)}
							>
								<>
									<span className="text-inherit">
										{appliedFilters.gender === 'MALE'
											? tDrawers('GenderBoys')
											: appliedFilters.gender === 'FEMALE'
												? tDrawers('GenderGirls')
												: tDrawers('GenderBoth')}
									</span>
								</>
								<ActionIcon
									size="sm"
									variant="text"
									onClick={() => clearApplied('gender')}
									className="h-5 w-5 p-0 text-inherit hover:bg-gray-100"
									aria-label={t('A11y.RemoveGender')}
								>
									<PiXBold size={12} />
								</ActionIcon>
							</Badge>
						)}

						{appliedFilters.age !== null && (
							<Badge
								variant="outline"
								className="flex items-center gap-1 border-green-700 bg-white/80 py-0.5 pl-2 pr-1 text-green-700"
							>
								{t('Chips.Age')}: {appliedFilters.age}
								<ActionIcon
									size="sm"
									variant="text"
									onClick={() => clearApplied('age')}
									className="h-5 w-5 p-0 text-green-700 hover:bg-gray-100"
									aria-label={t('A11y.RemoveAge')}
								>
									<PiXBold size={12} />
								</ActionIcon>
							</Badge>
						)}

						{(appliedFilters.fromDate || appliedFilters.toDate) && (
							<Badge
								variant="outline"
								className="flex items-center gap-1 border-indigo-500 bg-white/80 py-0.5 pl-2 pr-1 text-indigo-600"
							>
								{t('Chips.Date')}: {appliedFilters.fromDate || '—'} →{' '}
								{appliedFilters.toDate || '—'}
								<ActionIcon
									size="sm"
									variant="text"
									onClick={() => clearApplied('date')}
									className="h-5 w-5 p-0 text-indigo-600 hover:bg-gray-100"
									aria-label={t('A11y.RemoveDate')}
								>
									<PiXBold size={12} />
								</ActionIcon>
							</Badge>
						)}

						{(appliedFilters.minPrice !== null ||
							appliedFilters.maxPrice !== null) && (
							<Badge
								variant="outline"
								className="flex items-center gap-1 border-orange-300 bg-white/80 py-0.5 pl-2 pr-1 text-orange-500"
							>
								{t('Chips.Price')}: {appliedFilters.minPrice ?? 'min'} —{' '}
								{appliedFilters.maxPrice ?? 'max'}
								<ActionIcon
									size="sm"
									variant="text"
									onClick={() => clearApplied('price')}
									className="h-5 w-5 p-0 text-orange-500 hover:bg-gray-100"
									aria-label={t('A11y.RemovePrice')}
								>
									<PiXBold size={12} />
								</ActionIcon>
							</Badge>
						)}
					</div>
				)}

				{(selectedCategory || selectedBranchId || selectedBranchName) && (
					<div className="mt-1.5 flex flex-wrap gap-2">
						{selectedCategory && (
							<Badge
								key="category"
								variant="outline"
								className="flex items-center gap-1 bg-white/80 py-0.5 pl-2 pr-1"
							>
								{categories.find(
									(cat) => String(cat.id) === String(selectedCategory)
								)?.title || t('Chips.Category')}
								<ActionIcon
									size="sm"
									variant="text"
									onClick={handleRemoveCategory}
									className="h-5 w-5 p-0 text-mainPurple hover:bg-gray-100"
									aria-label={t('A11y.RemoveCategory')}
								>
									<PiXBold size={12} />
								</ActionIcon>
							</Badge>
						)}

						{(selectedBranchName || selectedBranchId) && (
							<Badge
								key="branch"
								variant="outline"
								className="flex items-center gap-1 bg-white/80 py-0.5 pl-2 pr-1"
							>
								<span className="text-primary">
									{selectedBranchName || t('Chips.Branch')}
								</span>
								<ActionIcon
									size="sm"
									variant="text"
									onClick={() => {
										setSelectedBranchId(null);
										setSelectedBranchName(null);
										const params = new URLSearchParams(
											searchParams?.toString() ?? ''
										);
										params.delete('branch_id');
										params.delete('branch_name');
										router.replace(`${routes.explore}?${params.toString()}`);
										resetAndFetchData();
									}}
									className="h-5 w-5 p-0 text-mainPurple hover:bg-gray-100"
									aria-label={t('A11y.RemoveBranch')}
								>
									<PiXBold size={12} />
								</ActionIcon>
							</Badge>
						)}
					</div>
				)}

				{/* Tabs */}
					<div className="my-3 flex items-center justify-between gap-2 rounded-2xl bg-white/70 p-1 shadow-sm">
						<Button
							variant="text"
							size="lg"
							className={`w-1/2 rounded-xl text-center font-bold text-textGray ${
								activeTab === 'classes'
									? 'bg-mainPurple text-white shadow-[0_8px_20px_rgba(166,82,199,0.32)] hover:text-white'
									: 'bg-white/80'
							}`}
							onClick={() => handleTabChange('classes')}
						>
						{t('Tabs.Classes')}
					</Button>
					<Button
							size="lg"
							variant="text"
							className={`w-1/2 rounded-xl text-center font-bold text-textGray ${
								activeTab === 'centers'
									? 'bg-mainPurple text-white shadow-[0_8px_20px_rgba(166,82,199,0.32)] hover:text-white'
									: 'bg-white/80'
							}`}
							onClick={() => handleTabChange('centers')}
						>
						{t('Tabs.Centers')}
					</Button>
				</div>

				{activeTab === 'classes' && (
					<div className="mb-6 flex items-center justify-between gap-4">
						<DrawerButton
							modalView={
								<ExploreCategoriesView
									categories={categories}
									isLoading={catsLoading}
									selectedCategory={selectedCategory}
									onPick={(id) => handleCategorySelect(id)}
									onClear={handleRemoveCategory}
								/>
							}
							placement="bottom"
							height="80vh"
							size="sm"
							className="flex w-fit items-center gap-1 whitespace-nowrap rounded-xl border border-mainPurple/15 bg-white text-mainPurple hover:bg-mainPurple/10 focus:border-mainPurple/30 focus:bg-mainPurple/10"
						>
							{t('Buttons.Categories')}
						</DrawerButton>
					</div>
				)}

				{/* Results */}
				<div>
					{isLoading ? (
						<ListGridSkeleton
							variant={activeTab === 'classes' ? 'classes' : 'centers'}
							count={3}
						/>
					) : error ? (
						<div className="flex flex-col items-center justify-center gap-4 py-10 text-center">
							<Empty
								text={t('Empty')}
								image={<ArrowPathIcon className="h-36 w-auto" />}
							/>
							<Button
								onClick={resetAndFetchData}
								className="size-10 rounded-full p-1"
								aria-label={t('Buttons.Retry')}
							>
								<ArrowPathIcon className="size-6" />
							</Button>
						</div>
					) : classesData?.length === 0 &&
					  branchesData?.length === 0 &&
					  !isLoading ? (
						<div className="flex flex-col items-center justify-center py-10 text-center">
							<Empty
								text={t('Empty')}
								image={
									<EmptyProductBoxIcon className="size-40 text-gray-700" />
								}
							/>
						</div>
					) : (
						<>
							<div className="grid grid-cols-1 gap-5 md:grid-cols-2">
								{activeTab === 'classes'
									? classesData.map((item) => (
											<Link href={routes.classDetails(item.id)} key={item.id}>
												<ClassCard
													key={item.id}
													classItem={item}
													showDescription
												/>
											</Link>
										))
									: branchesData.map((branch) => (
											<BranchCard
												key={branch.id}
												branch={branch}
												href={routes.branchDetails(branch.id)}
												variant="vertical"
												density="comfortable"
												showDescription
												showCategory
												showStatus
												showDistance
											/>
										))}
							</div>

							{loadingMore && (
								<InlineLoaderSkeleton
									variant={activeTab === 'classes' ? 'classes' : 'centers'}
								/>
							)}

							{/* SENTINEL: triggers IntersectionObserver when near viewport bottom */}
							<div ref={loadMoreRef} className="h-1 w-full" />
						</>
					)}
				</div>
			</div>

			<Button
				onClick={() => openMapDrawer()}
				className="fixed bottom-24 right-4 z-30 !w-auto gap-2 rounded-full bg-mainPurple px-4 py-3 shadow-[0_12px_24px_rgba(166,82,199,0.34)]"
			>
				<PiMapPinAreaDuotone className="size-5 text-white" />
				<span className="text-sm font-semibold text-white">
					{t('Buttons.Map')}
				</span>
			</Button>
			</div>
		);
}
