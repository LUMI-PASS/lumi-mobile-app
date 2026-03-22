'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { useRouter } from '@/i18n/routing';
import Image from 'next/image';
import { Button } from 'rizzui';
import { PiArrowArcRight, PiArrowLeft } from 'react-icons/pi';
import {
	getBookingById,
	getClassById,
	getClassPhotos,
	getImageUrl,
	cancelBooking,
} from '@/services/api';
import { toast } from 'react-hot-toast';
import { routes } from '@/config/routes';
import { formatDateTime } from '@/utils/format-dateTime';
import CheckNetwork from '@/app/[locale]/(other-pages)/check-network/check-network';
import { useTranslations } from 'next-intl';
import CustomModal from '@/components/ui/custom-modal';
import { TicketDetailsSkeleton } from '@/components/ui/skeletons';
import { openGoogleDirectionsToBranch } from '@/utils/route-builder.google';

export default function TicketDetails() {
	const params = useParams();
	const bookingId = params.ticketId as string;
	const router = useRouter();

	const [booking, setBooking] = useState<any>(null);
	const [classData, setClassData] = useState<any>(null);
	const [classThumbnail, setClassThumbnail] = useState<string | null>(null);

	const [isLoading, setIsLoading] = useState<boolean>(true);
	const [error, setError] = useState<string | null>(null);

	const [isCancelModalOpen, setIsCancelModalOpen] = useState(false);
	const [isTooLateModalOpen, setIsTooLateModalOpen] = useState(false);

	const [isCancelling, setIsCancelling] = useState(false);
	const [cancelReason, setCancelReason] = useState('');

	const t = useTranslations('TicketDetails');

	useEffect(() => {
		const fetchBooking = async () => {
			try {
				setIsLoading(true);
				//this function now fetches schedule details
				const res = await getBookingById(bookingId);
				const data = res?.data;
				if (!data) throw new Error('No booking data');
				setBooking(data);

				// Prefer embedded class if available; otherwise load by class_id
				const embeddedClass = (data as any)?.schedule?.class;
				const classId = (data as any)?.schedule?.class_id;

				if (embeddedClass) {
					setClassData(embeddedClass);
				} else if (classId) {
					const classRes = await getClassById(classId);
					setClassData(classRes?.data ?? null);
				} else {
					setClassData(null);
				}
			} catch (err: any) {
				setError(err?.message || 'Failed to load ticket details');
				toast.error(t('FailedToLoad'));
				// console.error('Error loading booking details:', err);
			} finally {
				setIsLoading(false);
			}
		};

		if (bookingId) fetchBooking();
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [bookingId]);

	useEffect(() => {
		let isCancelled = false;

		const fetchClassThumbnail = async () => {
			const classId = classData?.id;
			if (!classId) {
				if (!isCancelled) setClassThumbnail(null);
				return;
			}

			const fallback = getImageUrl(classId);
			if (!isCancelled) setClassThumbnail(fallback);

			try {
				const photos = await getClassPhotos(classId, {
					optimize: true,
					limit: 1,
				});
				if (!isCancelled && photos[0]) {
					setClassThumbnail(photos[0]);
				}
			} catch {
				if (!isCancelled) setClassThumbnail(fallback);
			}
		};

		void fetchClassThumbnail();

		return () => {
			isCancelled = true;
		};
	}, [classData?.id]);

	const handleBack = () => router.back();

	const openCancelModal = () => {
		const s = booking?.schedule;
		if (!s?.for_date || !s?.start_time) {
			// if we can’t determine start time, fall back to opening the cancel modal
			setCancelReason('');
			setIsCancelModalOpen(true);
			return;
		}

		// Combine date + time (assumes local time strings like "2025-09-16" & "15:10")
		const start = new Date(`${s.for_date}T${s.start_time}:00`);
		const hoursLeft = (start.getTime() - Date.now()) / (1000 * 60 * 60);

		if (hoursLeft < 12) {
			setIsTooLateModalOpen(true);
			return;
		}

		setCancelReason('');
		setIsCancelModalOpen(true);
	};

	const confirmCancelClass = async () => {
		try {
			setIsCancelling(true);
			const reason = cancelReason.trim() || 'No reason';
			await cancelBooking(String(bookingId), reason);
			toast.success(t('ClassCancelled'));
			setIsCancelModalOpen(false);
			setTimeout(() => {
				router.push(routes.schedules);
			}, 400);
		} catch (e: any) {
			toast.error(e?.message || t('FailedToLoad'));
		} finally {
			setIsCancelling(false);
		}
	};

	if (isLoading) return <TicketDetailsSkeleton />;
	if (error || !booking) return <CheckNetwork />;

	const schedule = booking.schedule ?? {};
	const child = booking.child ?? {};
	const title = classData?.title ?? '—';
	const description = classData?.description ?? t('NoDescription');
	const chargedAmount =
		typeof booking?.charged_coin_amount === 'number'
			? booking.charged_coin_amount
			: classData?.price ?? '—';
	const isTrialBooking = Boolean(booking?.is_trial_booking);
	const fullClassPrice = classData?.price;
	const trialClassPrice = classData?.trial_price;

	const branchText =
		typeof classData?.branch === 'string'
			? classData.branch
			: classData?.branch?.address ||
				classData?.branch?.title ||
				t('NoAddressProvided');

	const dayLabel = schedule?.day_of_week
		? schedule.day_of_week.charAt(0).toUpperCase() +
			schedule.day_of_week.slice(1).toLowerCase()
		: '';
	const heroImageSrc =
		classThumbnail ??
		(classData?.id ? getImageUrl(classData.id) : '/placeholder.avif');

	return (
		<div className="relative flex min-h-screen flex-col bg-transparent">
			{/* Header Image */}
			<div className="relative h-72 w-full">
				<Image
					src={heroImageSrc}
					alt={title}
					fill
					className="object-cover"
					priority
					aria-label="Class Image"
				/>
				<div className="pointer-events-none absolute inset-0 bg-gradient-to-b from-black/10 via-black/30 to-black/70" />
				<button
					onClick={handleBack}
					className="absolute left-4 top-4 rounded-full bg-white/30 p-2 text-white backdrop-blur hover:bg-white/35"
					aria-label="Go back"
				>
					<PiArrowLeft size={24} />
				</button>

				<div className="absolute bottom-3 left-4 right-4">
					<h1 className="line-clamp-2 text-2xl font-bold text-white drop-shadow">
						{title}
					</h1>
				</div>
			</div>

			{/* Main */}
			<div className="flex-1 overflow-y-auto px-4 pb-40">
				<div className="mb-3 mt-5 flex flex-col items-start gap-5 px-2">
					{/* Reserved For */}
					<div className="flex items-center justify-start gap-3">
						<div className="rounded-xl bg-mainPurple/12 p-2">
							<img src="/icons/profile.svg" alt="" width={32} height={32} />
						</div>
						<div className="flex flex-col items-start gap-1">
							<p className="text-xs font-medium text-secondaryGray">
								{t('ReservedFor')}
							</p>
							<p className="text-sm font-semibold text-textGray">
								{child?.first_name || child?.last_name
									? `${child?.first_name ?? ''} ${child?.last_name ?? ''}`.trim()
									: t('NoNameProvided')}
							</p>
						</div>
					</div>

					{/* Date */}
					<div className="flex items-center justify-start gap-3">
						<div className="rounded-xl bg-mainPurple/12 p-2">
							<img
								src="/icons/filters/calendar-bold.svg"
								alt=""
								width={32}
								height={32}
							/>
						</div>
						<div className="flex flex-col items-start gap-1">
							<p className="text-xs font-medium text-secondaryGray">
								{t('Date')}
							</p>
							<div className="font-semibold text-textGray">
								{dayLabel} {formatDateTime(schedule.for_date, 'date')}
							</div>
						</div>
					</div>

					{/* Time */}
					<div className="flex items-center justify-start gap-3">
						<div className="rounded-xl bg-mainPurple/12 p-2">
							<img src="/icons/watch.svg" alt="" width={32} height={32} />
						</div>
						<div className="flex flex-col items-start gap-1">
							<h3 className="text-xs font-medium text-secondaryGray">
								{t('Time')}
							</h3>
							<p className="text-sm font-semibold text-textGray">
								{formatDateTime(schedule.start_time, schedule.end_time, 'time')}
							</p>
						</div>
					</div>

					{/* Price & Location */}
					<div className="flex w-full flex-col items-start justify-center gap-5">
						<div className="flex w-full items-center justify-start gap-3">
							<div className="rounded-xl bg-mainPurple/12 p-2">
								<img src="/icons/dollar.svg" alt="" width={32} height={32} />
							</div>
							<div className="flex flex-col items-start gap-1">
								<h3 className="text-xs font-medium text-secondaryGray">
									{t('ChargedAmount')}
								</h3>
								<div
									className={
										isTrialBooking
											? 'flex items-center rounded-lg bg-emerald-100 px-1 py-0.5 pl-1.5'
											: 'flex items-center rounded-lg bg-orange-100 px-1 py-0.5 pl-1.5'
									}
								>
									<p
										className={
											isTrialBooking
												? 'text-sm font-semibold text-emerald-700'
												: 'text-sm font-semibold text-orange-500'
										}
									>
										{chargedAmount}
									</p>
									<Image
										src="/icons/coin.svg"
										alt="Coin"
										width={20}
										height={20}
										className="ml-1"
									/>
								</div>
								<p
									className={
										isTrialBooking
											? 'text-[11px] font-semibold text-emerald-600'
											: 'text-[11px] font-semibold text-orange-600'
									}
								>
									{isTrialBooking
										? t('TrialPriceApplied')
										: t('FullPriceApplied')}
								</p>
								{typeof fullClassPrice === 'number' &&
									typeof trialClassPrice === 'number' && (
										<p className="text-[11px] text-gray-500">
											{t('PriceReference', {
												fullPrice: fullClassPrice,
												trialPrice: trialClassPrice,
											})}
										</p>
									)}
							</div>
						</div>

						<div className="flex w-full items-center justify-start gap-3">
							<div className="rounded-xl bg-mainPurple/12 p-2">
								<Image
									src="/icons/location.svg"
									alt="Location"
									width={32}
									height={32}
								/>
							</div>
							<div className="flex flex-1 flex-col items-start">
								<h3 className="text-xs font-medium text-secondaryGray">
									{t('Location')}
								</h3>
								<p className="text-xs font-semibold text-mainPurple">
									{branchText}
								</p>
							</div>
						</div>
					</div>
				</div>

				{/* Build Route */}
				<div className="flex flex-col items-start gap-2 px-2">
					<Button
						variant="text"
						size="md"
						className="p-0 font-medium text-mainPurple"
						onClick={() => {
							openGoogleDirectionsToBranch(classData.branch, {
								mode: 'driving',
								// onError: () => console.error(t('MapsError')),
							});
						}}
					>
						{t('BuildRoute')}
						<PiArrowArcRight className="ml-1" size={18} />
					</Button>
				</div>

				{/* About */}
				<div className="flex flex-col items-start gap-2 px-2">
					<h2 className="text-lg font-medium text-textGray">
						{t('Description')}
					</h2>
					<p className="leading-relaxed text-gray-600">{description}</p>
				</div>
			</div>

			{/* Sticky Cancel CTA */}
			<div className="fixed bottom-[65px] left-0 right-0 bg-gradient-to-t from-[#f7fbff] via-[#f7fbff]/80 to-transparent px-3 pb-4 pt-4">
				<div className="mx-auto max-w-[65%]">
					<Button
						size="sm"
						onClick={openCancelModal}
						className="mx-auto w-full rounded-xl bg-mainPurple py-5 text-sm font-bold text-white shadow-[0_8px_20px_rgba(166,82,199,0.3)] hover:brightness-95"
					>
						{t('CancelClass')}
					</Button>
				</div>
			</div>

			{/* Cancel Modal */}
			<CustomModal
				isOpen={isCancelModalOpen}
				onClose={() => setIsCancelModalOpen(false)}
				title={t('CancelModal.Title')}
				description={t('CancelModal.Desc')}
				secondaryAction={{
					label: isCancelling
						? t('CancelModal.Working')
						: t('CancelModal.Secondary'),
					onClick: confirmCancelClass,
					variant: 'outline',
					color: 'danger',
				}}
				primaryAction={{
					label: t('CancelModal.Primary'),
					onClick: () => setIsCancelModalOpen(false),
					variant: 'solid',
				}}
				size="sm"
			>
				<label className="mb-2 block text-sm font-medium text-textGray">
					{t('CancelModal.ReasonLabel')}
				</label>
				<textarea
					value={cancelReason}
					onChange={(e) => setCancelReason(e.target.value)}
					placeholder={t('CancelModal.ReasonPlaceholder')}
					className="min-h-[96px] w-full rounded-xl border border-gray-200 bg-white p-3 text-sm text-gray-700 outline-none ring-0 focus:border-mainPurple"
				/>
			</CustomModal>

			<CustomModal
				isOpen={isTooLateModalOpen}
				onClose={() => setIsTooLateModalOpen(false)}
				title={t('CancelModal.TooLateTitle')}
				description={t('CancelModal.TooLateDesc')}
				primaryAction={{
					label: t('CancelModal.Ok'),
					onClick: () => setIsTooLateModalOpen(false),
					variant: 'solid',
				}}
				size="sm"
			/>
		</div>
	);
}
