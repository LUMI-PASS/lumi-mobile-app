'use client';

import Image from 'next/image';
import { motion } from 'framer-motion';
import { PiCheckCircleFill, PiCrownSimple } from 'react-icons/pi';
import cn from '@/utils/class-names';
import { PackageItem } from '@/types';
import { formatPrice } from '@/utils/format-price';
import { useTranslations } from 'next-intl';

type Props = {
	data: PackageItem;
	selected?: boolean;
	onSelect?: (id: string | null) => void;
	className?: string;
	allowUnselect?: boolean;
};

export default function PackageCard({
	data,
	selected = false,
	onSelect,
	className,
	allowUnselect = true,
}: Props) {
	const tCurrency = useTranslations('Packages.Details');
	const handleClick = () => {
		if (!onSelect) return;
		if (selected && allowUnselect) onSelect(null);
		else onSelect(data.id);
	};

	const handleKeyDown: React.KeyboardEventHandler<HTMLDivElement> = (e) => {
		if (!onSelect) return;
		if (e.key === 'Enter' || e.key === ' ') {
			e.preventDefault();
			handleClick();
		}
	};

	return (
		<motion.div
			whileTap={{ scale: 0.99 }}
			onClick={handleClick}
			onKeyDown={handleKeyDown}
			role="button"
			tabIndex={0}
			aria-pressed={selected}
			className={cn(
				'stagger-in relative cursor-pointer select-none overflow-hidden rounded-[22px] border border-white/90 bg-white/90 transition-all duration-300',
				selected
					? 'shadow-[0_14px_28px_rgba(36,174,116,0.22)] ring-2 ring-green-500'
					: 'shadow-[0_8px_20px_rgba(60,83,154,0.12)]',
				className
			)}
		>
			{/* Popular ribbon */}
			{data.isPopular && (
				<div className="absolute -right-11 top-4 rotate-45 bg-mainPink px-11 text-center text-[10px] font-bold text-white">
					POPULAR
				</div>
			)}

			{/* Title stripe */}
			<div
				className={cn(
					'line-clamp-1 w-full bg-mainPurple py-2 text-center text-sm font-bold text-white',
					selected && 'bg-green-600'
				)}
			>
				{data.title}
			</div>

			<div className="flex flex-col items-start justify-between p-4">
				<div className="mt-1 flex w-full items-center justify-start gap-1 font-bold text-mainPurple">
					<span className="text-lg">{data.coins}</span>
					<Image src="/icons/coin.svg" alt="Coin" width={26} height={26} />
				</div>

				<div className="mt-2 text-xs font-bold text-textGray">
					{formatPrice(data.price)} {tCurrency('Currency')}
				</div>

				{selected && (
					<div className="absolute bottom-2 right-2 text-green-600">
						<PiCheckCircleFill size={20} />
					</div>
				)}
			</div>
		</motion.div>
	);
}
