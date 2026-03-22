'use client';

import cn from '@/utils/class-names';
import Image from 'next/image';
import { PiUser } from 'react-icons/pi';
import { Badge } from 'rizzui';
import { routes } from '@/config/routes';
import { useRouter } from '@/i18n/routing';
import { getChildImageUrl } from '@/services/api';
import { useTranslations } from 'next-intl';
import { ChildCardProps } from '@/types';
import { reasonToCommonKey } from '@/utils/reason-i18n.mapper';

export default function ChildCard({
	child,
	isSelected,
	onSelect,
	isForProfilePage,
	isEditable,
	age,
}: ChildCardProps) {
	const router = useRouter();
	const tEditBtn = useTranslations('Profile.Children.Edit');
	const tCommon = useTranslations('Common');
	const tSelect = useTranslations('Drawers.SelectChild');
	const tTrial = useTranslations('Profile.Overview.TrialWallet');
	const reasonKey = reasonToCommonKey(child?.reason);

	const handleSelect = () => {
		if (isForProfilePage) {
			onSelect(child.id);
		} else if (child.is_eligible) {
			onSelect(child.id);
		}
	};

	const ageValue = child.age ?? age;
	const ageLabel =
		typeof ageValue === 'number'
			? tCommon('AgeWithUnits', { count: ageValue })
			: null;
	const unlockThreshold =
		typeof child.unlock_threshold_coin === 'number' &&
		child.unlock_threshold_coin > 0
			? child.unlock_threshold_coin
			: null;
	const progressPercent =
		unlockThreshold != null && typeof child.coins_into_unlock_cycle === 'number'
			? Math.min(
					100,
					Math.round((child.coins_into_unlock_cycle / unlockThreshold) * 100)
				)
			: null;
	const remainingTrials =
		typeof child.remaining_trials === 'number' ? child.remaining_trials : null;
	const coinsToNextUnlock =
		typeof child.coins_to_next_unlock === 'number'
			? child.coins_to_next_unlock
			: null;
	const hasTrialWalletInfo = !isForProfilePage && coinsToNextUnlock !== null;
	const showProfileInlineTrialCount = isForProfilePage && remainingTrials !== null;
	const showProfileProgress = isForProfilePage && progressPercent !== null;
	const showProfileUnlockMeta = isForProfilePage && coinsToNextUnlock !== null;
	const showSelectChildInlineMeta =
		!isForProfilePage &&
		(ageLabel !== null ||
			remainingTrials !== null ||
			typeof child.effective_class_price === 'number');

	return (
		<div
			className={cn(
				'relative mb-4 rounded-2xl border border-white/90 bg-white/90 px-3 py-2 shadow-[0_8px_18px_rgba(60,83,154,0.12)] backdrop-blur transition-all',
				isForProfilePage
					? isSelected
						? 'cursor-pointer border-mainPurple bg-mainPurple text-white shadow-[0_12px_22px_rgba(166,82,199,0.32)]'
						: 'cursor-pointer border-white/90'
					: child.is_eligible
						? isSelected
							? 'cursor-pointer border-mainPurple bg-mainPurple text-white shadow-[0_12px_22px_rgba(166,82,199,0.32)]'
							: 'cursor-pointer border-white/90 hover:border-mainPurple/40'
						: 'cursor-not-allowed border-mainPurple/20 bg-gray-100/90 opacity-60'
			)}
			onClick={handleSelect}
		>
			<div className="flex items-start gap-3 text-inherit">
				<div
					className={cn(
						'relative h-14 w-14 overflow-hidden rounded-xl border border-gray-100 bg-gray-50',
						isSelected && 'border-white/40 bg-white/20'
					)}
				>
					{child.has_photo ? (
						<Image
							src={getChildImageUrl(child.id)}
							alt={`${child.first_name}'s photo`}
							fill
							className="object-cover"
							sizes="96px"
						/>
					) : (
						<div className="flex h-full w-full items-center justify-center">
							<PiUser
								className={cn(
									'h-8 w-8 text-gray-400',
									isSelected && 'text-white'
								)}
							/>
						</div>
					)}
				</div>

				<div className="gap-auto flex flex-1 items-center justify-between">
					<div className="flex flex-1 flex-col text-inherit">
						<div className="flex items-center justify-between gap-3">
							<h3 className="line-clamp-1 flex-1 text-base font-medium text-inherit">
								{child.first_name} {child.last_name}
							</h3>
						</div>

						{isForProfilePage && (ageLabel || showProfileInlineTrialCount) && (
							<div className="mt-1.5 flex items-center justify-between gap-2">
								{ageLabel && (
									<span
										className={cn(
											'inline-flex items-center rounded-md bg-mainPink/20 px-2 py-1 text-[10px] font-semibold text-textGray',
											isSelected && 'bg-white/20 text-white'
										)}
									>
										{ageLabel}
									</span>
								)}
								{showProfileInlineTrialCount && (
									<span
										className={cn(
											'ml-auto rounded-md bg-mainPurple/10 px-1.5 py-0.5 text-[10px] font-semibold text-mainPurple',
											isSelected && 'bg-white/20 text-white'
										)}
									>
										{tTrial('ChildRemaining', {
											count: remainingTrials,
										})}
									</span>
								)}
							</div>
						)}
						{showSelectChildInlineMeta && (
							<div className="mt-1.5 flex items-center gap-1.5 overflow-x-auto whitespace-nowrap pb-0.5 text-[11px]">
								{ageLabel && (
									<span
										className={cn(
											'inline-flex items-center rounded-md bg-mainPink/20 px-2 py-1 text-[10px] font-semibold text-textGray',
											isSelected && 'bg-white/20 text-white'
										)}
									>
										{ageLabel}
									</span>
								)}
								{remainingTrials !== null && (
									<span
										className={cn(
											'inline-flex items-center rounded-md bg-mainPurple/10 px-2 py-1 text-[10px] font-semibold text-mainPurple',
											isSelected && 'bg-white/20 text-white'
										)}
									>
										{tSelect('ChildCard.TrialsLeft', {
											count: remainingTrials,
										})}
									</span>
								)}
								{typeof child.effective_class_price === 'number' && (
									<span
										className={cn(
											'inline-flex items-center rounded-md bg-amber-100 px-2 py-1 text-[10px] font-semibold text-amber-700',
											isSelected && 'bg-white/20 text-white'
										)}
									>
										{child.will_use_trial
											? tSelect('ChildCard.TrialCharge')
											: tSelect('ChildCard.FullCharge')}
										:
										<span className="ml-1">{child.effective_class_price}</span>
										<Image
											src="/icons/coin.svg"
											alt="Coin"
											width={12}
											height={12}
											className="ml-1"
										/>
									</span>
								)}
							</div>
						)}

						{hasTrialWalletInfo && (
							<div className="mt-1">
								{coinsToNextUnlock !== null && (
									<p
										className={cn(
											'mt-1 text-[11px] font-medium text-gray-500',
											isSelected && 'text-white/80'
										)}
									>
										{tSelect('ChildCard.CoinsToUnlock', {
											coins: coinsToNextUnlock,
										})}
									</p>
								)}
							</div>
						)}
					</div>

					{isForProfilePage && isSelected && isEditable && (
						<button
							onClick={(e) => {
								e.preventDefault();
								router.push(routes.profile.editChild(child.id));
							}}
							className={cn(
								'rounded-lg bg-black/10 !px-4 !py-1 text-sm font-semibold capitalize text-textGray',
								isSelected && 'bg-black/20 text-white'
							)}
						>
							{tEditBtn('EditBtn')}
						</button>
					)}
				</div>
			</div>

			{showProfileProgress && (
				<div className="mt-2 w-full text-inherit">
					{showProfileUnlockMeta && (
						<div
							className={cn(
								'mb-2 w-full px-0.5 text-mainPurple',
								isSelected && 'text-white'
							)}
						>
							<div className="flex flex-wrap items-center gap-1.5 text-[11px] font-semibold">
								<span>
									{tTrial('CoinsToNextUnlock', {
										count: coinsToNextUnlock,
									})}
								</span>
								{typeof child.next_unlock_at_total_paid_coins === 'number' && (
									<span
										className={cn(
											'text-[10px] font-bold text-mainPurple/90',
											isSelected && 'text-white/90'
										)}
									>
										{tTrial('NextUnlockTarget', {
											target: child.next_unlock_at_total_paid_coins,
										})}
									</span>
								)}
							</div>
						</div>
					)}
					<div
						className={cn(
							'mb-1 flex w-full items-center justify-between text-[11px] font-semibold text-gray-500',
							isSelected && 'text-white/80'
						)}
					>
						<span>{tTrial('ProgressLabel')}</span>
						<span>{progressPercent}%</span>
					</div>
					<div
						className={cn(
							'h-1.5 w-full rounded-full bg-mainPurple/10',
							isSelected && 'bg-white/25'
						)}
					>
						<div
							className={cn(
								'h-1.5 rounded-full bg-mainPurple transition-all duration-300',
								isSelected && 'bg-white'
							)}
							style={{ width: `${progressPercent}%` }}
						/>
					</div>
				</div>
			)}

			{/* reason */}
			{!isForProfilePage && !child.is_eligible && child.reason && (
				<Badge
					size="sm"
					variant="outline"
					color="danger"
					className="absolute -top-1.5 right-2"
				>
					{tCommon(reasonKey)}
				</Badge>
			)}
		</div>
	);
}
