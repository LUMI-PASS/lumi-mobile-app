'use client';

import { useEffect, useState } from 'react';
import { Button, Empty, Loader, SearchNotFoundIcon } from 'rizzui';
import { useDrawer } from '@/app/shared/drawer-views/use-drawer';
import { PiCaretLeftBold } from 'react-icons/pi';
import DateSlider from '@/components/ui/date-slider';
import TimeSlotCard from '@/components/ui/widgets/time-slot-card';
import { getClassAvailability, createBooking } from '@/services/api';
import { format, addDays } from 'date-fns';
import { BookingData, BookingViewProps } from '@/types';
import { routes } from '@/config/routes';
import { useRouter } from '@/i18n/routing';
import CheckNetwork from '@/app/[locale]/(other-pages)/check-network/check-network';
import CloseDrawerButton from '@/components/ui/buttons/close-drawer-button';
import SelectChildView from './select-child-view';
import { useTranslations } from 'next-intl';
import Image from 'next/image';
export default function BookingView({
	classId,
	childId,
	initialFromDate,
	initialToDate,
	eligibilityData, // ← now available here
}: BookingViewProps) {
	const { closeDrawer, openDrawer } = useDrawer();
	const [isLoading, setIsLoading] = useState(true);
	const [error, setError] = useState<string | null>(null);
	const [bookingData, setBookingData] = useState<BookingData | null>(null);
	const [selectedSlot, setSelectedSlot] = useState<string | null>(null);
	const [isBooking, setIsBooking] = useState(false);
	const router = useRouter();

	const [selectedDate, setSelectedDate] = useState(new Date());
	const [fromDate, setFromDate] = useState(initialFromDate);
	const [toDate, setToDate] = useState(initialToDate);
	const t = useTranslations('Drawers.Booking');

	const selectedChildData = eligibilityData.children.find(
		(child) => child.id === childId
	);
	const expectedCharge =
		typeof selectedChildData?.effective_class_price === 'number'
			? selectedChildData.effective_class_price
			: selectedChildData?.will_use_trial &&
				  typeof eligibilityData.class_trial_price === 'number'
				? eligibilityData.class_trial_price
				: eligibilityData.class_price;
	const willUseTrial = Boolean(selectedChildData?.will_use_trial);
	const canAffordBooking =
		typeof expectedCharge === 'number'
			? eligibilityData.wallet_balance >= expectedCharge
			: true;

	// Filter time slots for selected day
	const filteredTimeSlots =
		bookingData?.time_slots?.filter((slot) => {
			const slotDate = slot.for_date.includes('T')
				? slot.for_date.split('T')[0]
				: slot.for_date;
			return slotDate === format(selectedDate, 'yyyy-MM-dd');
		}) || [];

	useEffect(() => {
		let alive = true;

		const fetchAvailability = async () => {
			setIsLoading(true);
			setError(null);
			try {
				const response = await getClassAvailability(
					classId,
					childId,
					fromDate,
					toDate
				);
				if (alive) setBookingData(response.data);
			} catch (err: any) {
				if (alive) {
					setError(err.message || 'Failed to fetch availability data');
					// console.error('Error fetching availability:', err);
				}
			} finally {
				if (alive) setIsLoading(false);
			}
		};

		fetchAvailability();
		return () => {
			alive = false;
		};
	}, [classId, childId, fromDate, toDate]);

	const handleDateSelect = (date: Date) => {
		setSelectedDate(date);
		const prevDate = format(addDays(date, -15), 'yyyy-MM-dd');
		const nextDate = format(addDays(date, 15), 'yyyy-MM-dd');
		setFromDate(prevDate);
		setToDate(nextDate);
	};

	const handleSlotSelect = (scheduleId: string) => {
		setSelectedSlot((prev) => (prev === scheduleId ? null : scheduleId));
	};

	const handleBook = async () => {
		if (!selectedSlot || !canAffordBooking) return;
		setIsBooking(true);
		setError(null);

		try {
			const response = await createBooking({
				schedule_id: selectedSlot,
				child_id: childId,
				subscription_id: childId,
			});

			closeDrawer();
			setTimeout(() => {
				router.push(routes.bookingSuccess(response.data.id));
			}, 350);
		} catch (err: any) {
			setError(err.message || 'Failed to book class');
			// console.error('Booking error:', err);
		} finally {
			setIsBooking(false);
		}
	};

	const handleBack = () => {
		// Close current drawer first, then reopen the previous one with the same data
		closeDrawer();
		setTimeout(() => {
			openDrawer({
				view: (
					<SelectChildView
						eligibilityData={eligibilityData} // ← reuse the same dataset
						initialSelectedChildId={childId} // ← nice UX: keep selection
					/>
				),
				placement: 'bottom',
				height: '75vh',
			});
		}, 650);
	};

	return (
		<div className="flex h-full flex-col px-4 pb-6">
			{/* Header */}
			<div className="relative mb-6 flex items-center">
				<button
					onClick={handleBack}
					className="absolute bottom-0 left-0 top-0 mb-1 text-textGray"
				>
					<PiCaretLeftBold size={20} />
				</button>
				<h2 className="flex-1 text-center font-balsamiqSans text-2xl text-textGray">
					{t('Title')}
				</h2>
				<CloseDrawerButton onClick={closeDrawer} />
			</div>

			{error ? (
				<CheckNetwork />
			) : (
				<div className="flex h-full flex-col">
					{typeof expectedCharge === 'number' && (
						<div className="mb-3 rounded-2xl border border-mainPurple/15 bg-white/80 p-3 shadow-sm">
							<div className="flex items-center justify-between">
								<p className="text-xs font-semibold text-textGray">
									{t('ExpectedCharge')}
								</p>
								<div className="flex items-center rounded-lg bg-amber-100 px-2 py-0.5 text-sm font-bold text-amber-700">
									{expectedCharge}
									<Image
										src="/icons/coin.svg"
										alt="Coin"
										width={16}
										height={16}
										className="ml-1"
									/>
								</div>
							</div>
							<p className="mt-1 text-[11px] font-medium text-mainPurple">
								{willUseTrial ? t('UsesTrialPrice') : t('UsesFullPrice')}
							</p>
							{!canAffordBooking && (
								<p className="mt-1 text-[11px] font-semibold text-red-500">
									{t('InsufficientBalance')}
								</p>
							)}
						</div>
					)}

					<DateSlider
						selectedDate={selectedDate}
						onDateSelect={handleDateSelect}
					/>

					{isLoading ? (
						<div className="flex flex-grow items-center justify-center">
							<Loader size="lg" />
						</div>
					) : (
						<div className="mb-6 flex-grow overflow-y-auto px-2">
							{filteredTimeSlots.length === 0 ? (
								<Empty
									image={<SearchNotFoundIcon className="h-44 w-full" />}
									text={t('NoSlotsForDate')}
								/>
							) : (
								<div className="grid grid-cols-2 gap-5 py-2">
									{filteredTimeSlots.map((slot) => (
										<TimeSlotCard
											key={slot.schedule_id}
											scheduleId={slot.schedule_id}
											startTime={slot.start_time}
											endTime={slot.end_time}
											emptySeats={slot.empty_seats}
											isBookingConflict={slot.is_booking_conflict}
											isAvailable={slot.is_available}
											isSelected={selectedSlot === slot.schedule_id}
											onSelect={handleSlotSelect}
										/>
									))}
								</div>
							)}
						</div>
					)}

					<div className="mt-auto pb-6">
						<Button
							onClick={handleBook}
							size="lg"
							className="w-full rounded-2xl bg-mainPurple py-7 font-bold text-white shadow-[0_10px_22px_rgba(166,82,199,0.32)] disabled:opacity-50 disabled:hover:bg-mainPurple"
							disabled={!selectedSlot || isBooking || !canAffordBooking}
							isLoading={isBooking}
						>
							{isBooking ? t('Booking') : t('Book')}
						</Button>
					</div>
				</div>
			)}
		</div>
	);
}
