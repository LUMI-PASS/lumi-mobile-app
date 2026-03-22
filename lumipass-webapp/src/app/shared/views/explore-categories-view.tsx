'use client';

import { useMemo } from 'react';
import { Badge, Empty, Loader, SearchNotFoundIcon } from 'rizzui';
import CategoryCard from '@/components/ui/widgets/category-card';
import cn from '@/utils/class-names';
import { useDrawer } from '@/app/shared/drawer-views/use-drawer';
import { Category } from '@/types';
import CloseDrawerButton from '@/components/ui/buttons/close-drawer-button';
import { useTranslations } from 'next-intl';

interface ExploreCategoriesViewProps {
	categories: Category[];
	isLoading?: boolean;
	selectedCategory: string | null;
	onPick: (categoryId: string) => void;
	onClear: () => void;
}

export default function ExploreCategoriesView({
	categories,
	isLoading,
	selectedCategory,
	onPick,
	onClear,
}: ExploreCategoriesViewProps) {
	const { closeDrawer } = useDrawer();
	const t = useTranslations('Drawers.Explore');
	const handlePick = (id: string) => {
		onPick(id);
		closeDrawer();
	};

	const handleClear = () => {
		onClear();
		closeDrawer();
	};

	const grid = useMemo(() => {
		if (isLoading) {
			return (
				<div className="grid grid-cols-2 justify-center gap-4">
					{Array.from({ length: 6 }).map((_, i) => (
						<div
							key={i}
							className="h-44 animate-pulse rounded-2xl bg-gray-200"
						/>
					))}
				</div>
			);
		}

		if (!categories || categories.length === 0) {
			return (
				<div className="col-span-2 flex h-full flex-col items-center justify-center">
					<Empty
						className="py-20 font-lexend"
						image={<SearchNotFoundIcon className="h-44 w-full" />}
						text={t('NoCategories')}
					/>
				</div>
			);
		}

		return (
			<div className="grid grid-cols-2 justify-center gap-4 px-1 py-2">
				{categories.map((category) => (
					<button
						key={category.id}
						type="button"
						onClick={() => handlePick(category.id)}
						className="cursor-pointer text-left"
					>
						<CategoryCard
							category={category}
							active={selectedCategory === category.id}
							variant="overlay"
							size="md"
						/>
					</button>
				))}
			</div>
		);
	}, [categories, isLoading, selectedCategory]);

	return (
		<div className="flex h-full flex-col px-5 pb-6">
			<div className="relative mb-6 min-h-10">
				<h3
					className={cn(
						'pointer-events-none absolute inset-x-0 top-[62%] -translate-y-1/2 px-14 text-center font-balsamiqSans text-2xl leading-tight text-textGray'
					)}
				>
					{t('PickCategory')}
				</h3>
				{selectedCategory ? (
					<Badge
						onClick={handleClear}
						className="absolute right-0 top-1/2 -translate-y-1/2 cursor-pointer whitespace-nowrap rounded-xl border border-mainPurple/15 bg-mainPurple/10 px-3 py-1.5 text-mainPurple"
						variant="flat"
						size="md"
					>
						{t('Clear')}
					</Badge>
				) : (
					<CloseDrawerButton
						onClick={closeDrawer}
						className="bottom-auto top-1/2 -translate-y-1/2"
					/>
				)}
			</div>

			<div className="overflow-y-auto h-full flex-1 min-h-[240px]">{grid}</div>
		</div>
	);
}
