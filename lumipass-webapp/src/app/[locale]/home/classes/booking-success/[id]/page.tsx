'use client';

import { useParams } from 'next/navigation';
import { Button } from 'rizzui';
import { PiCaretLeftBold, PiCheckBold } from 'react-icons/pi';
import { routes } from '@/config/routes';
import { useRouter } from '@/i18n/routing';
import { useTranslations } from 'next-intl';

export default function BookingSuccessPage() {
	const params = useParams();
	const bookingId = params.id as string;
	const router = useRouter();
	const t = useTranslations('Booking.SuccessPage');

	const handleGoToSchedule = () => {
		router.push(routes.schedules);
	};

	const handleDiscoverMore = () => {
		router.push(routes.home);
	};

	const handleBack = () => {
		router.back();
	};

	return (
		<div className="flex min-h-screen flex-col bg-gray-50">
			<button
				type="button"
				onClick={handleBack}
				aria-label={t('Back')}
				className="absolute left-6 top-10 z-10 rounded-xl bg-white p-2 shadow-lg"
			>
				<PiCaretLeftBold size={20} className="font-extrabold text-primary" />
			</button>

			{/* Content */}
			<div className="flex flex-1 flex-col items-center justify-center px-6">
				<div className="relative">
					<div className="absolute inset-0 flex items-center justify-center">
						<div className="success-dot absolute -top-8 left-0 h-2 w-2 rounded-full bg-gray-200" />
						<div className="success-dot absolute -top-4 right-12 h-2 w-2 rounded-full bg-gray-200" />
						<div className="success-dot absolute right-2 top-4 h-3 w-3 rounded-full bg-gray-200" />
						<div className="success-dot absolute -bottom-8 left-12 h-2 w-2 rounded-full bg-gray-200" />

						<svg
							className="success-wave absolute -left-12"
							width="24"
							height="12"
							viewBox="0 0 24 12"
							fill="none"
							xmlns="http://www.w3.org/2000/svg"
						>
							<path
								d="M1 6C3 2 5 10 8 6C11 2 13 10 16 6C19 2 21 10 24 6"
								stroke="#D1D5DB"
								strokeWidth="2"
								strokeLinecap="round"
							/>
						</svg>

						<svg
							className="success-wave absolute -right-12"
							width="24"
							height="12"
							viewBox="0 0 24 12"
							fill="none"
							xmlns="http://www.w3.org/2000/svg"
						>
							<path
								d="M1 6C3 2 5 10 8 6C11 2 13 10 16 6C19 2 21 10 24 6"
								stroke="#D1D5DB"
								strokeWidth="2"
								strokeLinecap="round"
							/>
						</svg>

						{/* Triangle */}
						<div className="absolute -right-8 bottom-0">
							<svg
								width="12"
								height="12"
								viewBox="0 0 12 12"
								fill="none"
								xmlns="http://www.w3.org/2000/svg"
							>
								<path d="M6 0L11.1962 10.5H0.803848L6 0Z" fill="#D1D5DB" />
							</svg>
						</div>
					</div>

					<div className="flex h-32 w-32 items-center justify-center rounded-full bg-mainPurple">
						<PiCheckBold size={60} className="text-white" />
					</div>
				</div>

				{/* Text */}
				<h1 className="mt-10 w-full text-center font-balsamiqSans font-bold text-4xl text-textGray">
					{t('SuccessTitle')}
				</h1>
				<p className="mt-4 text-center font-lexend text-gray-400">
					{t('SuccessSubtitle')}
					<br />
					{t('SeeYou')}
				</p>
			</div>

			{/* Buttons */}
			<div className="mb-6 space-y-4 px-8 pb-24">
				<Button
					type="button"
					onClick={handleGoToSchedule}
					className="w-full rounded-xl bg-mainPurple py-6 font-bold text-white hover:bg-mainPurple/90"
				>
					{t('GoToSchedule')}
				</Button>
				<Button
					type="button"
					variant="outline"
					onClick={handleDiscoverMore}
					className="w-full rounded-xl border-mainPurple bg-white py-6 font-bold text-mainPurple hover:bg-mainPurple/5"
				>
					{t('DiscoverMore')}
				</Button>
			</div>
		</div>
	);
}
