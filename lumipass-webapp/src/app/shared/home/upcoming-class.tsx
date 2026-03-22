'use client';

import { Button, Badge } from 'rizzui';
import { useRouter } from '@/i18n/routing';
import { routes } from '@/config/routes';
import { useTranslations } from 'next-intl';
import type { UpcomingClass } from '@/types';
import { formatDateTime } from '@/utils/format-dateTime';
import Image from 'next/image';
import {
	PiBuildingApartmentDuotone,
	PiUserDuotone,
	PiMapPinAreaDuotone,
} from 'react-icons/pi';
import toast from 'react-hot-toast';

interface UpcomingClassProps {
	upcomingClass: UpcomingClass;
}

export default function UpcomingClass({ upcomingClass }: UpcomingClassProps) {
	const t = useTranslations('Home');
	const router = useRouter();
	if (!upcomingClass) return null;

	// Prefer the CONFIRMED booking; fallback to the first related booking
	const related = Array.isArray(upcomingClass.related_bookings)
		? (upcomingClass.related_bookings as any[])
		: [];
	const confirmed = related.find((b) => b?.booking_status === 'CONFIRMED');
	const selectedBooking = confirmed ?? related[0] ?? null;
	const bookingId: string | null = selectedBooking?.id ?? null;
	const chargedAmount = selectedBooking?.charged_coin_amount;
	const isTrialBooking = Boolean(selectedBooking?.is_trial_booking);

	const child =
		upcomingClass.for_child ?? ({} as NonNullable<UpcomingClass['for_child']>);
	const childFullName =
		`${child.first_name ?? ''} ${child.last_name ?? ''}`.trim();

	const handleViewAll = () => router.push(routes.schedules);
	const handleViewDetails = () => {
		if (!bookingId) {
			toast.error(t('NoBookingId'));
			return;
		}
		router.push(routes.scheduleDetails(bookingId));
	};
	return (
		<div className="px-4 py-5">
			{/* Header: “Classes today” + View all */}
			<div className="mb-3 flex items-center justify-between">
				<div className="rounded-xl bg-mainPurple/10 px-3 py-1 text-sm font-semibold text-mainPurple">
					{t('ClassesToday', { count: upcomingClass.count ?? 1 })}
				</div>
				<button
					onClick={handleViewAll}
					className="flex items-center text-sm font-bold text-mainPurple"
				>
					{t('ViewAll')}
				</button>
			</div>

			{/* Card */}
			<div className="stagger-in overflow-hidden rounded-[22px] border border-white/90 bg-white/90 px-3 py-4 shadow-[0_8px_20px_rgba(60,83,154,0.12)] backdrop-blur">
				{/* Top row: Category + Time */}
				<div className="mb-1.5 flex flex-wrap items-center justify-between gap-2">
					<Badge
						variant="flat"
						size="sm"
						className="flex items-center gap-1 border border-mainPurple/20 bg-mainPurple/10 text-mainPurple"
					>
						<PiUserDuotone className="size-3 text-inherit" />
						<p className="truncate font-medium">{childFullName}</p>
					</Badge>
					<Badge variant="flat" size="sm" className="border border-slate-100 bg-slate-50 text-textGray">
						{formatDateTime(
							upcomingClass.start_time,
							upcomingClass.end_time,
							'time'
						)}
					</Badge>
					{typeof chargedAmount === 'number' && (
						<Badge
							variant="flat"
							size="sm"
							className={
								isTrialBooking
									? 'border border-emerald-200 bg-emerald-50 text-emerald-700'
									: 'border border-orange-200 bg-orange-50 text-orange-700'
							}
						>
							{isTrialBooking ? t('TrialCharge') : t('FullCharge')}: {chargedAmount}
							<Image
								src="/icons/coin.svg"
								alt="Coin"
								width={12}
								height={12}
								className="ml-1"
							/>
						</Badge>
					)}
				</div>

				{/* Title */}
				<h3 className="font-aristotelica-demibold mb-3 text-lg font-bold text-textGray">
					{upcomingClass.class_name}
				</h3>

				{/* Branch */}
				<div className="mb-2 flex flex-wrap items-center gap-2 text-xs">
					<div className="flex items-center gap-1.5 rounded-md border border-violet-100 bg-violet-50 px-2 py-1 text-violet-700">
						<PiBuildingApartmentDuotone className="inline size-4 text-inherit" />
						{upcomingClass.branch_name}
					</div>
				</div>

				{/* Address */}
				{!!upcomingClass.branch_address && (
					<div className="mb-4 flex items-start gap-2 text-[11px] text-indigo-700">
						<PiMapPinAreaDuotone className="mt-0.5 size-4" />
						<p className="line-clamp-2">{upcomingClass.branch_address}</p>
					</div>
				)}

				{/* CTA */}
				<Button
					onClick={handleViewDetails}
					className="w-full rounded-2xl bg-mainPurple py-4 font-semibold text-white shadow-[0_8px_20px_rgba(166,82,199,0.3)] hover:brightness-95"
				>
					{t('ViewDetails')}
				</Button>
			</div>
		</div>
	);
}
