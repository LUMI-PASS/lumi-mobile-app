'use client';

import { useRouter } from '@/i18n/routing';
import cn from '@/utils/class-names';

interface ProfileHeaderProps {
	title: string;
	href?: string;
	isRequiredPage?: boolean;
	compact?: boolean;
}

export default function ProfileHeader({
	title,
	href,
	isRequiredPage,
	compact = false,
}: ProfileHeaderProps) {
	const router = useRouter();
	const handleBackClick = () => {
		if (href) {
			router.push(href);
		} else {
			router.back();
		}
	};

	return (
		<div
			className={cn(
				'sticky top-0 z-50 px-4 backdrop-blur',
				compact ? 'pb-3 pt-4' : 'pb-4 pt-6'
			)}
		>
			<div
				className={cn(
					'app-surface-soft flex items-center gap-3 px-3',
					compact ? 'py-2' : 'py-2.5'
				)}
			>
				<button
					type="button"
					className={cn(
						'grid size-9 place-content-center rounded-xl bg-mainPurple/10 text-mainPurple transition active:scale-95',
						isRequiredPage ? 'invisible' : 'visible'
					)}
					onClick={handleBackClick}
				>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						fill="none"
						viewBox="0 0 24 24"
						strokeWidth="2.5"
						stroke="currentColor"
						className="size-4"
					>
						<path
							strokeLinecap="round"
							strokeLinejoin="round"
							d="M15.75 19.5 8.25 12l7.5-7.5"
						/>
					</svg>
				</button>

				<h1
					className={cn(
						'flex-1 text-center font-balsamiqSans leading-tight text-textGray',
						compact
							? 'text-[19px] font-semibold md:text-[21px]'
							: 'text-[22px] font-bold md:text-2xl'
					)}
				>
					{title}
				</h1>

				<span className="size-9" aria-hidden />
			</div>
		</div>
	);
}
