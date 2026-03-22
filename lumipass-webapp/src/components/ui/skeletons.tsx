'use client';

import cn from '@/utils/class-names';

export function HeaderSkeleton({ className = ' ' }) {
	return (
		<div
			className={cn(
				'flex items-center justify-center px-4 pb-5 pt-6',
				className
			)}
		>
			<div className="flex items-center">
				<div className="h-8 w-8 animate-pulse rounded-full bg-gray-200"></div>
				<div className="ml-2 flex flex-col">
					<div className="h-4 w-20 animate-pulse rounded bg-gray-200"></div>
					<div className="mt-1 h-4 w-24 animate-pulse rounded bg-gray-200"></div>
				</div>
			</div>
			<div className="ml-auto flex items-center">
				<div className="mr-2 h-8 w-8 animate-pulse rounded-full bg-gray-200"></div>
				<div className="h-8 w-8 animate-pulse rounded-full bg-gray-200"></div>
			</div>
		</div>
	);
}
export function CategorySkeleton({ className = '' }) {
	return (
		<div
			className={`min-w-[160px] overflow-hidden rounded-xl bg-white p-1 shadow-sm ${className}`}
		>
			<div className="h-24 w-full animate-pulse rounded-xl bg-gray-200"></div>
			<div className="mx-auto mt-2 h-4 w-20 animate-pulse rounded bg-gray-200"></div>
		</div>
	);
}

export function ClassCardSkeleton({ variant = 'vertical', className = '' }) {
	if (variant === 'horizontal') {
		return (
			<div
				className={`overflow-hidden rounded-xl bg-white shadow-sm ${className}`}
			>
				<div className="flex">
					<div className="h-24 w-1/3 animate-pulse bg-gray-200"></div>
					<div className="w-2/3 p-3">
						<div className="h-3 w-24 animate-pulse rounded bg-gray-200"></div>
						<div className="mt-2 h-4 w-40 animate-pulse rounded bg-gray-200"></div>
						<div className="mt-3 flex items-center justify-between">
							<div className="h-3 w-16 animate-pulse rounded bg-gray-200"></div>
							<div className="h-4 w-10 animate-pulse rounded bg-gray-200"></div>
						</div>
					</div>
				</div>
			</div>
		);
	}

	return (
		<div
			className={`overflow-hidden rounded-2xl bg-white p-2 shadow-sm ${className}`}
		>
			<div className="h-36 animate-pulse rounded-xl bg-gray-200"></div>
			<div className="px-1 pt-2">
				<div className="h-3 w-24 animate-pulse rounded bg-gray-200"></div>
				<div className="mt-2 h-4 w-32 animate-pulse rounded bg-gray-200"></div>
				<div className="mt-1 h-3 w-full animate-pulse rounded bg-gray-200"></div>
				<div className="mt-2 flex items-center justify-between">
					<div className="h-3 w-20 animate-pulse rounded bg-gray-200"></div>
					<div className="h-6 w-12 animate-pulse rounded bg-gray-200"></div>
				</div>
			</div>
		</div>
	);
}

export function UpcomingClassSkeleton({ className = '' }) {
	return (
		<div className={`px-4 py-5 ${className}`}>
			<div className="mb-2 flex items-center justify-between gap-2">
				<div className="h-4 w-24 animate-pulse rounded bg-gray-200" />
				<div className="h-4 w-20 animate-pulse rounded bg-gray-200" />
			</div>
			<div className="mb-4 overflow-hidden rounded-2xl bg-white px-3 py-4 shadow-sm">
				<div className="mb-2 flex items-center justify-between gap-2">
					<div className="h-5 w-24 animate-pulse rounded bg-gray-100" />
					<div className="h-5 w-20 animate-pulse rounded bg-gray-100" />
				</div>
				<div className="mb-2 h-6 w-3/4 animate-pulse rounded bg-gray-200" />
				<div className="mb-2 flex items-center gap-2">
					<div className="h-5 w-5 animate-pulse rounded bg-gray-100" />
					<div className="h-4 w-32 animate-pulse rounded bg-gray-100" />
				</div>
				<div className="mb-2 h-5 w-40 animate-pulse rounded bg-gray-100" />
				<div className="mb-4 h-3 w-2/3 animate-pulse rounded bg-gray-100" />
				<div className="h-10 w-full animate-pulse rounded-xl bg-gray-200" />
			</div>
		</div>
	);
}

export function BranchCardSkeleton({ className = '' }) {
	return (
		<div
			className={`overflow-hidden rounded-2xl bg-white p-2 shadow-sm ${className}`}
		>
			<div className="h-36 animate-pulse rounded-xl bg-gray-200" />
			<div className="px-1 pt-2">
				<div className="h-3 w-20 animate-pulse rounded bg-gray-200" />
				<div className="mt-2 h-4 w-40 animate-pulse rounded bg-gray-200" />
				<div className="mt-1 h-3 w-full animate-pulse rounded bg-gray-200" />
				<div className="mt-2 flex items-center justify-between">
					<div className="h-3 w-24 animate-pulse rounded bg-gray-200" />
					<div className="h-6 w-16 animate-pulse rounded bg-gray-200" />
				</div>
			</div>
		</div>
	);
}

export function ListGridSkeleton({
	variant = 'classes',
	count = 3,
}: {
	variant?: 'classes' | 'centers';
	count?: number;
}) {
	const Item =
		variant === 'classes'
			? (props: any) => <ClassCardSkeleton variant="vertical" {...props} />
			: BranchCardSkeleton;

	return (
		<div className="grid grid-cols-1 gap-4 md:grid-cols-2">
			{Array.from({ length: count }).map((_, i) => (
				<Item key={i} />
			))}
		</div>
	);
}

export function InlineLoaderSkeleton({
	variant = 'classes',
}: {
	variant?: 'classes' | 'centers';
}) {
	const Item =
		variant === 'classes'
			? (props: any) => <ClassCardSkeleton variant="vertical" {...props} />
			: BranchCardSkeleton;

	return (
		<div className="grid grid-cols-1 gap-4 py-4 md:grid-cols-2">
			<Item />
			<Item />
		</div>
	);
}

export function BranchDetailsSkeleton() {
	return (
		<div className="relative flex min-h-screen flex-col bg-white">
			<div className="relative h-72 w-full shadow-sm">
				<div className="h-full w-full animate-pulse bg-gray-200" />
			</div>

			<div className="flex-1 overflow-y-auto px-2 pb-20">
				<div className="my-5 flex flex-col items-start gap-4 px-2">
					<div className="flex w-full items-center justify-start gap-3">
						<div className="h-10 w-10 animate-pulse rounded-xl bg-gray-200" />
						<div className="flex-1">
							<div className="h-4 w-28 animate-pulse rounded bg-gray-200" />
							<div className="mt-2 h-4 w-48 animate-pulse rounded bg-gray-200" />
						</div>
					</div>

					<div className="flex w-full items-center justify-start gap-3">
						<div className="h-10 w-10 animate-pulse rounded-xl bg-gray-200" />
						<div className="flex-1">
							<div className="h-4 w-24 animate-pulse rounded bg-gray-200" />
							<div className="mt-2 flex items-center gap-2">
								<div className="h-6 w-28 animate-pulse rounded-lg bg-gray-200" />
								<div className="h-6 w-20 animate-pulse rounded-lg bg-gray-200" />
							</div>
						</div>
					</div>
				</div>

				<div className="flex flex-col items-start gap-2 px-2">
					<div className="h-5 w-32 animate-pulse rounded bg-gray-200" />
					<div className="mt-1 h-4 w-full animate-pulse rounded bg-gray-200" />
					<div className="mt-2 h-4 w-5/6 animate-pulse rounded bg-gray-200" />
					<div className="mt-2 h-4 w-4/6 animate-pulse rounded bg-gray-200" />
				</div>

				<div className="mt-6 px-2">
					<div className="mb-3 h-5 w-24 animate-pulse rounded bg-gray-200" />
					<div className="grid grid-cols-1 gap-4 md:grid-cols-2">
						<div className="h-64 animate-pulse rounded-2xl bg-gray-100" />
						<div className="h-64 animate-pulse rounded-2xl bg-gray-100" />
					</div>
				</div>
			</div>
		</div>
	);
}

export function ScheduleCardSkeleton() {
	return (
		<div className="mb-4 overflow-hidden rounded-2xl bg-white px-3 py-4 shadow-sm">
			<div className="mb-2 flex items-center justify-between gap-2">
				<div className="h-5 w-24 animate-pulse rounded bg-gray-100" />
				<div className="h-5 w-20 animate-pulse rounded bg-gray-100" />
			</div>
			<div className="mb-2 h-6 w-3/4 animate-pulse rounded bg-gray-200" />
			<div className="mb-2 flex items-center gap-2">
				<div className="h-5 w-5 animate-pulse rounded bg-gray-100" />
				<div className="h-4 w-32 animate-pulse rounded bg-gray-100" />
			</div>
			<div className="mb-4 h-5 w-40 animate-pulse rounded bg-gray-100" />
			<div className="h-8 w-full animate-pulse rounded-xl bg-gray-200" />
		</div>
	);
}

export function SchedulesListSkeleton({ count = 4 }: { count?: number }) {
	return (
		<div>
			{Array.from({ length: count }).map((_, i) => (
				<ScheduleCardSkeleton key={i} />
			))}
		</div>
	);
}

export function TicketDetailsSkeleton() {
	return (
		<div className="relative flex min-h-screen flex-col bg-white">
			{/* Hero */}
			<div className="relative h-72 w-full">
				<div className="h-full w-full animate-pulse bg-gray-200" />
				<div className="pointer-events-none absolute inset-0 bg-gradient-to-b from-black/10 via-black/30 to-black/70" />
				<div className="absolute left-4 top-4 h-9 w-9 rounded-full bg-white/30 backdrop-blur" />
				<div className="absolute bottom-3 left-4 right-4">
					<div className="h-7 w-3/4 animate-pulse rounded bg-white/50" />
				</div>
			</div>

			{/* Body */}
			<div className="flex-1 overflow-y-auto px-4 pb-40">
				<div className="mb-3 mt-5 flex flex-col items-start gap-5 px-2">
					{/* Reserved For */}
					<div className="flex items-center gap-3">
						<div className="h-10 w-10 rounded-xl bg-purple-100" />
						<div>
							<div className="mb-1 h-3 w-24 animate-pulse rounded bg-gray-200" />
							<div className="h-4 w-40 animate-pulse rounded bg-gray-200" />
						</div>
					</div>

					{/* Date */}
					<div className="flex items-center gap-3">
						<div className="h-10 w-10 rounded-xl bg-purple-100" />
						<div>
							<div className="mb-1 h-3 w-16 animate-pulse rounded bg-gray-200" />
							<div className="h-4 w-48 animate-pulse rounded bg-gray-200" />
						</div>
					</div>

					{/* Time */}
					<div className="flex items-center gap-3">
						<div className="h-10 w-10 rounded-xl bg-purple-100" />
						<div>
							<div className="mb-1 h-3 w-14 animate-pulse rounded bg-gray-200" />
							<div className="h-4 w-32 animate-pulse rounded bg-gray-200" />
						</div>
					</div>

					{/* Price & Location */}
					<div className="flex w-full flex-col items-center justify-center gap-5">
						<div className="flex w-full items-center gap-3">
							<div className="h-10 w-10 rounded-xl bg-purple-100" />
							<div>
								<div className="mb-1 h-3 w-14 animate-pulse rounded bg-gray-200" />
								<div className="h-6 w-24 animate-pulse rounded bg-orange-100" />
							</div>
						</div>
						<div className="flex w-full items-center gap-3">
							<div className="h-10 w-10 rounded-xl bg-purple-100" />
							<div>
								<div className="mb-1 h-3 w-16 animate-pulse rounded bg-gray-200" />
								<div className="h-4 w-40 animate-pulse rounded bg-gray-200" />
							</div>
						</div>
					</div>
				</div>

				{/* Build Route */}
				<div className="px-2">
					<div className="h-5 w-28 animate-pulse rounded bg-gray-200" />
				</div>

				{/* About */}
				<div className="mt-4 px-2">
					<div className="mb-2 h-5 w-32 animate-pulse rounded bg-gray-200" />
					<div className="h-4 w-full animate-pulse rounded bg-gray-100" />
					<div className="mt-2 h-4 w-5/6 animate-pulse rounded bg-gray-100" />
					<div className="mt-2 h-4 w-4/6 animate-pulse rounded bg-gray-100" />
				</div>
			</div>

			{/* Sticky CTA */}
			<div className="fixed bottom-[65px] left-0 right-0 px-3 pb-4 pt-4">
				<div className="mx-auto max-w-[75%]">
					<div className="h-12 w-full animate-pulse rounded-xl bg-gray-200" />
				</div>
			</div>
		</div>
	);
}

export function ClassDetailsSkeleton() {
	return (
		<div className="relative flex min-h-screen flex-col bg-white">
			{/* Hero */}
			<div className="relative h-72 w-full">
				<div className="h-full w-full animate-pulse bg-gray-200" />
				<div className="pointer-events-none absolute inset-0 bg-gradient-to-b from-black/10 via-black/25 to-black/60" />
				<div className="absolute left-3 top-3 h-9 w-9 rounded-full bg-white/40 backdrop-blur" />
				<div className="absolute right-3 top-3 h-6 w-28 rounded bg-white/40 backdrop-blur" />
				<div className="absolute bottom-3 left-3 right-3">
					<div className="h-7 w-3/4 animate-pulse rounded bg-white/50" />
				</div>
			</div>

			{/* Body */}
			<div className="flex-1 overflow-y-auto px-4 pb-44">
				{/* chips */}
				<div className="mt-4 flex flex-wrap items-center gap-2">
					<div className="h-6 w-28 animate-pulse rounded bg-gray-100" />
					<div className="h-6 w-24 animate-pulse rounded bg-gray-100" />
					<div className="h-6 w-24 animate-pulse rounded bg-gray-100" />
				</div>

				{/* location */}
				<div className="mt-4 flex items-start gap-3 rounded-2xl border border-gray-100 px-3 py-3">
					<div className="h-8 w-8 rounded-xl bg-indigo-100" />
					<div className="flex-1">
						<div className="mb-2 h-4 w-2/3 animate-pulse rounded bg-gray-100" />
						<div className="h-3 w-4/5 animate-pulse rounded bg-gray-100" />
					</div>
					<div className="h-5 w-16 rounded bg-indigo-100" />
				</div>

				{/* description */}
				<div className="mt-5">
					<div className="mb-2 h-5 w-28 animate-pulse rounded bg-gray-200" />
					<div className="h-4 w-full animate-pulse rounded bg-gray-100" />
					<div className="mt-2 h-4 w-5/6 animate-pulse rounded bg-gray-100" />
					<div className="mt-2 h-4 w-4/6 animate-pulse rounded bg-gray-100" />
				</div>
			</div>

			{/* Sticky CTA */}
			<div className="fixed bottom-[65px] left-0 right-0 bg-gradient-to-t from-white via-white/80 to-transparent px-3 pb-4 pt-4">
				<div className="mx-auto max-w-[75%]">
					<div className="h-12 w-full animate-pulse rounded-2xl bg-gray-200" />
				</div>
			</div>
		</div>
	);
}

// --- WALLET: balance card ---
export function WalletBalanceSkeleton() {
	return (
		<div className="mb-6 rounded-2xl bg-gradient-to-r from-purple-50 to-purple-100 p-4 ring-1 ring-purple-50">
			<div className="flex items-center justify-between">
				<div className="h-4 w-28 animate-pulse rounded bg-gray-100" />
				<div className="flex items-center gap-2">
					<div className="h-7 w-16 animate-pulse rounded bg-gray-100" />
					<div className="h-7 w-7 animate-pulse rounded-full bg-gray-100" />
				</div>
			</div>
		</div>
	);
}

// --- WALLET: package tile (grid item) ---
export function PackageTileSkeleton() {
	return (
		<div className="overflow-hidden rounded-2xl bg-white ring-1 ring-inset ring-gray-100">
			<div className="h-8 w-full bg-gray-300" />
			<div className="p-4">
				<div className="mb-2 h-6 w-20 animate-pulse rounded bg-gray-200" />
				<div className="h-4 w-24 animate-pulse rounded bg-gray-100" />
			</div>
		</div>
	);
}

// --- WALLET: history list ---
export function WalletHistorySkeleton({
	groups = 2,
	itemsPerGroup = 3,
}: {
	groups?: number;
	itemsPerGroup?: number;
}) {
	return (
		<div className="space-y-4">
			{Array.from({ length: groups }).map((_, gi) => (
				<div key={gi}>
					<div className="mb-2 h-4 w-24 animate-pulse rounded bg-gray-200" />
					<div className="space-y-3">
						{Array.from({ length: itemsPerGroup }).map((__, ii) => (
							<div
								key={ii}
								className="flex items-center justify-between rounded-2xl bg-white p-4 shadow-sm ring-1 ring-black/5"
							>
								<div className="flex items-center gap-3">
									<div className="size-12 rounded-xl bg-gray-100" />
									<div>
										<div className="mb-1 h-4 w-24 animate-pulse rounded bg-gray-200" />
										<div className="h-3 w-16 animate-pulse rounded bg-gray-100" />
									</div>
								</div>
								<div className="h-6 w-20 animate-pulse rounded bg-gray-200" />
							</div>
						))}
					</div>
				</div>
			))}
		</div>
	);
}

// --- Generic page title ---
export function PageTitleSkeleton() {
	return <div className="h-8 w-40 animate-pulse rounded bg-gray-200" />;
}

// --- Profile menu row ---
export function ProfileMenuItemSkeleton() {
	return (
		<div className="flex items-center justify-between rounded-2xl border border-gray-100 bg-white px-4 py-4">
			<div className="flex items-center gap-4">
				<div className="h-8 w-8 animate-pulse rounded-xl bg-gray-200" />
				<div>
					<div className="h-4 w-32 animate-pulse rounded bg-gray-200" />
					<div className="mt-1 h-3 w-48 animate-pulse rounded bg-gray-100" />
				</div>
			</div>
			<div className="h-5 w-5 animate-pulse rounded-full bg-gray-200" />
		</div>
	);
}

export function ProfileMenuSkeleton({ rows = 6 }: { rows?: number }) {
	return (
		<div className="flex flex-col gap-y-4">
			{Array.from({ length: rows }).map((_, i) => (
				<ProfileMenuItemSkeleton key={i} />
			))}
		</div>
	);
}

// --- Account form (avatar + 4 fields + button) ---
export function AccountFormSkeleton() {
	return (
		<div className="flex flex-1 flex-col items-center gap-7 px-7 pt-10">
			<div className="h-28 w-28 animate-pulse rounded-full bg-gray-200" />
			{Array.from({ length: 4 }).map((_, i) => (
				<div key={i} className="w-full">
					<div className="mb-2 h-3 w-24 animate-pulse rounded bg-gray-200" />
					<div className="h-14 w-full animate-pulse rounded-xl bg-gray-100" />
				</div>
			))}
			<div className="mt-auto h-12 w-full animate-pulse rounded-2xl bg-gray-200" />
		</div>
	);
}

// --- Child card (list item) ---
export function ChildCardSkeleton() {
	return (
		<div className="relative mb-4 rounded-2xl border border-gray-200 bg-white px-3 py-2">
			<div className="flex items-start gap-3">
				<div className="h-14 w-14 animate-pulse rounded-xl bg-gray-200" />
				<div className="flex-1">
					<div className="h-4 w-40 animate-pulse rounded bg-gray-200" />
					<div className="mt-2 h-3 w-20 animate-pulse rounded bg-gray-100" />
				</div>
				<div className="h-6 w-16 animate-pulse rounded bg-gray-100" />
			</div>
		</div>
	);
}

// --- Stepper skeleton (2 steps) ---
export function StepperSkeleton() {
	return (
		<div className="flex items-center gap-3 px-6 py-4">
			<div className="h-6 w-6 animate-pulse rounded-full bg-gray-200" />
			<div className="h-3 w-28 animate-pulse rounded bg-gray-200" />
			<div className="mx-2 h-0.5 w-10 animate-pulse rounded bg-gray-200" />
			<div className="h-6 w-6 animate-pulse rounded-full bg-gray-200" />
			<div className="h-3 w-28 animate-pulse rounded bg-gray-200" />
		</div>
	);
}

// --- Edit child form/photo placeholder ---
export function EditChildFormSkeleton() {
	return (
		<div className="px-6 pb-6">
			{Array.from({ length: 4 }).map((_, i) => (
				<div key={i} className="mb-5">
					<div className="mb-2 h-3 w-24 animate-pulse rounded bg-gray-200" />
					<div className="h-12 w-full animate-pulse rounded-xl bg-gray-100" />
				</div>
			))}
			<div className="h-12 w-full animate-pulse rounded-2xl bg-gray-200" />
		</div>
	);
}

// --- Attendance record (list) ---
export function AttendanceListSkeleton({ items = 4 }: { items?: number }) {
	return (
		<div className="space-y-4">
			{Array.from({ length: items }).map((_, i) => (
				<div
					key={i}
					className="rounded-xl border border-gray-50 bg-white px-4 py-3 shadow-sm"
				>
					<div className="mb-2 flex items-center justify-between">
						<div className="h-4 w-40 animate-pulse rounded bg-gray-200" />
						<div className="h-5 w-20 animate-pulse rounded bg-gray-100" />
					</div>
					<div className="h-3 w-48 animate-pulse rounded bg-gray-100" />
					<div className="mt-4 flex gap-4">
						<div className="h-3 w-28 animate-pulse rounded bg-gray-100" />
						<div className="h-3 w-36 animate-pulse rounded bg-gray-100" />
					</div>
				</div>
			))}
		</div>
	);
}

export function PackagesDrawerSkeleton({ cards = 6 }: { cards?: number }) {
	return (
		<div className="flex h-full flex-col bg-white px-5 pb-6">
			{/* Header */}
			<div className="relative mb-6 flex items-center">
				<div className="mx-auto h-7 w-40 animate-pulse rounded bg-gray-200" />
				<div className="absolute right-0 h-7 w-7 animate-pulse rounded-full bg-gray-200" />
			</div>

			{/* Scroll area */}
			<div className="flex h-full flex-col overflow-y-auto pb-28">
				{/* Balance card skeleton */}
				<div className="mb-6 rounded-2xl border border-transparent bg-gray-50 p-4 shadow-sm">
					<div className="mb-3 flex items-center justify-between">
						<div className="h-4 w-24 animate-pulse rounded bg-gray-200" />
						<div className="flex items-center gap-2">
							<div className="h-6 w-16 animate-pulse rounded bg-gray-200" />
							<div className="h-7 w-7 animate-pulse rounded-full bg-gray-200" />
						</div>
					</div>
					<div className="h-9 w-full animate-pulse rounded bg-gray-100" />
				</div>

				{/* Packages grid skeleton */}
				<div className="mb-8 grid grid-cols-2 gap-4">
					{Array.from({ length: cards }).map((_, i) => (
						<div
							key={i}
							className="rounded-xl border border-gray-100 p-4 shadow-sm"
						>
							<div className="mb-3 h-4 w-3/4 animate-pulse rounded bg-gray-200" />
							<div className="mb-2 h-3 w-1/2 animate-pulse rounded bg-gray-100" />
							<div className="h-24 w-full animate-pulse rounded-xl bg-gray-100" />
						</div>
					))}
				</div>
			</div>

			{/* Floating button skeleton */}
			<div className="sticky bottom-0 left-0 right-0 z-10 -mx-5 pb-4 pt-10">
				<div className="absolute inset-x-0 -top-10 h-24 bg-gradient-to-t from-white via-white/80 to-transparent" />
				<div className="relative px-5">
					<div className="h-14 w-full animate-pulse rounded-2xl bg-gray-200 shadow-lg" />
				</div>
			</div>
		</div>
	);
}
