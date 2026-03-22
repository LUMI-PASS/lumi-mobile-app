'use client';

import { useEffect, useMemo, useState } from 'react';
import Image from 'next/image';
import { Link } from '@/i18n/routing';
import { Badge } from 'rizzui';
import {
	PiMapPinAreaDuotone,
	PiNavigationArrowDuotone,
} from 'react-icons/pi';
import cn from '@/utils/class-names';
import { getBranchPhotos, getImageUrl } from '@/services/api';
import { formatDistanceKm } from '@/utils/format-distance';
import { BranchCardData, BranchCardProps } from '@/types';
import { GRADIENTS } from '@/config/constants';
function gradientFor(title?: string) {
	const i =
		((title?.charCodeAt(0) ?? 65) + (title?.length ?? 0)) % GRADIENTS.length;
	return GRADIENTS[i];
}
function categoryTitle(c?: BranchCardData['category']) {
	if (!c) return null;
	return typeof c === 'string' ? c : (c?.title ?? null);
}
export default function BranchCard({
	branch,
	variant = 'vertical',
	density = 'comfortable',
	showDescription = true,
	showCategory = true,
	showStatus = false,
	showDistance = true,
	hoverable = true,
	href,
	onBookmarkToggle,
	isBookmarked,
	onClick,
	className,
}: BranchCardProps) {
	const [imgLoaded, setImgLoaded] = useState(false);
	const [resolvedImageSrc, setResolvedImageSrc] = useState<string | null>(
		branch.has_photo && branch.id ? getImageUrl(branch.id) : null
	);
	const [hasImageError, setHasImageError] = useState(false);

	useEffect(() => {
		let isCancelled = false;
		const fallback =
			branch.has_photo && branch.id ? getImageUrl(branch.id) : null;

		setImgLoaded(false);
		setHasImageError(false);
		setResolvedImageSrc(fallback);

		const loadThumbnail = async () => {
			if (!branch.id) return;
			const photos = await getBranchPhotos(branch.id, {
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
	}, [branch.id, branch.has_photo]);

	const cat = useMemo(() => categoryTitle(branch.category), [branch.category]);
	const distance = useMemo(
		() => formatDistanceKm(branch.distance),
		[branch.distance]
	);

	const isVertical = variant === 'vertical';
	const comfy = density === 'comfortable';
	const showImage = Boolean(resolvedImageSrc) && !hasImageError;
	const imageSrc = resolvedImageSrc ?? '/placeholder.avif';
	const gradient = useMemo(() => gradientFor(branch.title), [branch.title]);

	const Card = (href ? Link : 'div') as any;

	return (
		<Card
			href={href}
			onClick={href ? undefined : onClick}
			className={cn(
				'stagger-in group relative block select-none overflow-hidden rounded-[22px] border border-white/90 bg-white/90 shadow-[0_8px_20px_rgba(60,83,154,0.12)] backdrop-blur',
				hoverable &&
					'transition-all duration-200 hover:-translate-y-0.5 hover:shadow-[0_16px_28px_rgba(60,83,154,0.18)]',
				isVertical ? 'p-2' : 'p-3',
				className
			)}
			aria-label={branch.title}
		>
			<div
				className={cn(
					'relative overflow-hidden rounded-xl',
					isVertical ? 'h-44' : 'h-28 w-full'
				)}
			>
				{showImage && !imgLoaded && (
					<div className="absolute inset-0 animate-pulse rounded-xl bg-gray-200" />
				)}

				{showImage ? (
					<Image
						src={imageSrc}
						alt={branch.title}
						fill
						className={cn(
							'object-cover transition-opacity duration-300',
							imgLoaded ? 'opacity-100' : 'opacity-0'
						)}
						sizes="(max-width: 768px) 100vw, 50vw"
						onLoad={() => setImgLoaded(true)}
						onError={() => {
							setHasImageError(true);
							setImgLoaded(true);
						}}
						priority={false}
					/>
				) : (
					<div
						className={cn(
							'absolute inset-0 rounded-xl bg-gradient-to-tr opacity-90',
							gradient
						)}
					/>
				)}

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
				</div>
			</div>

			<div className={cn('pt-2', isVertical ? 'px-1.5' : 'px-0')}>
				<h3
					className={cn(
						'line-clamp-1 font-semibold text-textGray',
						comfy ? 'text-base' : 'text-[15px]'
					)}
				>
					{branch.title}
				</h3>

				{showDescription && branch.description && (
					<p
						className={cn(
							'mt-1 text-gray-600',
							comfy ? 'line-clamp-2 text-[12px]' : 'line-clamp-1 text-[12px]'
						)}
					>
						{branch.description}
					</p>
				)}

				{showDistance && (branch.address || distance) && (
					<div className="mt-2 flex items-center justify-start gap-4 overflow-clip">
						<div className="flex min-w-0 max-w-[70%] items-center text-[12px] text-indigo-900/90">
							<PiMapPinAreaDuotone className="mr-1 h-3.5 w-3.5 shrink-0 text-inherit" />
							<span className="ml-1 truncate">
								{branch.address ?? 'Location not specified'}
							</span>
						</div>
						<div className="flex min-w-0 items-center text-[12px] text-indigo-900/90">
							<PiNavigationArrowDuotone className="mr-1 h-3.5 w-3.5 shrink-0 text-inherit" />
							{distance && (
								<span className="ml-1 shrink-0 opacity-70">{distance}</span>
							)}
						</div>
					</div>
				)}
			</div>
		</Card>
	);
}
