// 'use client';

// import { Button } from 'rizzui';
// import { useRouter } from '@/i18n/routing';
// import { ScheduleCardProps } from '@/types';
// import { routes } from '@/config/routes';
// import { formatDateTime } from '@/utils/format-dateTime';
// import { useTranslations } from 'next-intl';
// import { toast } from 'react-hot-toast';

// export default function ScheduleCard({ schedule }: ScheduleCardProps) {
// 	const t = useTranslations('Schedules');
// 	const router = useRouter();

// 	const classData = schedule?.class ?? {};

// 	// Prefer the CONFIRMED booking; fallback to the first related booking
// 	const related = Array.isArray(schedule.related_bookings)
// 		? (schedule.related_bookings as any[])
// 		: [];

// 	const confirmed = related.find((b) => b?.booking_status === 'CONFIRMED');
// 	const bookingId: string | null = confirmed?.id ?? related[0]?.id ?? null;

// 	const handleViewDetails = () => {
// 		if (!bookingId) {
// 			toast.error(t('NoBookingId', { default: 'Booking data not found.' }));
// 			return;
// 		}
// 		// We pass the booking id to the details page now
// 		router.push(routes.scheduleDetails(bookingId));
// 	};

// 	return (
// 		<div className="mb-4 rounded-2xl bg-white p-4 shadow-sm">
// 			{/* Class Title */}
// 			<h3 className="mb-1 font-balsamiqSans text-xl font-bold text-mainPurple">
// 				{classData.title || '—'}
// 			</h3>

// 			{/* Short description */}
// 			<p className="mb-2 line-clamp-2 text-xs font-normal text-textGray">
// 				{classData.description || t('NoDescription')}
// 			</p>

// 			{/* Time • Date */}
// 			<div className="mb-1 flex items-center gap-1 text-xs text-lightGray">
// 				<span className="text-inherit">
// 					{formatDateTime(schedule.for_date, 'date')}
// 				</span>
// 				{' • '}
// 				<span>{schedule.start_time}</span>
// 			</div>

// 			{/* Branch / location (string from API) */}
// 			<p className="mb-4 truncate text-sm text-mainPurple">
// 				{classData.branch || t('NoAddress')}
// 			</p>

// 			{/* View Details */}
// 			<Button
// 				onClick={handleViewDetails}
// 				className="hover:bg-lavender/90 w-full rounded-xl bg-mainPurple/10 py-4 font-medium text-mainPurple"
// 			>
// 				{t('ViewDetails')}
// 			</Button>
// 		</div>
// 	);
// }

'use client';

import { Badge, Button } from 'rizzui';
import { useRouter } from '@/i18n/routing';
import { routes } from '@/config/routes';
import { formatDateTime } from '@/utils/format-dateTime';
import { useTranslations } from 'next-intl';
import { toast } from 'react-hot-toast';
import type { ScheduleCardProps } from '@/types';
import {
	PiBuildingApartmentDuotone,
	PiUserDuotone,
} from 'react-icons/pi';
import Image from 'next/image';

export default function ScheduleCard({ schedule }: ScheduleCardProps) {
	const t = useTranslations('Schedules');
	const router = useRouter();

	const classData = schedule?.class ?? {};

	// Prefer the CONFIRMED booking; fallback to the first related booking
	const related = Array.isArray(schedule.related_bookings)
		? (schedule.related_bookings as any[])
		: [];
	const confirmed = related.find((b) => b?.booking_status === 'CONFIRMED');
	const selectedBooking = confirmed ?? related[0] ?? null;
	const bookingId: string | null = selectedBooking?.id ?? null;
	const chargedAmount = selectedBooking?.charged_coin_amount;
	const isTrialBooking = Boolean(selectedBooking?.is_trial_booking);

	const child = schedule?.for_child ?? {};
	const childFullName =
		`${child.first_name ?? ''} ${child.last_name ?? ''}`.trim() ||
		t('NoNameProvided');

	const handleViewDetails = () => {
		if (!bookingId) {
			toast.error(t('NoBookingId'));
			return;
		}
		router.push(routes.scheduleDetails(bookingId));
	};

	return (
		<div className="stagger-in mb-6 overflow-hidden rounded-[22px] border border-white/90 bg-white/90 px-3 py-4 shadow-[0_8px_20px_rgba(60,83,154,0.12)] backdrop-blur">
			{/* Top row: Category + Time */}
			<div className="mb-1.5 flex flex-wrap items-center justify-between gap-2">
				<Badge
					variant="flat"
					size="sm"
					rounded="lg"
					className="flex items-center gap-1 border border-indigo-100 bg-indigo-50 text-indigo-900"
				>
					{/* <PiUserDuotone className="size-3 text-inherit" />
					<p className="truncate font-medium">{childFullName}</p> */}
					{formatDateTime(schedule.for_date, 'date')}
				</Badge>
				<Badge variant="flat" size="sm" rounded='lg' className="border border-slate-100 bg-slate-50 text-textGray">
					{formatDateTime(schedule.start_time, schedule.end_time, 'time')}
				</Badge>
				{typeof chargedAmount === 'number' && (
					<Badge
						variant="flat"
						size="sm"
						rounded="lg"
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
			<h3 className="mb-2 font-balsamiqSans text-lg font-bold text-textGray">
				{classData.title || '—'}
			</h3>

			{/* Child */}
			<div className="mb-2 flex items-center gap-1.5">
				<Badge size='sm' className="flex items-center gap-1.5 rounded-md border border-indigo-100 bg-indigo-50 px-2 py-1 text-indigo-900">
					<PiUserDuotone className="size-3 text-inherit" />
					<p className="truncate font-semibold text-indigo-900">
						{childFullName}
					</p>
				</Badge>
			</div>

			{/* Branch name chip (string from API) */}
			{classData.branch && (
				<div className="mb-4 flex flex-wrap items-center gap-2 text-xs">
					<div className="flex items-center gap-1.5 rounded-md border border-violet-100 bg-violet-50 px-2 py-1 text-violet-700">
						<PiBuildingApartmentDuotone className="inline size-4 text-inherit" />
						{classData.branch}
					</div>
				</div>
			)}

			{/* CTA */}
      <Button
        size='md'
				onClick={handleViewDetails}
				className="w-full rounded-2xl bg-mainPurple py-4 text-sm font-semibold text-white shadow-[0_8px_20px_rgba(166,82,199,0.3)] hover:brightness-95"
			>
				{t('ViewDetails')}
			</Button>
		</div>
	);
}
