'use client';

import { Category } from '@/types/index';
import CategoryCard from '@/components/ui/widgets/category-card';
import EmptyState from '@/components/ui/exmpty-state';
import { Text } from 'rizzui/typography';
import { routes } from '@/config/routes';
import { useTranslations } from 'next-intl';

interface CategoriesSectionProps {
	categories: Category[];
}

export default function CategoriesSection({
	categories,
}: CategoriesSectionProps) {
	const t = useTranslations('Home');

	if (!categories || categories.length === 0)
		return (
			<EmptyState
				message={t('NoCategories')}
				icon="/icons/nav/Search.svg"
				className="py-8"
			/>
		);

	return (
		<div className="py-4">
			<div className="mb-3 flex items-center justify-between px-4">
				<Text as="strong" className="rounded-xl bg-white/70 px-3 py-1 text-base text-textGray shadow-sm">
					{t('AllCategories')}
				</Text>
			</div>

			<div className="hide-scrollbar snap-x snap-mandatory scroll-pl-4 overflow-x-auto">
				<div
					className="flex snap-center py-0.5"
					style={{ minWidth: 'max-content' }}
				>
					{categories.map((category) => (
						<div
							key={category.id}
							className="ml-4 min-w-[150px] snap-center last:mr-4"
						>
							<CategoryCard
								category={category}
								href={`${routes.explore}?category=${encodeURIComponent(category.id)}`}
							/>
						</div>
					))}
				</div>
			</div>
		</div>
	);
}
