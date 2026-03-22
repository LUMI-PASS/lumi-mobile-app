'use client';

import { useMemo } from 'react';
import { Badge } from 'rizzui';
import { PiCheckBold } from 'react-icons/pi';
import { useDrawer } from '@/app/shared/drawer-views/use-drawer';
import cn from '@/utils/class-names';
import CloseDrawerButton from '@/components/ui/buttons/close-drawer-button';
import { useTranslations } from 'next-intl';

type Option = { label: string; value: string };

export default function SortDrawerView({
	value,
	options,
	onPick,
	onClear,
}: {
	value: string | null;
	options: Option[];
	onPick: (v: string) => void;
	onClear: () => void;
}) {
	const t = useTranslations('Drawers.Sort');
	const { closeDrawer } = useDrawer();
	const hasValue = useMemo(() => !!value, [value]);

	const labelFor = (val: string, fallback?: string) => {
		switch (val) {
			case 'price:asc':
				return t('Options.LowPrice');
			case 'price:desc':
				return t('Options.HighPrice');
			case 'created_at:desc':
				return t('Options.Latest');
			default:
				return fallback ?? val;
		}
	};

	return (
		<div className="flex h-full flex-col gap-4 px-5 pb-3">
			<div className="relative flex items-center justify-between">
				<h3
					className={cn(
						'flex-1 text-center font-balsamiqSans text-2xl font-semibold text-textGray'
					)}
				>
					{t('Title')}
				</h3>
				{hasValue ? (
					<Badge
						onClick={() => {
							onClear();
							closeDrawer();
						}}
						className="absolute bottom-0 right-0 top-0 cursor-pointer rounded-xl border border-mainPurple/15 bg-mainPurple/10 text-mainPurple"
						variant="flat"
						size="md"
					>
						{t('Clear')}
					</Badge>
				) : (
					<CloseDrawerButton onClick={closeDrawer} />
				)}
			</div>

			<div className="space-y-2">
				{options.map((opt) => {
					const active = value === opt.value;
					return (
						<button
							key={opt.value}
							type="button"
							onClick={() => {
								onPick(opt.value);
								closeDrawer();
							}}
							className={cn(
								'flex w-full items-center justify-between rounded-xl border border-white/90 bg-white/90 px-4 py-3 text-left shadow-sm transition',
								'focus:outline-none focus:ring-2 focus:ring-primary/40',
								active
									? 'ring-2 ring-mainPurple/35 bg-mainPurple/10 text-mainPurple'
									: ''
							)}
							aria-pressed={active}
						>
							<span>{labelFor(opt.value, opt.label)}</span>
							<PiCheckBold
								className={cn('size-5', active ? 'opacity-100' : 'opacity-0')}
							/>
						</button>
					);
				})}
			</div>
		</div>
	);
}
