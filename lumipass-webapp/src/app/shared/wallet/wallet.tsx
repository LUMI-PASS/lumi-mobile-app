'use client';

import { useEffect, useMemo, useState } from 'react';
import Image from 'next/image';
import { Button, Empty, Loader, SearchNotFoundIcon } from 'rizzui';
import {
	PiArrowDownBold,
	PiArrowUpBold,
	PiClockClockwiseDuotone,
	PiDotsThreeCircleVertical,
	PiInfoBold,
} from 'react-icons/pi';
import { useDrawer } from '@/app/shared/drawer-views/use-drawer';
import { getTariffs, getUserBalance, getCoinUsage } from '@/services/api';
import PackageCard from '@/components/ui/package-card';
import PackageDetailsView from '@/app/shared/views/package-details-view';
import { WalletResponse, PackageItem } from '@/types';
import { formatDateTime } from '@/utils/format-dateTime';
import cn from '@/utils/class-names';
import { BanknotesIcon } from '@heroicons/react/24/outline';
import { useLocale, useTranslations } from 'next-intl';
import {
	PackageTileSkeleton,
	WalletBalanceSkeleton,
	WalletHistorySkeleton,
} from '@/components/ui/skeletons';
import { CoinFlow } from '@/types';
export default function WalletView() {
	const { openDrawer } = useDrawer();
	const t = useTranslations('Wallet');
	const locale = useLocale();

	// Balance
	const [balance, setBalance] = useState<number>(0);
	const [expiresAt, setExpiresAt] = useState<string | null>(null);

	// Packages
	const [packages, setPackages] = useState<PackageItem[]>([]);
	const [pkgLoading, setPkgLoading] = useState(true);

	// History (plain array + client "show more")
	const [history, setHistory] = useState<CoinFlow[]>([]);
	const [histLoading, setHistLoading] = useState(true);
	const [visibleCount, setVisibleCount] = useState(5); // show 5 rows at a time
	const [balLoading, setBalLoading] = useState(true);

	// Fetch balance + packages
	useEffect(() => {
		(async () => {
			try {
				const w = (await getUserBalance()) as WalletResponse;
				setBalance(w?.balance ?? 0);
				if (w?.actual_deadline) setExpiresAt(w.actual_deadline);
			} finally {
				setBalLoading(false);
			}
		})();

		(async () => {
			try {
				setPkgLoading(true);
				const res: any = await getTariffs();
				if (res?.success && Array.isArray(res.data)) {
					const enhanced = res.data.map((p: PackageItem, i: number) => ({
						...p,
						discount:
							i % 2 === 1 ? Math.floor(Math.random() * 15) + 5 : undefined,
						isPopular: i === 1,
					}));
					setPackages(enhanced);
				}
			} finally {
				setPkgLoading(false);
			}
		})();
	}, []);

	// Fetch coin flows (new endpoint: /coin-flows/me)
	const fetchHistory = async () => {
		try {
			setHistLoading(true);
			const list = await getCoinUsage(); // returns CoinFlow[]
			// Sort newest first for consistent display
			list.sort(
				(a, b) =>
					new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
			);
			setHistory(list);
		} catch (e) {
			// console.error('Failed to fetch coin flows', e);
		} finally {
			setHistLoading(false);
		}
	};

	useEffect(() => {
		fetchHistory();
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	// Can we reveal more?
	const canLoadMore = visibleCount < history.length;

	// Group only the visible items
	const grouped = useMemo(() => {
		const slice = history.slice(0, visibleCount);
		const m = new Map<string, CoinFlow[]>();
		for (const it of slice) {
			const d = it.created_at ? new Date(it.created_at) : null;
			const key = d
				? d.toLocaleDateString(locale || undefined, {
						day: 'numeric',
						month: 'long',
					})
				: t('Recent');
			if (!m.has(key)) m.set(key, []);
			m.get(key)!.push(it);
		}
		return Array.from(m.entries());
	}, [history, visibleCount, locale, t]);

	const showMore = () => {
		if (visibleCount < history.length) {
			setVisibleCount((c) => c + 5);
		}
	};

	return (
		<div className="flex min-h-screen flex-col px-4 pb-24 pt-8">
			<h1 className="app-page-title mb-5">
				{t('Title')}
			</h1>

			{/* Balance card */}
			{balLoading ? (
				<WalletBalanceSkeleton />
			) : (
				<div className="mb-6 rounded-[22px] border border-mainPurple/15 bg-gradient-to-r from-violet-50 via-fuchsia-50 to-pink-50 p-4 shadow-sm">
					<div className="flex items-center justify-between">
						<div className="flex items-center text-sm font-semibold text-textGray">
							<span>{t('YourBalance')}</span>
							<span className="mb-0.5">:</span>{' '}
						</div>
						<div className="flex items-center">
							<span className="mr-2 text-2xl font-bold text-mainPurple">
								{balance}
							</span>
							<Image src="/icons/coin.svg" alt="Coin" width={28} height={28} />
						</div>
					</div>
				</div>
			)}

			{/* Packages to buy */}
			<h2 className="mb-4 flex items-center gap-1 text-lg font-semibold text-textGray">
				<BanknotesIcon className="inline-block size-5" />
				{t('BuyTariff')}
			</h2>
			{pkgLoading ? (
				<div className="mb-8 grid grid-cols-2 gap-x-4 gap-y-5">
					{Array.from({ length: 4 }).map((_, i) => (
						<PackageTileSkeleton key={i} />
					))}
				</div>
			) : packages.length === 0 ? (
				<div className="mb-6 rounded-xl border border-white/90 bg-white/85 p-4 shadow-sm">
					<Empty text={t('NoTariffs')} />
				</div>
			) : (
				<div className="mb-8 grid grid-cols-2 gap-x-4 gap-y-5">
					{packages.map((p) => (
						<PackageCard
							data={p}
							key={p.id}
							selected={false}
							allowUnselect={false}
							onSelect={() =>
								openDrawer({
									view: <PackageDetailsView packageData={p} />,
									placement: 'bottom',
									height: '55vh',
								})
							}
						/>
					))}
				</div>
			)}

			{/* Usage history */}
			<h2 className="mb-3 flex items-center gap-1 text-lg font-semibold text-textGray">
				<PiClockClockwiseDuotone className="inline-block size-5" />
				{t('History')}
			</h2>

			<div className="flex-1">
				{histLoading && history.length === 0 ? (
					<WalletHistorySkeleton groups={2} itemsPerGroup={3} />
				) : history.length === 0 ? (
					<div className="rounded-xl border border-white/90 bg-white/85 p-6 shadow-sm">
						<Empty
							text={t('NoHistory')}
							image={<SearchNotFoundIcon className="h-32 w-auto" />}
						/>
					</div>
				) : (
					<div className="space-y-4">
						{grouped.map(([day, items]) => (
							<div key={day}>
								<div className="mb-2 text-sm font-normal text-textGray">
									{day}
								</div>

								<div className="space-y-3">
									{items.map((it) => {
										const isOut = it.type === 'WITHDRAW';
										const amount = Number(it.amount) || 0;

										return (
											<div
												key={it.id}
												className="flex items-center justify-between rounded-2xl border border-white/90 bg-white/90 p-4 shadow-[0_8px_20px_rgba(60,83,154,0.12)]"
											>
												<div className="flex items-center gap-3">
													<div className="grid size-12 place-content-center rounded-xl bg-white ring-1 ring-black/10">
														{isOut ? (
															<PiArrowUpBold className="size-6 text-red-500" />
														) : (
															<PiArrowDownBold className="size-6 text-green-600" />
														)}
													</div>

													<div>
														<div className="text-sm font-semibold text-textGray">
															{it.type === 'WITHDRAW'
																? t('Spent')
																: t('Bought')}
														</div>
														<div className="text-xs text-gray-500">
															{formatDateTime(it.created_at, 'time')}
														</div>
													</div>
												</div>

												<div
													className={cn(
														'flex items-center justify-center gap-0.5 text-base',
														isOut
															? 'font-bold text-red-500'
															: 'font-bold text-green-700'
													)}
												>
													{isOut ? '-' : '+'}
													{amount}
													<Image
														src="/icons/coin.svg"
														alt="Lumi Coin"
														width={24}
														height={24}
														className="inline-block"
													/>
												</div>
											</div>
										);
									})}
								</div>
							</div>
						))}

						{canLoadMore && (
							<div className="flex justify-center pt-2">
								<Button
									onClick={showMore}
									className="grid size-10 place-content-center rounded-full border border-white/90 bg-white p-0 shadow-sm hover:bg-white"
									aria-label={t('LoadMore')}
								>
									<PiArrowDownBold className="size-5 text-textGray" />
								</Button>
							</div>
						)}
					</div>
				)}
			</div>

			{/* Low balance hint */}
			{balance < 10 && (
				<div className="mt-6 rounded-xl bg-amber-50/90 p-3 text-sm text-amber-700 ring-1 ring-amber-200">
					<div className="flex items-start gap-2">
						<PiInfoBold size={20} className="text-inherit" />
						<p>{balance === 0 ? t('LowBalanceZero') : t('LowBalance')}</p>
					</div>
				</div>
			)}
		</div>
	);
}
