'use client';

import { useEffect, useMemo, useState } from 'react';
import { Banner } from '@/types';
import { getImageUrl } from '@/services/api';
import { Swiper, SwiperSlide } from 'swiper/react';
import { Pagination, Autoplay } from 'swiper/modules';
import type { Swiper as SwiperType } from 'swiper/types';
import 'swiper/css';
import 'swiper/css/pagination';

interface BannerSliderProps {
	banners: Banner[];
}

type BannerSlide = {
	key: string;
	src: string;
	title: string;
};

const UUID_REGEX =
	/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function resolveBannerSrc(banner: Banner): string {
	const raw = (banner?.url ?? '').trim();
	if (raw.startsWith('http://') || raw.startsWith('https://')) {
		return raw;
	}
	if (UUID_REGEX.test(raw)) {
		return getImageUrl(raw);
	}
	return getImageUrl(banner.id);
}

export default function BannerSlider({ banners }: BannerSliderProps) {
	const [isReady, setIsReady] = useState(false);
	const bannerShellClass =
		'relative aspect-[16/8] w-full rounded-[24px] bg-transparent sm:aspect-[21/9] md:aspect-[32/10]';

	const baseSlides = useMemo<BannerSlide[]>(
		() =>
			(banners ?? []).map((banner, index) => ({
				key: `${banner.id}-${index}`,
				src: resolveBannerSrc(banner),
				title: banner.title || 'Banner',
			})),
		[banners]
	);

	const hasMultipleBanners = baseSlides.length > 1;
	const sliderKey = baseSlides.map((slide) => slide.key).join('|');

	useEffect(() => {
		let isCancelled = false;

		const preloadImage = (src: string) =>
			new Promise<void>((resolve) => {
				const img = new window.Image();
				img.decoding = 'async';
				img.onload = () => resolve();
				img.onerror = () => resolve();
				img.src = src;
				if (img.complete) resolve();
			});

		const preloadAllBanners = async () => {
			const uniqueSources = Array.from(new Set(baseSlides.map((slide) => slide.src)));
			if (uniqueSources.length === 0) {
				if (!isCancelled) setIsReady(true);
				return;
			}

			await Promise.all(uniqueSources.map(preloadImage));

			if (!isCancelled) {
				setIsReady(true);
			}
		};

		setIsReady(false);
		preloadAllBanners();

		return () => {
			isCancelled = true;
		};
		}, [baseSlides]);

	if (!baseSlides.length) return null;

	if (!isReady) {
		return (
			<div className="px-4 pb-3">
				<div className={bannerShellClass}>
					<div className="h-full w-full animate-pulse rounded-[24px] bg-gray-200/45" />
				</div>
			</div>
		);
	}

	if (!hasMultipleBanners) {
		const slide = baseSlides[0];
		return (
			<div className="px-4 pb-3">
				<div className={bannerShellClass}>
					<img
						src={slide.src || '/placeholder.avif'}
						alt={slide.title}
						loading="eager"
						decoding="async"
						draggable={false}
						className="block h-full w-full rounded-[24px] object-cover ring-1 ring-white/85 shadow-[0_10px_22px_rgba(60,83,154,0.16)]"
						onError={(event) => {
							event.currentTarget.src = '/placeholder.avif';
						}}
					/>
					<div className="pointer-events-none absolute inset-x-0 bottom-0 h-20 rounded-b-[24px] bg-gradient-to-t from-black/25 via-black/5 to-transparent" />
				</div>
			</div>
		);
	}

	const handleSwiperInit = (swiper: SwiperType) => {
		requestAnimationFrame(() => {
			if (swiper.destroyed) return;
			swiper.slideTo(0, 0, false);
			if (swiper.autoplay && !swiper.autoplay.running) {
				swiper.autoplay.start();
			}
		});
	};

	return (
		<div className="px-4 pb-3">
			<Swiper
				key={sliderKey}
				modules={[Pagination, Autoplay]}
				onSwiper={handleSwiperInit}
				pagination={{
					clickable: true,
					dynamicBullets: true,
				}}
				autoplay={{
					delay: 5000,
					disableOnInteraction: false,
					pauseOnMouseEnter: false,
					waitForTransition: true,
				}}
				slideToClickedSlide
				slidesPerView={1}
				spaceBetween={0}
				initialSlide={0}
				loop={false}
				rewind
				speed={600}
				grabCursor
				allowTouchMove
				touchStartPreventDefault={false}
				touchMoveStopPropagation={false}
				watchSlidesProgress
				observer
				observeParents
				nested
				className="[touch-action:pan-y] [&_.swiper-slide]:!h-auto [&_.swiper-slide]:bg-transparent [&_.swiper-wrapper]:bg-transparent"
			>
				{baseSlides.map((slide) => {
					return (
						<SwiperSlide key={slide.key} className="!w-full">
							<div className={bannerShellClass}>
								<img
									src={slide.src || '/placeholder.avif'}
									alt={slide.title}
									loading="eager"
									decoding="async"
									draggable={false}
									className="block h-full w-full rounded-[24px] object-cover ring-1 ring-white/85 shadow-[0_10px_22px_rgba(60,83,154,0.16)]"
									onError={(event) => {
										event.currentTarget.src = '/placeholder.avif';
									}}
								/>
								<div className="pointer-events-none absolute inset-x-0 bottom-0 h-20 rounded-b-[24px] bg-gradient-to-t from-black/20 via-black/5 to-transparent" />
							</div>
						</SwiperSlide>
					);
				})}
			</Swiper>
		</div>
	);
}
