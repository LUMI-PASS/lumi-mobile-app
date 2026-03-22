'use client';

import { useEffect, useState } from 'react';
import ProfileHeader from '@/components/ui/page-header';
import { routes } from '@/config/routes';
import { getChildrenList } from '@/services/api';
import { useRouter } from '@/i18n/routing';
import { Button, Loader } from 'rizzui';
import ChildCard from '@/components/ui/widgets/child-card';
import { Empty, SearchNotFoundIcon } from 'rizzui/empty';
import { PiCalendarBold, PiGenderFemale, PiUserCircle } from 'react-icons/pi';
import { calculateAge } from '@/utils/calculate-age';
import { useTranslations } from 'next-intl';
import { ChildCardSkeleton } from '@/components/ui/skeletons';
export default function AttendanceHistory() {
	const [children, setChildren] = useState<any[]>([]);
	const [isLoading, setIsLoading] = useState(true);
	const [error, setError] = useState<string | null>(null);
	const [selectedChildId, setSelectedChildId] = useState<string | null>(null);
	const router = useRouter();
	const t = useTranslations('Profile.Attendance');

	const handleAddChild = () => {
		router.push('/profile/children/add');
	};

	useEffect(() => {
		async function fetchChildren() {
			try {
				setIsLoading(true);
				const response = await getChildrenList();
				if (response.success) {
					setChildren(response.data);
				} else {
					setError('Failed to load children data');
				}
			} catch (err) {
				setError('An error occurred while fetching children data');
				// console.error(err);
			} finally {
				setIsLoading(false);
			}
		}

		fetchChildren();
	}, []);

	const handleSelectChild = (childId: string) => {
		setSelectedChildId(childId);
		router.push(routes.profile.attendanceDetails(childId));
	};

	return (
		<div className="flex min-h-screen flex-col bg-transparent pb-16">
			<ProfileHeader title={t('Title')} href={routes.profile.base} />

			<div className="flex flex-1 flex-col px-6 py-8">
				{isLoading ? (
					<div className="mt-2">
						<ChildCardSkeleton />
						<ChildCardSkeleton />
						<ChildCardSkeleton />
					</div>
				) : error ? (
					<div className="rounded-lg bg-red-50 p-4 text-center text-red-500">
						{error}
					</div>
				) : children === null ? (
					<>
						<Empty
							className="py-20 font-lexend"
							image={<SearchNotFoundIcon className="h-44 w-full" />}
							text={t('Empty')}
						/>
						<Button
							onClick={handleAddChild}
							variant="outline"
							className="mt-auto w-full rounded-2xl border-mainPurple/30 bg-white py-6 font-semibold text-mainPurple shadow-sm"
						>
							{t('AddChild')}
						</Button>
					</>
				) : (
					<div className="mt-2">
						{children.map((child: any) => {
							const age = calculateAge(child.dob);
							return (
								<ChildCard
									key={child.id}
									age={age}
									child={child}
									isSelected={selectedChildId === child.id}
									onSelect={handleSelectChild}
									isForProfilePage={true}
									isEditable={false}
								/>
							);
						})}
					</div>
				)}
			</div>
		</div>
	);
}
