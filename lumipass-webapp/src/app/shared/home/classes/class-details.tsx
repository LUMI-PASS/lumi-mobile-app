'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { useRouter } from '@/i18n/routing';
import {
	getClassById,
	getClassPhotos,
	getImageUrl,
	checkClassEligibility,
} from '@/services/api';
import Image from 'next/image';
import { Badge, Loader } from 'rizzui';
import {
	PiArrowLeft,
	PiNavigationArrowDuotone,
	PiMapPinAreaDuotone,
	PiClockClockwiseDuotone,
	PiUserDuotone,
} from 'react-icons/pi';
import DrawerButton from '@/components/ui/buttons/drawer-button';
import SelectChildView from '../../views/select-child-view';
import ChoosePackageView from '../../views/choose-package-view';
import CheckNetwork from '@/app/[locale]/(other-pages)/check-network/check-network';
import { BoyIcon, GirlIcon, BothIcon } from '@/components/ui/gender-icons';
import { formatDistanceKm } from '@/utils/format-distance';
import { useTranslations, useLocale } from 'next-intl';
import { ClassDetailsSkeleton } from '@/components/ui/skeletons';
import { routes } from '@/config/routes';
import { Swiper, SwiperSlide } from 'swiper/react';
import { Autoplay } from 'swiper/modules';
import type { ChildData, ClassDetail, ClassEligibilityData } from '@/types';

function cn(...classes: (string | false | null | undefined)[]) {
	return classes.filter(Boolean).join(' ');
}

export default function ClassDetails() {
	const [classData, setClassData] = useState<ClassDetail | null>(null);
	const [classGallery, setClassGallery] = useState<string[]>([]);
	const [eligibilityPreview, setEligibilityPreview] =
		useState<ClassEligibilityData | null>(null);
	const [isLoading, setIsLoading] = useState<boolean>(true);
	const [isCheckingEligibility, setIsCheckingEligibility] =
		useState<boolean>(false);
	const [error, setError] = useState<string | null>(null);

	const params = useParams();
	const router = useRouter();
	const classId = params.classId as string;

	const t = useTranslations('ClassDetails');
	const tDrw = useTranslations('Drawers.Explore');
	const locale = useLocale();

	// localized helpers
	const fmtDuration = (min?: number) => {
		if (!min || min <= 0) return '—';
		const h = Math.floor(min / 60);
		const m = min % 60;
		const H = locale === 'ru' ? ' ч ' : locale === 'uz' ? ' soat ' : ' h ';
		const M = locale === 'ru' ? ' мин ' : locale === 'uz' ? ' daq ' : ' m ';
		if (h && m) return `${h}${H} ${m}${M}`;
		if (h) return `${h}${H}`;
		return `${m}${M}`;
	};

	const fmtAge = (min?: number, max?: number) => {
		const suffix = tDrw('AgeSuffix');
		if (min == null && max == null) return '—';
		if (min != null && max != null) return `${min}-${max} ${suffix}`;
		if (min != null) return `${min}+ ${suffix}`;
		return `≤ ${max} ${suffix}`;
	};

	useEffect(() => {
		const fetchClassDetails = async () => {
			try {
				setIsLoading(true);
				const response = await getClassById(classId);
				setClassData(response.data as ClassDetail);
			} catch {
				setError('LOAD_ERROR');
				// console.error('Error loading class details:', err);
			} finally {
				setIsLoading(false);
			}
		};

		if (classId) {
			fetchClassDetails();
		}
	}, [classId]);

	useEffect(() => {
		let isCancelled = false;

		const fetchClassGallery = async () => {
			if (!classId) return;
			try {
				setClassGallery([]);
				const photos = await getClassPhotos(classId, { optimize: true });
				if (!isCancelled) setClassGallery(photos);
			} catch {
				if (!isCancelled) setClassGallery([]);
			}
		};

		void fetchClassGallery();

		return () => {
			isCancelled = true;
		};
	}, [classId]);

	useEffect(() => {
		let isCancelled = false;

		const fetchEligibilityPreview = async () => {
			if (!classId) return;
			setEligibilityPreview(null);
			try {
				const response = await checkClassEligibility(classId);
				if (!isCancelled) {
					setEligibilityPreview(response?.data ?? null);
				}
			} catch {
				if (!isCancelled) {
					setEligibilityPreview(null);
				}
			}
		};

		void fetchEligibilityPreview();

		return () => {
			isCancelled = true;
		};
	}, [classId]);

	const handleCheckEligibility = async (): Promise<ClassEligibilityData | null> => {
		if (eligibilityPreview) {
			return eligibilityPreview;
		}

		try {
			setIsCheckingEligibility(true);
			const response = await checkClassEligibility(classId);
			const data = response?.data ?? null;
			setEligibilityPreview(data);
			return data;
		} catch {
			// console.error('Error checking eligibility:', err);
			return null;
		} finally {
			setIsCheckingEligibility(false);
		}
	};

	const handleGoBack = () => router.back();
	const handleViewCenter = () => {
		const branchId = classData?.branch?.id;
		if (!branchId) return;
		router.push(routes.branchDetails(branchId));
	};

	if (isLoading) {
		return <ClassDetailsSkeleton />;
	}
	if (error || !classData) {
		return <CheckNetwork />;
	}

	const fallbackHeroImage = classData.has_photo
		? getImageUrl(classData.id)
		: '/placeholder.avif';
	const heroImages =
		classGallery.length > 0 ? classGallery : [fallbackHeroImage];
	const hasGalleryCarousel = heroImages.length > 1;

	const genderKey: 'MALE' | 'FEMALE' | 'BOTH' | undefined = classData.gender;
	const genderText =
		genderKey === 'MALE'
			? t('GenderBoys')
			: genderKey === 'FEMALE'
				? t('GenderGirls')
				: t('GenderBoth');

	const duration = fmtDuration(classData.duration);
	const ages = fmtAge(classData.min_age, classData.max_age);
	const dist = formatDistanceKm(
		classData.branch?.distance ?? classData.distance
	);
	const previewChildren: ChildData[] = Array.isArray(eligibilityPreview?.children)
		? eligibilityPreview.children
		: [];
	const hasAnyEligibleTrialChild = previewChildren.some(
		(child) => child.is_eligible && child.will_use_trial
	);

	const fullPrice =
		typeof classData.price === 'number' && Number.isFinite(classData.price)
			? classData.price
			: null;
	const trialPrice =
		typeof classData.trial_price === 'number' &&
		Number.isFinite(classData.trial_price)
			? classData.trial_price
			: null;
	const showTrialSale =
		fullPrice !== null &&
		trialPrice !== null &&
		hasAnyEligibleTrialChild;

	const ctaPrice = showTrialSale ? trialPrice : fullPrice;
	const ctaLabel = showTrialSale ? t('BookFrom') : t('BookFor');

	return (
		<div className="relative flex min-h-screen flex-col bg-transparent">
			{/* HERO */}
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
										alt={classData.title}
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
							alt={classData.title}
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
				{/* top controls */}
				<div className="absolute left-0 right-0 top-0 z-20 flex items-center justify-between p-3 pt-[calc(env(safe-area-inset-top)+8px)]">
					<button
						onClick={handleGoBack}
						className="relative z-30 rounded-full bg-white/80 p-2 text-gray-800 shadow-sm backdrop-blur hover:bg-white"
						aria-label="Go back"
					>
						<PiArrowLeft className="h-5 w-5" />
					</button>
					<Badge
						variant="flat"
						size="md"
						className="mt-2 max-w-max border border-white/20 bg-black/35 text-white shadow-[0_8px_20px_rgba(0,0,0,0.28)] backdrop-blur-[1px]"
					>
						{classData.category?.title || t('Uncategorized')}
					</Badge>
				</div>

				{/* title over image */}
				<div className="absolute bottom-3 left-3 right-3 z-20 flex items-end justify-between">
					<h1 className="line-clamp-2 inline-flex max-w-full rounded-xl bg-black/35 px-3 py-2 text-xl font-bold text-white shadow-[0_8px_20px_rgba(0,0,0,0.28)] backdrop-blur-[1px]">
						{classData.title}
					</h1>
				</div>
			</div>

			{/* BODY */}
			<div className="flex-1 overflow-y-auto px-4 pb-44">
				{/* quick chips */}
				<div className="mt-4 flex flex-wrap items-center justify-start gap-2">
					<Badge variant="flat" rounded="lg" className="border border-green-100 bg-green-50 text-green-700">
						<PiUserDuotone className="mr-1 h-4 w-4" />
						{ages}
					</Badge>
					<Badge variant="flat" rounded="lg" className="border border-slate-100 bg-slate-50 text-slate-700">
						<PiClockClockwiseDuotone className="mr-1 h-4 w-4" />
						{duration}
					</Badge>
					<Badge
						variant="flat"
							className={cn(
								'inline-flex items-center justify-center gap-1 bg-transparent px-1',
								genderKey === 'MALE'
									? 'text-blue-500'
									: genderKey === 'FEMALE'
										? 'text-violet-600'
										: 'text-mainPurple'
							)}
						>
						{genderKey === 'MALE' ? (
							<BoyIcon size={27} />
						) : genderKey === 'FEMALE' ? (
							<GirlIcon size={27} />
						) : (
							<BothIcon size={27} />
						)}
						{genderText}
					</Badge>
				</div>

				{/* location */}
				{(classData.branch?.title || classData.branch?.address) && (
					<button
						type="button"
						onClick={handleViewCenter}
						disabled={!classData.branch?.id}
						className={cn(
							'mt-3 flex w-full items-start gap-3 rounded-2xl border border-white/90 bg-white/90 p-3 text-left shadow-sm',
							classData.branch?.id && 'cursor-pointer active:scale-[0.995]'
						)}
					>
						<div className="rounded-xl bg-indigo-100 p-2 text-indigo-900">
							<PiMapPinAreaDuotone className="h-5 w-5" />
						</div>
						<div className="flex min-w-0 flex-col items-start gap-0.5">
							<div className="flex w-full items-center justify-between gap-2 text-sm font-semibold text-textGray">
								{classData.branch?.title}
								{dist && (
									<div className="flex min-w-0 items-center gap-1 rounded-md bg-indigo-100 px-1 text-[12px] text-indigo-900 opacity-80">
										<PiNavigationArrowDuotone className="h-3 w-3 shrink-0 text-inherit" />
										<span className="shrink-0">{dist}</span>
									</div>
								)}
							</div>
							<div className="w-full text-xs text-indigo-500">
								{classData.branch?.address}
							</div>
						</div>
					</button>
				)}

				{/* about */}
				{classData.description && (
					<section className="mt-5">
						<h2 className="mb-2 text-base font-bold text-textGray">
							{t('About')}
						</h2>
						<p className="pl-1 leading-normal text-gray-600">
							{classData.description}
						</p>
					</section>
				)}
			</div>

			{/* STICKY CTA */}
			<div className="fixed bottom-[65px] left-0 right-0 bg-gradient-to-t from-[#f7fbff] via-[#f7fbff]/80 to-transparent px-3 pb-4 pt-4">
				<div className="mx-auto max-w-[75%]">
					<DrawerButton
						modalView={async () => {
							const data = await handleCheckEligibility();
							if (!data) {
								return <ChoosePackageView />;
							}

							const children: ChildData[] = Array.isArray(data.children)
								? data.children
								: [];
							const hasChildren = children.length > 0;
							const hasAffordableChild = children.some((child) => {
								const effectivePrice =
									typeof child?.effective_class_price === 'number'
										? child.effective_class_price
										: data.class_price;
								return Number(data.wallet_balance ?? 0) >= effectivePrice;
							});
							const canProceed =
								!hasChildren ||
								Boolean(
									data.is_balance_enough ||
										data.is_balance_enough_for_trial_price ||
										hasAffordableChild
								);

							if (canProceed) {
								return <SelectChildView eligibilityData={data} />;
							}
							return <ChoosePackageView />;
						}}
						placement="bottom"
						height="85vh"
						className="flex items-center justify-center gap-3 rounded-2xl bg-mainPurple py-6 font-bold text-white shadow-[0_14px_26px_rgba(166,82,199,0.34)]"
					>
						{isCheckingEligibility ? (
							<Loader size="sm" color="primary" className="mr-1" />
						) : (
							<div className="flex items-center justify-center gap-3">
								<span className="shrink-0 text-base font-bold tracking-tight">
									{ctaLabel}
								</span>
								{ctaPrice !== null && (
									<div className="flex items-center rounded-xl bg-white/14 px-2.5 py-1.5 ring-1 ring-white/20 backdrop-blur-sm">
										{showTrialSale ? (
											<div className="flex items-end gap-2">
												<div className="flex items-center gap-0.5 text-white/70">
													<span className="tabular-nums text-sm font-semibold line-through decoration-[1.5px]">
														{fullPrice}
													</span>
													<Image
														src="/icons/coin.svg"
														alt="Coin"
														className="opacity-75"
														width={14}
														height={14}
													/>
												</div>
												<div className="flex items-center gap-0.5 text-white">
													<span className="tabular-nums text-lg font-extrabold leading-none">
														{trialPrice}
													</span>
													<Image
														src="/icons/coin.svg"
														width={20}
														height={20}
														alt="Coin"
													/>
												</div>
											</div>
										) : (
											<div className="flex items-center gap-0.5 text-white">
												<span className="tabular-nums text-lg font-extrabold leading-none">
													{ctaPrice}
												</span>
												<Image
													src="/icons/coin.svg"
													width={20}
													height={20}
													alt="Coin"
												/>
											</div>
										)}
									</div>
								)}
							</div>
						)}
					</DrawerButton>
				</div>
			</div>
		</div>
	);
}
