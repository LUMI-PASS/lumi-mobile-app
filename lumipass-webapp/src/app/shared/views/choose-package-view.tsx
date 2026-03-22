'use client';

import { useEffect, useState } from 'react';
import { Button, Empty, EmptyProductBoxIcon } from 'rizzui'; // ⬅️ added Empty, EmptyProductBoxIcon
import Image from 'next/image';
import { useDrawer } from '@/app/shared/drawer-views/use-drawer';
import { PiInfoBold } from 'react-icons/pi';
import cn from '@/utils/class-names';
import PackageDetailsView from './package-details-view';
import { getTariffs, getUserBalance } from '@/services/api';
import PackageCard from '@/components/ui/package-card';
import { PackageItem, WalletResponse, TariffsResponse } from '@/types';
import CloseDrawerButton from '@/components/ui/buttons/close-drawer-button';
import { useTranslations } from 'next-intl';
import { PackagesDrawerSkeleton } from '@/components/ui/skeletons';

export default function ChoosePackageView() {
	const { closeDrawer, openDrawer } = useDrawer();
	const [selectedOption, setSelectedOption] = useState<string | null>(null);
	const [packages, setPackages] = useState<PackageItem[]>([]);
	const [isLoading, setIsLoading] = useState(true);
	const [error, setError] = useState<string | null>(null);
	const [userBalance, setUserBalance] = useState<number>(0);

	const t = useTranslations('Drawers.Packages');
	const tEmpty = useTranslations('Explore');

	useEffect(() => {
		const fetchPackages = async () => {
			try {
				setIsLoading(true);
        const response = (await getTariffs()) as TariffsResponse;
        // console.log("Packages response:",response);
				if (response?.success) {
					const raw = response?.data;
					if (!Array.isArray(raw) || raw.length === 0) {
						setPackages([]);
					} else {
						const enhanced = raw.map((pkg, i) => ({
							...pkg,
							discount:
								i % 2 === 1 ? Math.floor(Math.random() * 15) + 5 : undefined,
							isPopular: i === 1,
						}));
						setPackages([...enhanced]);
					}
					setIsLoading(false);
				} else {
					setError('Failed to load packages');
				}
				try {
					const wallet = (await getUserBalance()) as WalletResponse;
					if (wallet && typeof wallet.balance === 'number') {
						setUserBalance(wallet.balance);
					}
				} catch {}
			} catch {
				setError('Failed to load packages. Please try again.');
			} finally {
				setIsLoading(false);
			}
		};

		fetchPackages();
	}, []);

	const handlePackageSelect = (optionId: string | null) => {
		setSelectedOption(optionId);
	};

	const handleNext = () => {
		const selected = packages.find((p) => p.id === selectedOption);
		if (!selected) return;

		closeDrawer();
		setTimeout(() => {
			openDrawer({
				view: <PackageDetailsView packageData={selected} />,
				placement: 'bottom',
				height: '50vh',
			});
		}, 650);
	};

	if (isLoading) {
		return <PackagesDrawerSkeleton />;
	}

	if (error) {
		return (
			<div className="flex h-full flex-col items-center justify-center px-5 py-6">
				<div className="rounded-full bg-red-100 p-4">
					<PiInfoBold size={32} className="text-red-500" />
				</div>
				<p className="mt-4 text-center text-red-500">{t('LoadError')}</p>
				<Button
					onClick={() => window.location.reload()}
					className="mt-6 rounded-xl bg-mainPurple px-6 py-3 text-white shadow-[0_8px_20px_rgba(166,82,199,0.32)]"
				>
					{t('TryAgain')}
				</Button>
			</div>
		);
	}

	return (
		<div className="relative flex h-full flex-col px-5 pb-6">
			{/* Header */}
			<div className="relative mb-6 flex items-center">
				<h2 className="flex-1 text-center font-balsamiqSans text-2xl font-bold text-textGray">
					{t('ChoosePackage')}
				</h2>
				<CloseDrawerButton onClick={closeDrawer} />
			</div>
			{/* Scroll area */}
			<div className="flex h-full flex-col overflow-y-auto pb-20">
				{/* Balance */}
				<div className="mb-6 rounded-[22px] border border-mainPurple/15 bg-gradient-to-r from-violet-50 via-fuchsia-50 to-pink-50 p-4 shadow-sm">
					<div className="mb-3 flex items-center justify-between">
						<div className="text-sm font-semibold text-textGray">
							{t('YourBalance')}
						</div>
						<div className="flex items-center">
							<span className="mr-2 text-2xl font-bold text-mainPurple">
								{userBalance}
							</span>
							<Image src="/icons/coin.svg" alt="Coin" width={28} height={28} />
						</div>
					</div>

					{userBalance < 10 && (
						<div className="flex items-start gap-2 rounded-lg bg-white/50 p-3 backdrop-blur-sm">
							<PiInfoBold size={18} className="mt-0.5 text-mainPurple" />
							<p className="text-xs font-medium text-gray-600">
								{userBalance === 0 ? t('NoCoins') : t('LowCoins')}
							</p>
						</div>
					)}
				</div>

				{/* Packages OR Empty fallback */}
				{packages.length === 0 ? (
					<div className="flex flex-1 items-center justify-center py-10">
						<Empty
							text={tEmpty('Empty')}
							image={<EmptyProductBoxIcon className="size-40 text-gray-700" />}
						/>
					</div>
				) : (
					<div className="mb-8 grid grid-cols-2 gap-4">
						{packages.map((pkg) => (
							<PackageCard
								key={pkg.id}
								data={pkg}
								selected={pkg.id === selectedOption}
								onSelect={handlePackageSelect}
							/>
						))}
					</div>
				)}
			</div>
			{/* Floating CTA */}
			{packages.length !== 0 && (
				<div className="fixed bottom-0 left-0 right-0 bg-gradient-to-t from-white via-white/80 to-transparent px-3 py-7">
					<div className="mx-auto max-w-[75%]">
						<Button
							size="lg"
							onClick={handleNext}
							className={cn(
								'flex w-full items-center justify-center gap-2 rounded-2xl bg-mainPurple py-6 font-bold text-white shadow-[0_10px_22px_rgba(166,82,199,0.32)] outline-0 ring-0'
							)}
							disabled={!selectedOption}
						>
							{t('Next')}
						</Button>
					</div>
				</div>
			)}
		</div>
	);
}
