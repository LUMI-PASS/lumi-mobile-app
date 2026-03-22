'use client';

import { Button, Empty, SearchNotFoundIcon } from 'rizzui';
import Image from 'next/image';
import { useDrawer } from '@/app/shared/drawer-views/use-drawer';
import { PiInfoBold } from 'react-icons/pi';
import { useState } from 'react';
import cn from '@/utils/class-names';
import ChildCard from '@/components/ui/widgets/child-card';
import { ClassEligibilityData, SelectChildViewProps } from '@/types';
import BookingView from './booking-view';
import { format, addDays } from 'date-fns';
import { useRouter } from '@/i18n/routing';
import CloseDrawerButton from '@/components/ui/buttons/close-drawer-button';
import { useTranslations } from 'next-intl';

export default function SelectChildView({
	eligibilityData,
	initialSelectedChildId,
}: SelectChildViewProps) {
	const t = useTranslations('Drawers.SelectChild');
	const tPkg = useTranslations('Drawers.Packages');
	const tPrf = useTranslations('Profile.Attendance');
	const { closeDrawer, openDrawer } = useDrawer();
	const [selectedChild, setSelectedChild] = useState<string | null>(
		initialSelectedChildId ?? null
	);
	const isLoading = false;
	const router = useRouter();

	const resolveEffectivePrice = (child: ClassEligibilityData['children'][number]) => {
		if (typeof child.effective_class_price === 'number') {
			return child.effective_class_price;
		}
		if (child.will_use_trial && typeof eligibilityData.class_trial_price === 'number') {
			return eligibilityData.class_trial_price;
		}
		return eligibilityData.class_price;
	};

	const selectedChildData = eligibilityData.children.find(
		(child) => child.id === selectedChild
	);

	const totalRemainingTrials = eligibilityData.children.reduce(
		(total, child) => total + (child.remaining_trials ?? 0),
		0
	);

	const unlockThreshold = eligibilityData.trial_unlock_threshold_coin ?? 700;
	const unlockBatch = eligibilityData.trial_unlock_batch_lessons_per_unlock ?? 3;
	const safeUnlockThreshold = unlockThreshold > 0 ? unlockThreshold : 700;

	const eligibleChildren = eligibilityData.children.filter(
		(child) => child.is_eligible
	);
	const minEffectivePrice =
		eligibleChildren.length > 0
			? Math.min(...eligibleChildren.map((child) => resolveEffectivePrice(child)))
			: 0;

	const selectedChildPrice = selectedChildData
		? resolveEffectivePrice(selectedChildData)
		: null;

	const canAffordSelectedChild =
		typeof selectedChildPrice === 'number'
			? eligibilityData.wallet_balance >= selectedChildPrice
			: false;

	const canProceed = Boolean(
		selectedChild && selectedChildData?.is_eligible && canAffordSelectedChild
	);

	const showLowBalanceState =
		(minEffectivePrice > 0 &&
			eligibilityData.wallet_balance < minEffectivePrice) ||
		eligibilityData.wallet_balance === 0;

	const selectedChildProgressCoins =
		selectedChildData?.coins_into_unlock_cycle ??
		(selectedChildData?.paid_coin_accumulator ?? 0) % safeUnlockThreshold;
	const selectedChildProgress = Math.min(
		100,
		Math.round((selectedChildProgressCoins / safeUnlockThreshold) * 100)
	);

	const handleChildSelect = (childId: string) => {
		setSelectedChild(selectedChild === childId ? null : childId);
	};

	const handleNext = (e: React.TouchEvent | React.MouseEvent) => {
		e.preventDefault();
		e.stopPropagation();
		if (!selectedChild) return;

		// Close current drawer first (with animation)
		closeDrawer();

		setTimeout(() => {
			const today = new Date();
			const fromDate = format(today, 'yyyy-MM-dd');
			const toDate = format(addDays(today, 30), 'yyyy-MM-dd');

			openDrawer({
				view: (
					<BookingView
						classId={eligibilityData.class_id}
						childId={selectedChild}
						initialFromDate={fromDate}
						initialToDate={toDate}
						eligibilityData={eligibilityData} // ← pass it forward
					/>
				),
				placement: 'bottom',
				height: '80vh',
			});
		}, 650);
	};

	return (
		<div className="flex h-full flex-col px-5 pb-6">
			{/* Header */}
			<div className="relative mb-6 flex items-center">
				<h2 className="flex-1 text-center font-balsamiqSans font-semibold text-2xl text-textGray">
					{t('Title')}
				</h2>
				<CloseDrawerButton onClick={closeDrawer} />
			</div>

			<div className="flex h-full flex-col overflow-y-auto">
				{/* Balance */}
				<div className="mb-6 rounded-[22px] border border-mainPurple/15 bg-gradient-to-r from-violet-50 via-fuchsia-50 to-pink-50 p-4 shadow-sm">
					<div className="mb-3 flex items-center justify-between">
						<div className="text-sm font-semibold text-textGray">
							{tPkg('YourBalance')}
						</div>
						<div className="flex items-center">
							<span className="mr-2 text-2xl font-bold text-mainPurple">
								{eligibilityData.wallet_balance}
							</span>
							<Image src="/icons/coin.svg" alt="Coin" width={28} height={28} />
						</div>
					</div>

					{showLowBalanceState && (
						<div className="flex items-start gap-2 rounded-lg bg-white/50 p-3 backdrop-blur-sm">
							<PiInfoBold size={18} className="mt-0.5 text-mainPurple" />
							<p className="text-xs font-medium text-gray-600">
								{eligibilityData.wallet_balance === 0
									? tPkg('NoCoins')
									: tPkg('LowCoins')}
							</p>
						</div>
					)}
				</div>

				<div className="mb-6 rounded-[22px] border border-mainPurple/10 bg-white/80 p-4 shadow-sm">
					<p className="text-sm font-semibold text-textGray">
						{t('PerChildTrialsTitle')}
					</p>
					<p className="mt-1 text-xs text-gray-500">{t('PerChildTrialsDesc')}</p>

					<div className="mt-3 flex items-center justify-between rounded-xl bg-mainPurple/10 px-3 py-2">
						<p className="text-xs font-semibold text-mainPurple">
							{t('TotalRemainingTrials')}
						</p>
						<p className="text-lg font-bold text-mainPurple">
							{totalRemainingTrials}
						</p>
					</div>

					<p className="mt-2 text-[11px] text-gray-500">
						{t('UnlockRule', {
							threshold: safeUnlockThreshold,
							batch: unlockBatch,
						})}
					</p>
				</div>

				{/* Children List */}
				<div className="mb-6 px-1">
					{eligibilityData.children.length !== 0 ? (
						eligibilityData.children.map((child) => (
							<ChildCard
								isForProfilePage={false}
								isEditable={false}
								key={child.id}
								child={child}
								isSelected={selectedChild === child.id}
								onSelect={handleChildSelect}
							/>
						))
					) : (
						<div className="flex flex-col items-center justify-center">
							<Empty
								className="font-lexend"
								image={<SearchNotFoundIcon className="h-44 w-full" />}
								text={tPrf('Empty')}
							/>
							<Button
								onClick={() => router.push('/profile/children/add')}
								className="mt-6 rounded-xl bg-mainPurple px-6 py-3 text-white shadow-[0_8px_18px_rgba(166,82,199,0.3)]"
							>
								{tPrf('AddChild')}
							</Button>
						</div>
					)}
				</div>

				{selectedChildData && (
					<div className="mb-4 rounded-2xl border border-mainPurple/15 bg-white/85 p-4 shadow-sm">
						<div className="mb-2 flex items-center justify-between">
							<p className="text-sm font-semibold text-textGray">
								{t('ExpectedCharge')}
							</p>
							<div className="flex items-center rounded-lg bg-amber-100 px-2 py-0.5 text-sm font-bold text-amber-700">
								{selectedChildPrice}
								<Image
									src="/icons/coin.svg"
									alt="Coin"
									width={16}
									height={16}
									className="ml-1"
								/>
							</div>
						</div>
						<p className="text-xs font-medium text-mainPurple">
							{selectedChildData.will_use_trial
								? t('BookingUsesTrialPrice')
								: t('BookingUsesFullPrice')}
						</p>

						<div className="mt-4">
							<div className="mb-1 flex items-center justify-between text-[11px] font-semibold text-gray-500">
								<span>{t('UnlockProgress')}</span>
								<span>{selectedChildProgress}%</span>
							</div>
							<div className="h-2 w-full rounded-full bg-mainPurple/10">
								<div
									className="h-2 rounded-full bg-mainPurple transition-all duration-300"
									style={{ width: `${selectedChildProgress}%` }}
								/>
							</div>
							<p className="mt-2 text-[11px] text-gray-500">
								{t('UnlockProgressMeta', {
									coinsLeft: selectedChildData.coins_to_next_unlock ?? 0,
									target:
										selectedChildData.next_unlock_at_total_paid_coins ??
										safeUnlockThreshold,
								})}
							</p>
						</div>
					</div>
				)}

				{/* Next Button */}
				<div className="mt-auto bg-gradient-to-t from-white via-white/80 to-white/20 pb-10 pt-4">
					{selectedChild && !canAffordSelectedChild && (
						<div className="mb-2 rounded-xl bg-red-50 px-3 py-2 text-center text-xs font-semibold text-red-500">
							{t('InsufficientBalanceForSelectedChild')}
						</div>
					)}
					<Button
						size="lg"
						onClick={handleNext}
						className={cn(
							'w-full rounded-2xl bg-mainPurple py-7 font-bold text-white shadow-[0_10px_22px_rgba(166,82,199,0.32)]',
							!canProceed
								? 'cursor-not-allowed opacity-40'
								: 'hover:opacity-90'
						)}
						disabled={!canProceed || isLoading}
						isLoading={isLoading}
					>
						{isLoading ? t('Booking') : tPkg('Next')}
					</Button>
				</div>
			</div>
		</div>
	);
}
