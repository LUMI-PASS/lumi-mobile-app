'use client';

import { useEffect, useMemo, useState } from 'react';
import Image from 'next/image';
import { Link } from '@/i18n/routing';
import { getCategoryPhotos, getImageUrl } from '@/services/api';
import cn from '@/utils/class-names';
import { GRADIENTS } from '@/config/constants';
import { CategoryCardProps } from '@/types';

function gradientFor(title?: string) {
	const i =
		((title?.charCodeAt(0) ?? 65) + (title?.length ?? 0)) % GRADIENTS.length;
	return GRADIENTS[i];
}

function sizeClasses(size: CategoryCardProps['size']) {
	switch (size) {
		case 'sm':
			return {
				media: 'h-24',
				title: 'text-xs',
				pad: 'p-0',
			};
		case 'lg':
			return {
				media: 'h-40',
				title: 'text-base',
				pad: 'p-0',
			};
		case 'md':
		default:
			return {
				media: 'h-28',
				title: 'text-sm',
				pad: 'p-0',
			};
	}
}

function CardInner({
	category,
	variant = 'overlay',
	size = 'md',
	active,
	onClick,
	className,
}: Omit<CategoryCardProps, 'href'>) {
	const [resolvedImageSrc, setResolvedImageSrc] = useState<string | null>(
		category.has_photo && category.id ? getImageUrl(category.id) : null
	);
	const [imgOk, setImgOk] = useState(Boolean(resolvedImageSrc));
	const [imgLoaded, setImgLoaded] = useState(false);

	const g = useMemo(() => gradientFor(category.title), [category.title]);
	const sz = sizeClasses(size);

	useEffect(() => {
		let isCancelled = false;
		const fallback = category.has_photo && category.id ? getImageUrl(category.id) : null;

		setImgLoaded(false);
		setResolvedImageSrc(fallback);
		setImgOk(Boolean(fallback));

		const loadThumbnail = async () => {
			if (!category.id) return;
			const photos = await getCategoryPhotos(category.id, {
				optimize: true,
				limit: 1,
			});
			if (isCancelled) return;
			if (photos[0]) {
				setResolvedImageSrc(photos[0]);
				setImgOk(true);
			}
		};

		void loadThumbnail();

		return () => {
			isCancelled = true;
		};
	}, [category.id, category.has_photo]);

	const media = (
		<div
			className={cn('relative w-full overflow-hidden rounded-2xl', sz.media)}
		>
			{!imgLoaded && (
				<div className="absolute inset-0 animate-pulse rounded-xl bg-gray-200" />
			)}

			{imgOk ? (
				<Image
					src={resolvedImageSrc || '/placeholder.avif'}
					alt={category.title}
					fill
					className={cn(
						'object-cover transition-opacity duration-300',
						imgLoaded ? 'opacity-100' : 'opacity-0'
					)}
					sizes="(max-width: 768px) 50vw, 25vw"
					onLoad={() => setImgLoaded(true)}
					onError={() => {
						setImgOk(false);
						setImgLoaded(true);
					}}
					priority={false}
				/>
			) : (
				<div
					className={cn(
						'absolute inset-0 rounded-xl bg-gradient-to-tr',
						g,
						'opacity-90'
					)}
				/>
			)}

			{variant === 'overlay' && (
				<div className="absolute inset-x-0 bottom-0 rounded-b-xl bg-gradient-to-t from-black/70 via-black/30 to-transparent px-1 pb-2 pt-8">
					<h3
						className={cn(
							'line-clamp-1 font-balsamiqSans text-center font-semibold text-white drop-shadow',
							sz.title
						)}
					>
						{category.title}
					</h3>
				</div>
			)}
		</div>
	);

	const titleBelow =
		variant === 'below' ? (
			<div className="mt-1.5">
				<h3 className={cn('text-center font-balsamiqSans font-semibold text-textGray', sz.title)}>
					{category.title}
				</h3>
			</div>
		) : null;

	return (
		<div
			onClick={onClick}
			className={cn(
				'stagger-in w-full select-none rounded-[22px] border border-white/90 bg-white/90 shadow-[0_8px_20px_rgba(60,83,154,0.12)] backdrop-blur transition',
				'hover:-translate-y-0.5 hover:shadow-[0_16px_28px_rgba(60,83,154,0.18)] focus:outline-none focus:ring-2 focus:ring-primary/50',
				active && 'ring-2 ring-mainPurple',
				sz.pad,
				className
			)}
			aria-label={category.title}
		>
			{media}
			{titleBelow}
		</div>
	);
}

export default function CategoryCard(props: CategoryCardProps) {
	const { href, ...rest } = props;

	if (href) {
		return (
			<Link href={href} className="block">
				<CardInner {...rest} />
			</Link>
		);
	}
	return <CardInner {...rest} />;
}
