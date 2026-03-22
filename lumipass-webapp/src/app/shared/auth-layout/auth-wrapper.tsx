'use client';

import { useRouter } from '@/i18n/routing';
import cn from '@/utils/class-names';
import Image from 'next/image';

export default function AuthWrapper({
	children,
	title,
	backgroundColor = 'bg-grayBg',
}: {
	children: React.ReactNode;
	title: React.ReactNode;
	backgroundColor?: string;
}) {
	const router = useRouter();

	return (
		<div
			className={cn(
				'relative flex min-h-screen max-w-full flex-col items-center justify-center overflow-x-hidden px-4 py-8',
				backgroundColor
			)}
		>
			<div className="pointer-events-none absolute inset-0">
				<div className="absolute left-[-30px] top-20 h-24 w-24 rounded-full bg-mainPurple/10 blur-lg" />
				<div className="absolute right-[-26px] top-36 h-20 w-20 rounded-full bg-mainPink/20 blur-md" />
				<div className="absolute bottom-20 left-10 h-16 w-16 rounded-full bg-mainYellow/25 blur-sm" />
			</div>

			<div className="relative mb-6 flex w-full max-w-[540px] items-start justify-between">
				<button
					type="button"
					className="grid size-10 place-content-center rounded-2xl bg-white/85 text-mainPurple shadow-[0_8px_18px_rgba(60,83,154,0.16)] backdrop-blur"
					onClick={() => router.back()}
				>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						fill="none"
						viewBox="0 0 24 24"
						strokeWidth="3"
						stroke="currentColor"
						className="pointer-events-none size-4"
					>
						<path
							strokeLinecap="round"
							strokeLinejoin="round"
							d="M15.75 19.5 8.25 12l7.5-7.5"
						/>
					</svg>
				</button>
				<Image
					src="/auth/confetti.png"
					alt="Confetti"
					width={120}
					height={120}
					className="rounded-2xl object-cover opacity-90"
				/>
			</div>

			<div className="relative flex w-full max-w-[540px] flex-1 flex-col items-center px-2">
				<div className="absolute left-[70%] top-48">
					<div className="h-4 w-4 rounded-full bg-mainPink"></div>
				</div>
				<div className="absolute left-[20%] top-16">
					<div className="h-3 w-3 rounded-full bg-mainPink"></div>
				</div>
				<div className="absolute right-8 top-52">
					<div className="h-8 w-8 rounded-full bg-mainPurple/80"></div>
				</div>
				{title ? (
					<div className="mb-7 w-full rounded-[28px] bg-white/70 px-5 py-6 shadow-[0_10px_24px_rgba(60,83,154,0.14)] backdrop-blur">
						{title}
					</div>
				) : null}

				<div className="w-full rounded-[28px] bg-white/78 p-5 shadow-[0_10px_24px_rgba(60,83,154,0.14)] backdrop-blur">
					{children}
				</div>
			</div>
		</div>
	);
}
