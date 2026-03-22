'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { Link, useRouter } from '@/i18n/routing';
import {
	getBranchById,
	getBranchPhotos,
	getClasses,
	getImageUrl,
} from '@/services/api';
import { Badge, Button } from 'rizzui';
import {
	PiArrowLeft,
	PiNavigationArrowDuotone,
	PiMapPinAreaDuotone,
	PiMapTrifoldDuotone,
} from 'react-icons/pi';
import CheckNetwork from '@/app/[locale]/(other-pages)/check-network/check-network';
import { routes } from '@/config/routes';
import { formatDistanceKm } from '@/utils/format-distance';
import toast from 'react-hot-toast';
import { useTranslations } from 'next-intl';
import {
	BranchDetailsSkeleton,
	ListGridSkeleton,
} from '@/components/ui/skeletons';
import { openGoogleDirectionsToBranch } from '@/utils/route-builder.google';
import ClassCard from '@/components/ui/widgets/class-card';
import { ClassCardData } from '@/types';
import { Swiper, SwiperSlide } from 'swiper/react';
import { Autoplay } from 'swiper/modules';

const toClassCardData = (item: any, branch: any): ClassCardData => ({
	id: item?.id,
	title: item?.title,
	description: item?.description,
	duration: item?.duration,
	price:
		typeof item?.price === 'number'
			? item.price
			: typeof item?.price_in_sum === 'number'
				? item.price_in_sum
				: undefined,
	min_age: item?.min_age,
	max_age: item?.max_age,
	gender: item?.gender,
	has_photo: item?.has_photo,
	category: item?.category,
	branch: item?.branch
		? {
				id: item.branch.id,
				title: item.branch.title,
				address: item.branch.address,
				distance: item.branch.distance,
			}
		: {
				id: branch?.id,
				title: branch?.title,
				address: branch?.address,
				distance: branch?.distance,
			},
});

const parseClassListResponse = (response: any) => {
	const rootData = response?.data;
	const classes = Array.isArray(rootData)
		? rootData
		: Array.isArray(rootData?.data)
			? rootData.data
			: [];
	const page =
		typeof response?.page === 'number'
			? response.page
			: typeof rootData?.page === 'number'
				? rootData.page
				: 1;
	const pages =
		typeof response?.pages === 'number'
			? response.pages
			: typeof rootData?.pages === 'number'
				? rootData.pages
				: 1;

	return { classes, page, pages };
};

export default function BranchDetails() {
	const [branchData, setBranchData] = useState<any>(null);
	const [branchGallery, setBranchGallery] = useState<string[]>([]);
	const [classesData, setClassesData] = useState<ClassCardData[]>([]);
	const [classesPage, setClassesPage] = useState(1);
	const [classesTotalPages, setClassesTotalPages] = useState(1);
	const [isLoading, setIsLoading] = useState<boolean>(true);
	const [isClassesLoading, setIsClassesLoading] = useState<boolean>(true);
	const [isClassesLoadingMore, setIsClassesLoadingMore] =
		useState<boolean>(false);
	const [error, setError] = useState<string | null>(null);
	const [classesError, setClassesError] = useState<string | null>(null);
	const params = useParams();
	const router = useRouter();
	const branchId = params.id as string;
	const t = useTranslations('BranchDetails');

	useEffect(() => {
		const fetchBranchDetails = async () => {
			try {
				setIsLoading(true);
				const response = await getBranchById(branchId);
				setBranchData(response.data);
			} catch {
				setError('Failed to load branch details. Please try again.');
				// console.error('Error loading branch details:', err);
				toast.error(t('FailedToLoad'));
			} finally {
				setIsLoading(false);
			}
		};

		if (branchId) {
			fetchBranchDetails();
		}
	}, [branchId, t]);

	useEffect(() => {
		let isCancelled = false;

		const fetchBranchGallery = async () => {
			if (!branchId) return;
			try {
				setBranchGallery([]);
				const photos = await getBranchPhotos(branchId, { optimize: true });
				if (!isCancelled) setBranchGallery(photos);
			} catch {
				if (!isCancelled) setBranchGallery([]);
			}
		};

		void fetchBranchGallery();

		return () => {
			isCancelled = true;
		};
	}, [branchId]);

	const fetchClasses = async (page = 1, append = false) => {
		if (!branchId) return;

		if (page === 1) setIsClassesLoading(true);
		else setIsClassesLoadingMore(true);

		try {
			const response = await getClasses({
				page,
				limit: 10,
				branch_id: branchId,
			});
			const { classes, page: currentPage, pages } =
				parseClassListResponse(response);
			const mapped = classes.map((item: any) => toClassCardData(item, branchData));
			setClassesData((prev) => (append ? [...prev, ...mapped] : mapped));
			setClassesPage(currentPage);
			setClassesTotalPages(pages);
			setClassesError(null);
		} catch {
			setClassesError(t('FailedToLoadClasses'));
			toast.error(t('FailedToLoadClasses'));
		} finally {
			setIsClassesLoading(false);
			setIsClassesLoadingMore(false);
		}
	};

	useEffect(() => {
		if (branchId) void fetchClasses(1, false);
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [branchId]);

	const handleGoBack = () => {
		router.back();
	};

	const handleLoadMoreClasses = () => {
		if (isClassesLoading || isClassesLoadingMore) return;
		if (classesPage >= classesTotalPages) return;
		void fetchClasses(classesPage + 1, true);
	};

	if (isLoading) {
		return <BranchDetailsSkeleton />;
	}

	if (error || !branchData) {
		return <CheckNetwork />;
	}

	const fallbackHeroImage = branchData.has_photo
		? getImageUrl(branchData.id)
		: '/placeholder.avif';
	const heroImages =
		branchGallery.length > 0 ? branchGallery : [fallbackHeroImage];
	const hasGalleryCarousel = heroImages.length > 1;

	return (
		<div className="relative flex min-h-screen flex-col bg-transparent">
			<div className="relative h-72 w-full shadow-sm">
				<div className="absolute inset-0">
					{hasGalleryCarousel ? (
						<Swiper
							modules={[Autoplay]}
							autoplay={{
								delay: 5000,
								disableOnInteraction: false,
								pauseOnMouseEnter: false,
							}}
							loop
							rewind
							speed={600}
							slidesPerView={1}
							className="h-full w-full [&_.swiper-slide]:h-full [&_.swiper-wrapper]:h-full"
						>
							{heroImages.map((src, index) => (
								<SwiperSlide key={`${src}-${index}`}>
									<img
										src={src}
										alt={branchData.title}
										className="h-full w-full object-cover"
										loading={index === 0 ? 'eager' : 'lazy'}
										decoding="async"
										onError={(event) => {
											event.currentTarget.src = '/placeholder.avif';
										}}
									/>
								</SwiperSlide>
							))}
						</Swiper>
					) : (
						<img
							src={heroImages[0]}
							alt={branchData.title}
							className="h-full w-full object-cover"
							loading="eager"
							decoding="async"
							onError={(event) => {
								event.currentTarget.src = '/placeholder.avif';
							}}
						/>
					)}
				</div>
				<div className="pointer-events-none absolute inset-0 bg-gradient-to-b from-black/20 via-black/20 to-black/50" />
				<div className="absolute left-0 right-0 top-0 z-20 flex items-center justify-between p-3 pt-[calc(env(safe-area-inset-top)+8px)]">
					<button
						onClick={handleGoBack}
						className="relative z-30 rounded-full bg-white/80 p-2 text-gray-800 shadow-sm backdrop-blur hover:bg-white"
						aria-label="Go back"
					>
						<PiArrowLeft className="h-5 w-5" />
					</button>
				</div>

				{/* title over image */}
				<div className="absolute bottom-3 left-3 right-3 z-20 flex items-end justify-between">
					<h1 className="line-clamp-2 inline-flex max-w-full rounded-xl bg-black/35 px-3 py-2 text-xl font-bold text-white shadow-[0_8px_20px_rgba(0,0,0,0.28)] backdrop-blur-[1px]">
						{branchData.title}
					</h1>
				</div>
			</div>

			{/* Scrollable content area */}
			<div className="flex-1 overflow-y-auto px-2 pb-20">
				<div className="my-5 flex flex-col items-start gap-4 px-2">
					<div className="flex items-center justify-start gap-3">
							<div className="rounded-xl bg-mainPurple/12 p-2">
								<PiMapPinAreaDuotone className="size-7 text-mainPurple" />
							</div>
						<div className="flex flex-col items-start">
							<p className="text-xs font-semibold text-secondaryGray">
								{t('Address')}
							</p>
							<h3 className="text-xs font-medium text-mainPurple">
								{branchData.address}
							</h3>
						</div>
					</div>

					{/* Distance / Maps */}
					{branchData.distance !== undefined && (
						<div className="flex items-center justify-start gap-3">
							<div className="rounded-xl bg-indigo-100 p-2">
								<PiMapTrifoldDuotone className="size-7 text-indigo-500" />
							</div>
							<div className="flex flex-col items-start gap-0.5">
								<p className="text-xs font-semibold text-secondaryGray">
									{t('ViewOnMaps')}
								</p>
								<div className="flex items-center gap-2">
									<Badge
										onClick={() => {
											openGoogleDirectionsToBranch(branchData, {
												mode: 'driving',
												// onError: () => console.error(t('MapsError')),
											});
										}}
										variant="flat"
										size="md"
										rounded="lg"
										className="border border-indigo-100 bg-indigo-100 font-medium text-indigo-600"
									>
										{t('BuildRoute')}
									</Badge>
									<Badge
										variant="flat"
										size="sm"
										className="flex max-w-max items-center gap-1 rounded-lg border border-gray-200 bg-gray-100 text-textGray"
									>
										<PiNavigationArrowDuotone className="size-3 text-inherit" />
										{formatDistanceKm(branchData.distance)}
									</Badge>
								</div>
							</div>
						</div>
					)}
				</div>

				{/* About Section */}
				<div className="flex flex-col items-start gap-1 px-2">
					<h2 className="text-base font-bold text-textGray">{t('About')}</h2>
					<p className="pl-1 font-lexend leading-normal text-gray-600">
						{branchData.description || t('NoDescription')}
					</p>
				</div>

				<div className="mt-6 px-2">
					<h2 className="mb-3 text-base font-bold text-textGray">{t('Classes')}</h2>

					{isClassesLoading ? (
						<ListGridSkeleton variant="classes" count={2} />
					) : classesError ? (
						<div className="rounded-2xl border border-red-100 bg-red-50 p-4">
							<p className="text-sm text-red-600">{classesError}</p>
							<Button
								size="sm"
								variant="outline"
								onClick={() => void fetchClasses(1, false)}
								className="mt-3 rounded-xl border-mainPurple/20 bg-white"
							>
								{t('RetryClasses')}
							</Button>
						</div>
					) : classesData.length === 0 ? (
						<div className="rounded-2xl border border-white/90 bg-white/90 p-4 text-sm text-gray-500 shadow-sm">
							{t('NoClasses')}
						</div>
					) : (
						<>
							<div className="grid grid-cols-1 gap-4 md:grid-cols-2">
								{classesData.map((classItem) => (
									<Link href={routes.classDetails(classItem.id)} key={classItem.id}>
										<ClassCard classItem={classItem} showDescription />
									</Link>
								))}
							</div>

							{classesPage < classesTotalPages && (
								<div className="mt-4 flex justify-center">
									<Button
										size="sm"
										onClick={handleLoadMoreClasses}
										isLoading={isClassesLoadingMore}
										className="rounded-xl bg-mainPurple px-4 shadow-[0_8px_20px_rgba(166,82,199,0.3)]"
									>
										{t('LoadMoreClasses')}
									</Button>
								</div>
							)}
						</>
					)}
				</div>
			</div>
		</div>
	);
}
