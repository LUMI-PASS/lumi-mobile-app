'use client';

import { useEffect, useState } from 'react';
import { warmLocation, initializeLocation } from '@/utils/location-cache';
import Header from '@/components/header';
import UpcomingClass from '@/app/shared/home/upcoming-class';
import BannerSlider from '@/app/shared/home/banner-slider';
import CategoriesSection from '@/app/shared/home/categories-section';
import NewClassesSection from '@/app/shared/home/new-classes-section';
import NearMeClassesSection from '@/app/shared/home/nearby-classes-section';
import { getHomeFeed } from '@/services/api';
import { HomeFeedResponse } from '@/types/index';
import { isAuthRoute } from '@/utils/route-utils';
import { usePathname } from '@/i18n/routing';
import {
	CategorySkeleton,
	ClassCardSkeleton,
	UpcomingClassSkeleton,
} from '@/components/ui/skeletons';
import { useTranslations } from 'next-intl';
import { useAuth } from '@/contexts/auth-context';
import toast from 'react-hot-toast';

export default function HomeView() {
	const [homeData, setHomeData] = useState<HomeFeedResponse | null>(null);
	const [isLoading, setIsLoading] = useState<boolean>(true);
	const pathname = usePathname();
	const t = useTranslations('Home');
	const { logout } = useAuth();
	const isAuthPath = isAuthRoute(pathname);

	useEffect(() => {
		if (isAuthPath) return;

		let isMounted = true;
		const fetchHomeData = async () => {
			try {
				setIsLoading(true);
				const data = await getHomeFeed({
					new_classes_page: 1,
					new_classes_limit: 10,
					category_page: 1,
					category_limit: 10,
					near_class_page: 1,
					near_class_limit: 10,
				});

				if (!isMounted) return;
				if (data.data == null) {
					toast.error(t('ServerError'));
					logout();
					return;
				}

				setHomeData(data);
				setIsLoading(false);
			} catch (err: any) {
				if (!isMounted) return;
				setIsLoading(false);

				if (err?.status === 401 || err?.code === 401) {
					logout();
					return;
				}

				// Optional: keep your generic error path
				// console.error('Error fetching home data:', err);
			}
		};

		fetchHomeData();
		initializeLocation();
		warmLocation({ freshWithinMs: 0, desiredAccuracy: 50 });
		return () => {
			isMounted = false;
		};
	}, [isAuthPath, logout, t]);

	if (isAuthPath) {
		return null;
	}

	return (
		<div className="flex min-h-screen flex-col pb-20 pt-[calc(112px+env(safe-area-inset-top))]">
			<div className="fixed left-0 right-0 top-0 z-50 pt-[env(safe-area-inset-top)]">
				<div className="relative">
					<Header />
				</div>
			</div>

			{/* Main scrollable content */}
			<div className="bg-transparent">
				{isLoading ? (
					<UpcomingClassSkeleton />
				) : (
					homeData?.data?.upcoming_class &&
					homeData.data.upcoming_class !== null && (
						<UpcomingClass upcomingClass={homeData.data.upcoming_class} />
					)
				)}
				{!isLoading &&
					homeData?.data.banners &&
					homeData.data.banners !== null && (
						<BannerSlider banners={homeData.data.banners} />
					)}
				{isLoading ? (
					<div className="py-3">
						<div className="mb-6 flex items-center justify-between px-4">
							<div className="h-5 w-40 animate-pulse rounded bg-gray-200"></div>
							<div className="h-4 w-14 animate-pulse rounded bg-gray-200"></div>
						</div>
						<div className="hide-scrollbar flex overflow-x-auto pl-4">
							{[1, 2, 3, 4].map((i) => (
								<CategorySkeleton key={i} className="mr-4" />
							))}
						</div>
					</div>
				) : (
					homeData?.data.categories?.data &&
					homeData.data.categories.data !== null && (
						<CategoriesSection categories={homeData.data.categories.data} />
					)
				)}
				{isLoading ? (
					<div className="py-3">
						<div className="mb-4 flex items-center justify-between px-4">
							<div className="h-5 w-40 animate-pulse rounded bg-gray-200"></div>
							<div className="h-4 w-14 animate-pulse rounded bg-gray-200"></div>
						</div>
						<div className="hide-scrollbar flex overflow-x-auto pl-4">
							{[1, 2, 3].map((i) => (
								<ClassCardSkeleton key={i} className="mr-4 min-w-[240px]" />
							))}
						</div>
					</div>
				) : (
					homeData?.data.new_classes?.data &&
					homeData.data.new_classes.data !== null && (
						<NewClassesSection
							initialClasses={homeData.data.new_classes.data}
							initialPage={2}
						/>
					)
				)}
				{isLoading ? (
					<div className="px-4 py-3">
						<div className="mb-4 flex items-center justify-between">
							<div className="h-5 w-40 animate-pulse rounded bg-gray-200"></div>
						</div>
						<div className="space-y-4">
							{[1, 2].map((i) => (
								<ClassCardSkeleton key={i} variant="horizontal" />
							))}
						</div>
					</div>
				) : (
					homeData?.data.near_classes?.data &&
					homeData.data.near_classes.data !== null && (
						<NearMeClassesSection
							initialClasses={homeData.data.near_classes.data}
							initialPage={2}
						/>
					)
				)}
			</div>
		</div>
	);
}
