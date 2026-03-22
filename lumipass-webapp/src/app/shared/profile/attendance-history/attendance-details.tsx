'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import ProfileHeader from '@/components/ui/page-header';
import { routes } from '@/config/routes';
import { getChildDetails, getChildAttendanceHistory } from '@/services/api';
import { useRouter } from '@/i18n/routing';
import { Badge, Button, Loader } from 'rizzui';
import ChildCard from '@/components/ui/widgets/child-card';
import { format, parseISO } from 'date-fns';
import { PiCalendarX, PiClockBold, PiClockDuotone } from 'react-icons/pi';
import { Empty, SearchNotFoundIcon } from 'rizzui/empty';
import {
	CheckCircleIcon,
	XCircleIcon,
	MinusCircleIcon,
	CalendarIcon,
} from '@heroicons/react/24/solid';
import { calculateAge } from '@/utils/calculate-age';
import { useTranslations } from 'next-intl';
import {
	AttendanceListSkeleton,
	ChildCardSkeleton,
} from '@/components/ui/skeletons';
import {
	CalendarDaysIcon,
	ExclamationCircleIcon,
	ClockIcon,
} from '@heroicons/react/24/outline';

export default function AttendanceDetails() {
	const [child, setChild] = useState<any>(null);
	const [attendanceHistory, setAttendanceHistory] = useState<any[]>([]);
	const [isLoading, setIsLoading] = useState(true);
	const [error, setError] = useState<string | null>(null);
	const params = useParams();
	const router = useRouter();
	const childId = params.id as string;
	const t = useTranslations('Profile.AttendanceDetails');

	useEffect(() => {
		async function fetchData() {
			try {
				setIsLoading(true);

				// Fetch child data
				const childResponse = await getChildDetails(childId);
				if (childResponse.success) {
					setChild(childResponse.data);
				} else {
					setError('Failed to load child data');
					return;
				}

				// Fetch attendance history
				const historyResponse = await getChildAttendanceHistory(childId);
				if (historyResponse.success) {
					if (Array.isArray(historyResponse.data)) {
						setAttendanceHistory(historyResponse.data);
						// console.log('Attendance History:', historyResponse.data);
					} else {
						setAttendanceHistory([]);
						<Empty
							image={<PiCalendarX className="h-16 w-16 text-gray-400" />}
							text="No attendance records found for this child"
						/>;
					}
				} else {
					setError('Failed to load attendance history');
				}
			} catch (err) {
				setError('An error occurred while fetching data');
				// console.error(err);
			} finally {
				setIsLoading(false);
			}
		}

		if (childId) {
			fetchData();
		}
	}, [childId]);

	const formatTime = (timeString: string) => {
		try {
			return format(parseISO(timeString), 'h:mm a');
		} catch (error) {
			return timeString;
		}
	};

	const getStatusBadge = (attendanceStatus: string, bookingStatus: string) => {
		if (bookingStatus !== 'CONFIRMED') {
			switch (bookingStatus) {
				case 'CANCELED_BY_SYSTEM':
					return (
						<Badge
							size="sm"
							variant="flat"
							className="flex items-center gap-1.5 bg-gray-100 text-gray-700"
						>
							<MinusCircleIcon className="h-3 w-3" />
							{t('Status.Booking.CANCELED_BY_SYSTEM')}
						</Badge>
					);
				case 'CANCELED_BY_PARENT':
					return (
						<Badge
							size="sm"
							variant="flat"
							className="flex items-center gap-1.5 bg-gray-100 text-gray-700"
						>
							<MinusCircleIcon className="h-3 w-3" />
							{t('Status.Booking.CANCELED_BY_PARENT')}
						</Badge>
					);
				case 'CANCELED_BY_PARTNER':
					return (
						<Badge
							size="sm"
							variant="flat"
							className="flex items-center gap-1.5 bg-gray-100 text-gray-700"
						>
							<MinusCircleIcon className="h-3 w-3" />
							{t('Status.Booking.CANCELED_BY_PARTNER')}
						</Badge>
					);
				case 'PENDING':
					return (
						<Badge
							size="sm"
							variant="flat"
							className="flex items-center gap-1.5 bg-amber-100 text-amber-700"
						>
							<ClockIcon className="h-3 w-3" />
							{t('Status.Booking.PENDING')}
						</Badge>
					);
				default:
					return (
						<Badge
							size="sm"
							variant="flat"
							className="flex items-center gap-1.5 bg-gray-100 text-gray-700"
						>
							<MinusCircleIcon className="h-3 w-3" />
							{t('Status.Booking.CANCELED_BY_SYSTEM')}
						</Badge>
					);
			}
    }
    
		switch (attendanceStatus) {
			case 'CHECKED_IN':
				return (
					<Badge
						variant="flat"
						size="sm"
						className="flex items-center gap-1.5 bg-green-100 text-green-700"
					>
						<CheckCircleIcon className="h-3 w-3" />
						{t('Status.Present')}
					</Badge>
				);
			case 'NO_SHOW':
				return (
					<Badge
						size="sm"
						variant="flat"
						className="flex items-center gap-1.5 bg-red-100 text-red-700"
					>
						<XCircleIcon className="h-3 w-3" />
						{t('Status.Absent')}
					</Badge>
				);
			case 'LATE':
				return (
					<Badge
						size="sm"
						variant="flat"
						className="flex items-center gap-1.5 bg-amber-100 text-amber-700"
					>
						<ExclamationCircleIcon className="h-3 w-3" />
						{t('Status.Late')}
					</Badge>
				);
			case 'NOT_APPLICABLE':
			default:
				return (
					<Badge
						size="sm"
						variant="flat"
						className="flex items-center gap-1.5 bg-indigo-100 text-indigo-700"
					>
						<CheckCircleIcon className="h-3 w-3" />
						{t('Status.Booking.CONFIRMED')}
					</Badge>
				);
		}
	};


	const handleSelectChild = () => {
		return;
	};

	return (
		<div className="flex min-h-screen flex-col bg-gray-50 pb-16">
			<ProfileHeader
				title={t('Title')}
				href={routes.profile.attendanceHistory}
			/>

			<div className="flex flex-1 flex-col px-5 py-5">
				{isLoading ? (
					<>
						<div className="mb-7">
							<ChildCardSkeleton />
						</div>
						<AttendanceListSkeleton items={4} />
					</>
				) : error ? (
					<div className="rounded-lg bg-red-50 p-4 text-center text-red-500">
						{error}
					</div>
				) : (
					<>
						{/* Child Card */}
						{child && (
							<div className="mb-7">
								<ChildCard
									age={calculateAge(child.dob)}
									child={child}
									isSelected={true}
									onSelect={handleSelectChild}
									isForProfilePage={true}
								/>
							</div>
						)}

						{/* Attendance History */}
						<div>
							<div className="mb-4 w-full border-t border-dashed text-xl font-semibold text-gray-800"></div>

							{attendanceHistory.length === 0 ? (
								<div className="flex flex-col items-center gap-5">
									<Empty
										image={<SearchNotFoundIcon className="h-44 w-full" />}
										text={t('Empty')}
									/>
									<Button
										size="sm"
										type="submit"
										variant="outline"
										onClick={() => router.push('/explore')}
										className="w-3/4 rounded-2xl border-mainPurple bg-white py-5 text-mainPurple"
									>
										{t('BookClass')}
									</Button>
								</div>
							) : (
								<div className="space-y-4">
									{attendanceHistory.map((record, index) => (
										<div
											key={record.booking_id || index}
											className="rounded-xl border border-gray-50 bg-white px-4 py-3 shadow-sm"
										>
											<div className="flex items-center justify-end">
												{getStatusBadge(
													record.attendance_status,
													record.booking_status
												)}
											</div>
											<h5 className="mb-3 line-clamp-2 text-sm font-semibold text-textGray">
												{record.class_name}
											</h5>

											<div className="text-xs text-gray-600">
												<div className="mb-2 flex items-center gap-2">
													<Badge
														variant="flat"
														size="sm"
														rounded="md"
														className="bg-indigo-100 text-indigo-600"
													>
														{record.category_title}
													</Badge>
													{/* •{' '} */}
													<Badge
														size="sm"
														variant="flat"
														rounded="md"
														className="bg-gray-100 text-gray-600"
													>
														{record.branch_title}
													</Badge>
												</div>

												<div className="mt-5 flex flex-wrap items-center gap-4 border-t border-dashed pt-2">
													<div className="flex items-center gap-1 text-sky-700">
														<CalendarDaysIcon className="h-4 w-4" />
														<span>
															{format(
																new Date(record.schedule_date),
																'MMM d, yyyy'
															)}
														</span>
													</div>

													<div className="flex items-center gap-1 text-mainPurple">
														<ClockIcon className="h-4 w-4" />
														<span>
															{formatTime(record.start_time)} -{' '}
															{formatTime(record.end_time)}
														</span>
													</div>
												</div>
											</div>
										</div>
									))}
								</div>
							)}
						</div>
					</>
				)}
			</div>
		</div>
	);
}
