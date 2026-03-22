'use client';

import { useEffect, useMemo, useState } from 'react';
import Image from 'next/image';
import cn from '@/utils/class-names';
import { getClassPhotos, getImageUrl } from '@/services/api';
import { Badge } from 'rizzui';
import {
	PiClockDuotone,
	PiMapPinAreaDuotone,
	PiUserDuotone,
	PiBuildingApartmentDuotone,
	PiNavigationArrowDuotone,
} from 'react-icons/pi';
import { formatDistanceKm } from '@/utils/format-distance';
import { BoyIcon, GirlIcon, BothIcon } from '../gender-icons';
import { Gender } from '@/types';
import { ClassCardData, ClassCardProps } from '@/types/index';
import { useTranslations, useLocale } from 'next-intl';

function categoryTitle(c?: ClassCardData['category']) {
	if (!c) return null;
	return typeof c === 'string' ? c : (c?.title ?? null);
}

export default function ClassCard({
	classItem,
	variant = 'vertical',
	density = 'comfortable',
	wrapBranch = false,
	showDescription = true,
	showCategory = true,
	showAge = true,
	showGender = true,
	showPrice = true,
	showDistance = true,
	showDuration = true,
	hoverable = true,
	onBookmarkToggle,
	isBookmarked,
	className,
}: ClassCardProps) {
	const [imgLoaded, setImgLoaded] = useState(false);
	const [resolvedImageSrc, setResolvedImageSrc] = useState(
		classItem.has_photo && classItem.id
			? getImageUrl(classItem.id)
			: '/placeholder.avif'
	);

	const tDrw = useTranslations('Drawers');
	const tCD = useTranslations('ClassDetails');
	const tTicket = useTranslations('TicketDetails');
	const locale = useLocale();

	// localized helpers
	const fmtAge = (min?: number, max?: number) => {
		const suffix = tDrw('Explore.AgeSuffix');
		if (min == null && max == null) return null;
		if (min != null && max != null) return `${min}-${max} ${suffix}`;
		if (min != null) return `${min}+ ${suffix}`;
		return `≤ ${max} ${suffix}`;
	};

	const fmtDuration = (min?: number) => {
		if (!min || min <= 0) return null;
		const h = Math.floor(min / 60);
		const m = min % 60;
		const H = locale === 'ru' ? ' ч ' : locale === 'uz' ? ' soat ' : ' h ';
		const M = locale === 'ru' ? ' мин ' : locale === 'uz' ? ' daq ' : ' m ';
		if (h && m) return `${h}${H} ${m}${M}`;
		if (h) return `${h}${H}`;
		return `${m}${M}`;
	};

	const genderText = (g?: Gender | null) => {
		if (!g) return null;
		if (g === 'MALE') return tCD('GenderBoys');
		if (g === 'FEMALE') return tCD('GenderGirls');
		return tCD('GenderBoth');
	};

	const cat = useMemo(
		() => categoryTitle(classItem.category),
		[classItem.category]
	);
	const fullPrice =
		typeof classItem.price === 'number' && Number.isFinite(classItem.price)
			? classItem.price
			: null;
	const trialPrice =
		typeof classItem.trial_price === 'number' &&
		Number.isFinite(classItem.trial_price)
			? classItem.trial_price
			: null;
	const showPreviewSale =
		fullPrice !== null &&
		trialPrice !== null &&
		classItem.trial_enabled === true &&
		trialPrice < fullPrice;
	const age = useMemo(
		() => fmtAge(classItem.min_age, classItem.max_age),
		[classItem.min_age, classItem.max_age, locale, tDrw]
	);
	const distance = useMemo(
		() => formatDistanceKm(classItem.branch?.distance),
		[classItem.branch?.distance, (classItem as any).distance]
	);
	const duration = useMemo(
		() => fmtDuration(classItem.duration),
		[classItem.duration, locale]
	);
	const genderLabel = useMemo(
		() => genderText(classItem.gender),
		[classItem.gender, tCD]
	);

	const isVertical = variant === 'vertical';
	const comfy = density === 'comfortable';

	useEffect(() => {
		let isCancelled = false;
		const fallback =
			classItem.has_photo && classItem.id
				? getImageUrl(classItem.id)
				: '/placeholder.avif';

		setImgLoaded(false);
		setResolvedImageSrc(fallback);

		const loadThumbnail = async () => {
			if (!classItem.id) return;
			const photos = await getClassPhotos(classItem.id, {
				optimize: true,
				limit: 1,
			});
			if (isCancelled) return;
			if (photos[0]) {
				setResolvedImageSrc(photos[0]);
			}
		};

		void loadThumbnail();

		return () => {
			isCancelled = true;
		};
	}, [classItem.id, classItem.has_photo]);

	return (
		<div
			className={cn(
				'stagger-in group relative overflow-hidden rounded-[22px] border border-white/90 bg-white/90 shadow-[0_8px_20px_rgba(60,83,154,0.12)] backdrop-blur',
				hoverable &&
					'p-2 transition-all duration-200 hover:-translate-y-0.5 hover:shadow-[0_16px_28px_rgba(60,83,154,0.18)]',
				className
			)}
			aria-label={classItem.title}
		>
			{/* media */}
			<div
				className={cn(
					'relative overflow-hidden rounded-xl',
					isVertical && 'w-full',
					wrapBranch ? 'h-40' : 'h-44'
				)}
			>
				{!imgLoaded && (
					<div className="absolute inset-0 animate-pulse rounded-xl bg-gray-200" />
				)}
				<Image
					src={resolvedImageSrc}
					alt={classItem.title}
					fill
					className={cn(
						'object-cover transition-opacity duration-300',
						imgLoaded ? 'opacity-100' : 'opacity-0'
					)}
					sizes="(max-width: 768px) 100vw, 50vw"
					onLoad={() => setImgLoaded(true)}
					onError={(event) => {
						event.currentTarget.src = '/placeholder.avif';
						setImgLoaded(true);
					}}
					priority={false}
				/>

				{/* top-left chips */}
				<div className="pointer-events-none absolute left-2 top-2 flex flex-wrap items-center gap-1">
					{showCategory && cat && (
						<Badge
							variant="flat"
							size="sm"
							className="border border-white/80 bg-white/75 text-mainPurple backdrop-blur"
						>
							{cat}
						</Badge>
					)}
					{showDuration && duration && (
						<Badge
							variant="flat"
							size="sm"
							className="border border-white/65 bg-[#21376d]/65 text-white backdrop-blur"
						>
							<span className="inline-flex items-center gap-1">
								<PiClockDuotone className="h-3.5 w-3.5" />
								{duration}
							</span>
						</Badge>
					)}
				</div>

					{/* price pill */}
					{showPrice && (
						<div className="absolute bottom-2 right-2 flex items-end">
							{fullPrice !== null && (
								<div
									className={cn(
										'flex items-center rounded-xl border border-emerald-200 bg-white px-2.5 py-1 shadow-sm',
										showPreviewSale ? 'gap-2' : 'gap-1 text-textGray'
									)}
								>
									{showPreviewSale ? (
										<>
											<div className="flex items-center gap-0.5 text-slate-600">
												<span className="tabular-nums text-[11px] font-semibold leading-none line-through decoration-[1.5px]">
													{fullPrice}
												</span>
												<Image
													src="/icons/coin.svg"
													alt="Lumi Coin"
													width={12}
													height={12}
												/>
											</div>
											<div className="flex items-center gap-0.5 text-emerald-700">
												<span className="tabular-nums text-sm font-extrabold leading-none">
													{trialPrice}
												</span>
												<Image
													src="/icons/coin.svg"
													alt="Lumi Coin"
													width={16}
													height={16}
												/>
											</div>
										</>
									) : (
										<>
											<span className="tabular-nums text-sm font-extrabold leading-none">
												{fullPrice}
											</span>
											<Image
												src="/icons/coin.svg"
												alt="Lumi Coin"
												width={16}
												height={16}
											/>
										</>
									)}
								</div>
							)}
						</div>
					)}
			</div>

			{/* body */}
			<div className={cn('pt-2', isVertical ? 'px-1.5' : 'px-0')}>
				{/* title */}
				<h4
					className={cn(
						'line-clamp-1 font-semibold text-textGray',
						comfy ? 'text-sm' : 'text-[15px]'
					)}
				>
					{classItem.title}
				</h4>

        {/* top row */}
        <div
          className={cn(
            'mt-1.5 flex items-center justify-between gap-3 overflow-x-auto whitespace-nowrap overscroll-behavior-x-contain pb-1'
          )}
        >
          {showDescription && classItem.branch?.title && (
            <Badge
              variant="flat"
              size="sm"
              className="flex w-fit shrink-0 items-center gap-1 rounded-lg border border-violet-100 bg-violet-50/80 text-violet-700"
            >
              <PiBuildingApartmentDuotone className="size-3" />
              {classItem.branch?.title}
            </Badge>
          )}
          <div className="flex shrink-0 items-center gap-2 text-[11px] lowercase text-gray-600">
	            {showGender && genderLabel && (
	              <span
	                className={cn(
	                  'inline-flex items-center',
	                  classItem.gender === 'MALE'
	                    ? 'text-blue-500'
	                    : classItem.gender === 'FEMALE'
	                      ? 'text-violet-600'
	                      : 'text-violet-600'
	                )}
	              >
                {classItem.gender === 'MALE' ? (
                  <BoyIcon size={20} />
                ) : classItem.gender === 'FEMALE' ? (
                  <GirlIcon size={20} />
                ) : (
                  <BothIcon size={20} className="mr-0.5" />
                )}
                {genderLabel}
              </span>
            )}
            {showAge && age && (
              <span className="inline-flex items-center gap-1 text-green-600">
                <PiUserDuotone className="h-3 w-3 text-inherit" />
                {age}
              </span>
            )}
          </div>
        </div>

				{/* bottom row */}
				{showDistance && (classItem.branch?.address || distance) && (
					<div className="mt-2 flex items-center justify-start gap-2 overflow-hidden">
						<div className="flex min-w-0 flex-1 items-center gap-1 text-xs text-indigo-900/90">
							<PiMapPinAreaDuotone className="h-3.5 w-3.5 shrink-0 text-inherit" />
							<span className="truncate">
								{classItem.branch?.address ?? tTicket('NoAddressProvided')}
							</span>
						</div>
						<div className="flex min-w-0 items-center gap-1 text-[12px] text-indigo-900 opacity-90">
							<PiNavigationArrowDuotone className="h-3 w-3 shrink-0 text-inherit" />
							{distance && <span className="shrink-0">{distance}</span>}
						</div>
					</div>
				)}
			</div>
		</div>
	);
}
