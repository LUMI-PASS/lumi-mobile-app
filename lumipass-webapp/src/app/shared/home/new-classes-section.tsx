'use client';

import { useRef, useState } from 'react';
import { Class } from '@/types/index';
import ClassCard from '@/components/ui/widgets/class-card';
import EmptyState from '@/components/ui/exmpty-state';
import { Text } from 'rizzui/typography';
import { routes } from '@/config/routes';
import { useTranslations } from 'next-intl';
import { Loader } from 'rizzui/loader';
import { Link } from '@/i18n/routing';
import cn from '@/utils/class-names';
import { getHomeFeed } from '@/services/api';

interface NewClassesSectionProps {
	initialClasses: Class[];
	/** next page index to start fetching from (initial payload was page 1) */
	initialPage?: number;
}

const LIMIT = 10;

export default function NewClassesSection({
	initialClasses,
	initialPage = 2,
}: NewClassesSectionProps) {
	const t = useTranslations('Home');

  const [classes, setClasses] = useState<Class[]>(initialClasses ?? []);
	const [page, setPage] = useState<number>(initialPage);
	const [isLoading, setIsLoading] = useState(false);
	const [hasMore, setHasMore] = useState(true);

	// Track seen ids to avoid duplicate keys
	const seenIds = useRef<Set<string>>(
		new Set((initialClasses ?? []).map((c) => c.id))
	);

	const mergeUnique = (prev: Class[], incoming: Class[]) => {
		const out = [...prev];
		for (const item of incoming) {
			if (!seenIds.current.has(item.id)) {
				seenIds.current.add(item.id);
				out.push(item);
			}
		}
		return out;
	};

	const fetchMoreClasses = async () => {
		if (isLoading || !hasMore) return;
		setIsLoading(true);
		try {
			const response = await getHomeFeed({
				new_classes_page: page,
				new_classes_limit: LIMIT,
			});
			const incoming: Class[] = response?.data?.new_classes?.data ?? [];
			setClasses((prev) => mergeUnique(prev, incoming));
			setPage((p) => p + 1);
			if (incoming.length < LIMIT) setHasMore(false); // heuristic if API doesn't return meta
		} catch (error) {
			// console.error('Error fetching new classes:', error);
		} finally {
			setIsLoading(false);
		}
	};

	// NOTE: This container scrolls HORIZONTALLY, so check scrollLeft / scrollWidth
	const handleScroll = (e: React.UIEvent<HTMLDivElement>) => {
		const el = e.currentTarget;
		const reachedEnd = el.scrollLeft + el.clientWidth >= el.scrollWidth - 8; // small threshold
		if (reachedEnd && !isLoading && hasMore) {
			fetchMoreClasses();
		}
	};

	if (!classes || classes.length === 0) {
		return (
			<EmptyState
				message={t('NoNewClasses')}
				icon="/icons/nav/Search.svg"
				className="py-8"
			/>
		);
	}

	return (
		<div className="py-4">
			<div className="mb-3 flex items-center justify-between px-4">
				<Text as="strong" className="rounded-xl bg-white/70 px-3 py-1 text-base font-bold text-textGray shadow-sm">
					{t('NewlyAddedClasses')}
				</Text>
			</div>

			<div
				className="hide-scrollbar snap-x snap-mandatory scroll-pl-4 overflow-x-auto"
				onScroll={handleScroll}
			>
				<div
					className={cn(
						'flex snap-center py-1',
						classes.length == 1 && 'justify-center'
					)}
					style={{ minWidth: 'max-content' }}
				>
					{classes.map((classItem) => (
						<Link
							href={routes.classDetails(classItem.id)}
							key={classItem.id}
							className={cn(
								'ml-4 block w-[250px] snap-center last:mr-4',
								classes.length == 1 && 'w-[90vw] '
							)}
						>
              <ClassCard
                key={classItem.id}
                wrapBranch = {true}
								variant="vertical"
								classItem={classItem}
								showDescription
							/>
						</Link>
					))}
					{isLoading && (
						<div className="ml-4 flex items-center">
							<Loader size="sm" />
						</div>
					)}
				</div>
			</div>
		</div>
	);
}
