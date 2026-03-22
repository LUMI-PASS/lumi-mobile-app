'use client';

import { useState, useMemo } from 'react';
import { Button } from 'rizzui';
import Image from 'next/image';
import { useDrawer } from '@/app/shared/drawer-views/use-drawer';
import {
	PiCaretLeftBold,
	PiInfoDuotone,
	PiCreditCardDuotone,
} from 'react-icons/pi';
import { motion } from 'framer-motion';
import ChoosePackageView from './choose-package-view';
import { toast } from 'react-hot-toast';
import { PackageItem } from '@/types';
import CloseDrawerButton from '@/components/ui/buttons/close-drawer-button';
import { useTranslations } from 'next-intl';
import { usePathname } from '@/i18n/routing';
import { purchaseTariff } from '@/services/api'; 
import { formatPrice } from '@/utils/format-price';

interface PackageDetailsProps {
	packageData: PackageItem;
}

export default function PackageDetailsView({
	packageData,
}: PackageDetailsProps) {
	const { closeDrawer, openDrawer } = useDrawer();
	const [isLoading, setIsLoading] = useState(false);
	const t = useTranslations('Packages.Details');
	const pathname = usePathname() || '';

	// Hide back button if one of the URL segments is exactly "wallet"
	const hideBackButton = useMemo(() => {
		const segs = pathname.toLowerCase().split('/').filter(Boolean);
		return segs.includes('wallet');
	}, [pathname]);

	const handleBack = () => {
		// Only relevant when back button is visible (non-wallet contexts)
		closeDrawer();
		setTimeout(() => {
			openDrawer({
				view: <ChoosePackageView />,
				placement: 'bottom',
				height: '75vh',
			});
		}, 600);
	};

	const openExternal = (url: string) => {
		// Try opening a new tab first (preferred for "external browser" behavior on mobile as well)
		const win = window.open(url, '_blank', 'noopener,noreferrer');
		if (!win) {
			// Popup blocker? Fall back to a hard redirect in the same tab
			window.location.href = url;
		}
	};

	const handlePurchase = async (id: string) => {
		try {
			setIsLoading(true);
			const purchase = await purchaseTariff(id);
			const url = purchase?.transaction?.checkout_url;
			if (!url) {
				toast.error(t('Errors.MissingCheckoutUrl') ?? 'Missing checkout URL');
				return;
			}
			toast.success(t('RedirectingToPayme'));
			closeDrawer();
			// Remove the setTimeout and redirect immediately
			window.location.href = url;
		} catch (e) {
			toast.error(t('Errors.PurchaseFailed') ?? 'Purchase failed');
		} finally {
			setIsLoading(false);
		}
	};


	return (
		<motion.div
			initial={{ opacity: 0, y: 20 }}
			animate={{ opacity: 1, y: 0 }}
			transition={{ duration: 0.3 }}
			className="flex h-full flex-col px-5 pb-6"
		>
			{/* Header */}
			<div className="relative mb-6 flex items-center">
				{!hideBackButton && (
					<button
						onClick={handleBack}
						className="absolute bottom-0 left-0 top-0 mb-1 text-textGray"
						aria-label="Go back"
					>
						<PiCaretLeftBold size={20} />
					</button>
				)}
				<h2 className="flex-1 text-center font-balsamiqSans text-2xl font-bold text-textGray">
					{t('Title')}
				</h2>
				<CloseDrawerButton onClick={closeDrawer} />
			</div>

			<div className="flex flex-1 flex-col overflow-y-auto">
				{/* Package Header with Coins Badge */}
				<div className="mb-6 flex items-center justify-between">
					<div>
						<h3 className="text-xl font-bold text-primary">
							{packageData.title}
						</h3>
						{packageData.isPopular && (
							<span className="mt-1 inline-block rounded-full bg-amber-100 px-3 py-0.5 text-xs font-medium text-amber-700">
								{t('Popular')}
							</span>
						)}
					</div>
					<div className="flex items-center rounded-full bg-mainPurple/12 px-3 py-1">
						<span className="mr-1 text-base font-bold text-mainPurple">
							{packageData.coins}
						</span>
						<Image src="/icons/coin.svg" alt="Coin" width={24} height={24} />
					</div>
				</div>

				{/* Package Features in Cards */}
				<div className="mb-6 flex flex-col gap-4">
					{/* Price Info */}
					<div className="overflow-hidden rounded-xl border border-white/90 bg-white/90 shadow-sm">
						<div className="flex items-center justify-start gap-3 border-b border-gray-100 bg-gray-50/80 p-3">
							<div className="rounded-xl bg-mainPurple/10 p-2 text-mainPurple">
								<PiCreditCardDuotone className="h-5 w-5 text-inherit" />
							</div>
							<div>
								<h3 className="text-lg font-semibold text-textGray">
									{t('Price')}
								</h3>
							</div>
						</div>

						<div className="flex items-center justify-between p-4">
							<span className="font-medium">{t('Price')}:</span>
							<span className="font-bold text-mainPurple">
								{formatPrice(packageData.price)} {t('Currency')}
							</span>
						</div>
					</div>

					{/* Description Section */}
					{/* <div className="overflow-hidden rounded-xl border border-gray-100 bg-white shadow-sm">
						<div className="flex items-center justify-start gap-3 border-b border-gray-100 bg-gray-50 p-3">
							<div className="rounded-xl bg-purple-100 p-2">
								<PiInfoDuotone className="h-5 w-5 text-mainPurple" />
							</div>
							<div>
								<h3 className="text-lg font-semibold text-mainPurple">
									{t('Description')}
								</h3>
							</div>
						</div>

						<div className="p-4">
							<p className="leading-relaxed text-gray-600">
								{packageData.description || t('NoDescriptionAvailable')}
							</p>
						</div>
					</div> */}
				</div>

				{/* Purchase Button */}
				<div className="mt-auto pb-6 pt-4">
					<Button
						onClick={() => handlePurchase(packageData.id)}
						size="md"
						className="w-full rounded-2xl bg-mainPurple py-6 text-sm font-bold uppercase text-white shadow-[0_10px_22px_rgba(166,82,199,0.32)] transition-all hover:brightness-95 active:scale-[0.98]"
						isLoading={isLoading}
						disabled={isLoading}
						rel={"noopener noreferrer"}
					>
						{t('Purchase')}
					</Button>
				</div>
			</div>
		</motion.div>
	);
}
