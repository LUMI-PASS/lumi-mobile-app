'use client';

import { useEffect, useState } from 'react';
import { Button, Empty, SearchNotFoundIcon } from 'rizzui';
import { useRouter } from '@/i18n/routing';
import { getParentSchedules } from '@/services/api';
import ScheduleCard from '@/components/ui/widgets/schedule-card';
import { routes } from '@/config/routes';
import CheckNetwork from '@/app/[locale]/(other-pages)/check-network/check-network';
import { useTranslations } from 'next-intl';
import { SchedulesListSkeleton } from '@/components/ui/skeletons';

export default function SchedulesPageContent() {
	const [schedules, setSchedules] = useState<any[]>([]);
	const [isLoading, setIsLoading] = useState<boolean>(true);
	const [error, setError] = useState<string | null>(null);
	const [noData, setNoData] = useState<boolean>(false);
	const t = useTranslations('Schedules');
	const router = useRouter();

	useEffect(() => {
		const fetchSchedules = async () => {
			try {
				setIsLoading(true);
				let parentId = '';
				const userData = localStorage.getItem('user');
				if (userData) {
					const parsedUser = JSON.parse(userData);
					parentId = parsedUser.id;
				}

				if (!parentId) {
					setError('User not found. Please log in again.');
					return;
				}

				const response = await getParentSchedules(parentId);
				const list = Array.isArray(response?.data) ? response.data : [];
				// console.log('Fetched schedules:', list);
				if (list.length === 0) {
					setNoData(true);
					setSchedules([]);
				} else {
					setNoData(false);
					setSchedules(list);
				}
			} catch (err: any) {
				setError(err?.message || 'Failed to load schedules');
				// console.error('Error fetching schedules:', err);
			} finally {
				setIsLoading(false);
			}
		};
		fetchSchedules();
	}, []);

	const handleDiscoverClasses = () => {
		router.push(routes.home);
	};

	if (error) {
		return <CheckNetwork />;
	}

	return (
		<div className="flex min-h-screen flex-col bg-transparent">
			<div className="flex-1 px-4 pb-24 pt-8">
				{/* Always show title */}
				<h1 className="app-page-title mb-5">
					{t('Title')}
				</h1>

				{/* Conditional rendering below the title */}
				{isLoading ? (
					<SchedulesListSkeleton count={4} />
				) : noData ? (
					<div className="flex h-full flex-1 flex-col items-center justify-center rounded-3xl bg-white/75 px-6 py-8 shadow-sm">
						<Empty image={<SearchNotFoundIcon className="h-44 w-full" />} />
						<h2 className="mb-1 text-center font-balsamiqSans text-xl font-bold text-textGray">
							{t('Empty.title')}
						</h2>
						<p className="mb-8 text-center font-lexend text-sm text-gray-500">
							{t('Empty.description')}
						</p>
						<Button
							onClick={handleDiscoverClasses}
							variant="outline"
							className="w-full rounded-2xl border-mainPurple/30 bg-white px-8 py-6 font-semibold text-mainPurple"
						>
							{t('DiscoverClasses')}
						</Button>
					</div>
				) : (
					schedules.map((schedule: any) => (
						<ScheduleCard key={schedule.id} schedule={schedule} />
					))
				)}
			</div>
		</div>
	);
}
