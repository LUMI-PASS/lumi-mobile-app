'use client';

import { useEffect, useMemo, useState } from 'react';
import { useRouter } from '@/i18n/routing';
import { Button, Empty, SearchNotFoundIcon } from 'rizzui';
import { getParentProfile } from '@/services/api';
import { routes } from '@/config/routes';
import ProfileHeader from '@/components/ui/page-header';
import ChildCard from '@/components/ui/widgets/child-card';
import { calculateAge } from '@/utils/calculate-age';
import { useTranslations } from 'next-intl';
import CheckNetwork from '@/app/[locale]/(other-pages)/check-network/check-network';
import { ChildCardSkeleton } from '@/components/ui/skeletons';

type TrialChildSummaryEntry = {
	child_id: string | number;
	remaining_trials?: number;
	coins_into_unlock_cycle?: number;
	coins_to_next_unlock?: number;
	next_unlock_at_total_paid_coins?: number;
};

export default function MyChildren() {
	const [profileData, setProfileData] = useState<any>(null);
	const [isLoading, setIsLoading] = useState<boolean>(true);
	const [error, setError] = useState<string | null>(null);
	const router = useRouter();
	const t = useTranslations('Profile.Children');
	const tTrial = useTranslations('Profile.Overview.TrialWallet');

	const handleChildSelect = (childId: string) => {
		router.push(routes.profile.editChild(childId));
	};

	useEffect(() => {
		const fetchProfileData = async () => {
			try {
				setIsLoading(true);
				const response = await getParentProfile();
				setProfileData(response.data);
			} catch (err: any) {
				setError(err.message || 'Failed to load children information');
				// console.error('Error fetching children information:', err);
			} finally {
				setIsLoading(false);
			}
		};

		fetchProfileData();
	}, []);

	const handleAddChild = () => {
		router.push('/profile/children/add');
	};

	const children = profileData?.children || [];
	const trialSummary = profileData?.trial_summary;
	const unlockThreshold = trialSummary?.unlock_threshold_coin ?? 700;
	const unlockBatch = trialSummary?.unlock_batch_trials ?? 3;
	const trialByChildId = useMemo<Map<string, TrialChildSummaryEntry>>(() => {
		const entries = Array.isArray(trialSummary?.children)
			? (trialSummary.children as TrialChildSummaryEntry[])
			: ([] as TrialChildSummaryEntry[]);
		return new Map(entries.map((entry) => [String(entry.child_id), entry]));
	}, [trialSummary]);

	if (isLoading) {
		return (
			<div className="flex min-h-screen flex-col bg-transparent pb-16">
				<ProfileHeader title={t('Title')} href={routes.profile.base} />
				<div className="flex flex-1 flex-col gap-2 px-4 py-8">
					<ChildCardSkeleton />
					<ChildCardSkeleton />
					<ChildCardSkeleton />
				</div>
			</div>
		);
	}

	if (error) {
		return <CheckNetwork />;
	}

	return (
		<div className="flex min-h-screen flex-col bg-transparent pb-16">
			<ProfileHeader title={t('Title')} href={routes.profile.base} />

			<div className="flex h-full flex-1 flex-col gap-2 px-4 pt-8 pb-3">
				{trialSummary && (
					<div className="mb-2 rounded-2xl border border-mainPurple/15 bg-white/90 p-3 shadow-sm">
						<div className="flex items-center justify-between gap-3">
							<div className="min-w-0">
								<h2 className="text-sm font-semibold text-textGray">
									{tTrial('Title')}
								</h2>
								<p className="mt-0.5 line-clamp-2 text-xs text-gray-500">
									{tTrial('Desc')}
								</p>
							</div>
							<div className="shrink-0 rounded-lg bg-mainPurple/10 px-2.5 py-1.5 text-center">
								<p className="text-[10px] font-semibold text-mainPurple/80">
									{tTrial('TotalRemainingLabel')}
								</p>
								<p className="text-lg font-extrabold leading-none text-mainPurple">
									{trialSummary.total_remaining_trials}
								</p>
							</div>
						</div>
						<p className="mt-2 rounded-lg bg-mainPurple/5 px-2.5 py-1.5 text-[11px] text-mainPurple/80">
							{tTrial('UnlockRule', {
								threshold: unlockThreshold,
								batch: unlockBatch,
							})}
						</p>
					</div>
				)}

				{/* Children List */}
				{children.length > 0 ? (
					children.map((child: any) => {
						const age = calculateAge(child.dob);
						const trial = trialByChildId.get(String(child.id));
						const childWithTrialData = trial
							? {
									...child,
									remaining_trials: trial.remaining_trials,
									coins_into_unlock_cycle: trial.coins_into_unlock_cycle,
									coins_to_next_unlock: trial.coins_to_next_unlock,
									next_unlock_at_total_paid_coins:
										trial.next_unlock_at_total_paid_coins,
									unlock_threshold_coin: unlockThreshold,
								}
							: child;
						return (
							<ChildCard
								age={age}
								isForProfilePage={true}
								key={child.id}
								child={childWithTrialData}
								isSelected={false}
								onSelect={handleChildSelect}
								isEditable={false}
							/>
						);
					})
				) : (
					<Empty
						className="py-20 font-lexend"
						image={<SearchNotFoundIcon className="h-44 w-full" />}
						text={t('Empty')}
					/>
				)}

				{/* Add Child Button */}
				<Button
					onClick={handleAddChild}
					variant="outline"
					className="mt-auto w-full rounded-2xl border-mainPurple/30 bg-white py-6 font-semibold text-mainPurple shadow-sm"
					style={{ marginBottom: 'calc(env(safe-area-inset-bottom) + 10px)' }}
				>
					{t('AddChild')}
				</Button>
			</div>
		</div>
	);
}
