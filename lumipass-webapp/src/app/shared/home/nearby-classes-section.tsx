'use client';

import { useEffect, useRef, useState } from 'react';
import { Class } from '@/types/index';
import ClassCard from '@/components/ui/widgets/class-card';
import EmptyState from '@/components/ui/exmpty-state';
import { Text } from 'rizzui/typography';
import { Link } from '@/i18n/routing';
import { routes } from '@/config/routes';
import { useTranslations } from 'next-intl';
import { Loader } from 'rizzui/loader';
import { getHomeFeed } from '@/services/api';

interface NearMeClassesSectionProps {
	initialClasses: Class[];
	/** next page index to start fetching from (initial payload was page 1) */
	initialPage?: number;
}

const LIMIT = 10;

export default function NearbyClassesSection({
	initialClasses,
	initialPage = 2,
}: NearMeClassesSectionProps) {
	const t = useTranslations('Home');
	const [classes, setClasses] = useState<Class[]>(initialClasses ?? []);
	const [page, setPage] = useState<number>(initialPage);
	const [isLoading, setIsLoading] = useState(false);
	const [hasMore, setHasMore] = useState(true);

	// Track seen ids to avoid duplicates
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
				near_class_page: page,
				near_class_limit: LIMIT,
			});
			const incoming: Class[] = response?.data?.near_classes?.data ?? [];
			setClasses((prev) => mergeUnique(prev, incoming));
			setPage((p) => p + 1);
			if (incoming.length < LIMIT) setHasMore(false);
		} catch (error) {
			// console.error('Error fetching near classes:', error);
		} finally {
			setIsLoading(false);
		}
	};

	// Your div doesn't scroll; the page does. Add a window scroll listener.
	useEffect(() => {
		const onScroll = () => {
			const nearBottom =
				window.innerHeight + window.scrollY >=
				document.documentElement.scrollHeight - 200;
			if (nearBottom && !isLoading && hasMore) {
				fetchMoreClasses();
			}
		};
		window.addEventListener('scroll', onScroll, { passive: true });
		return () => window.removeEventListener('scroll', onScroll);
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [isLoading, hasMore, page]);

	// Keep your existing handler (harmless if container doesn't scroll)
	const handleScroll = (e: React.UIEvent<HTMLDivElement>) => {
		const el = e.currentTarget;
		const atBottom = el.scrollHeight - el.scrollTop - el.clientHeight < 8;
		if (atBottom && !isLoading && hasMore) {
			fetchMoreClasses();
		}
	};

	if (!classes || classes.length === 0) {
		return (
			<EmptyState
				message={t('NoNearClasses')}
				icon="/icons/nav/Search.svg"
				className="py-8"
			/>
		);
	}

	return (
		<div className="px-4 py-4">
			<div className="mb-3 flex items-center justify-between">
				<Text as="p" className="rounded-xl bg-white/70 px-3 py-1 text-base font-bold text-textGray shadow-sm">
					{t('NearYou')}
				</Text>
			</div>

			<div className="space-y-5" onScroll={handleScroll}>
				{classes.map((classItem) => (
					<Link
						href={routes.classDetails(classItem.id)}
						key={classItem.id}
						className="block"
					>
						<ClassCard
							key={classItem.id}
							wrapBranch={false}
							classItem={classItem}
							variant="vertical"
							showDescription
						/>
					</Link>
				))}
			</div>
			{isLoading && (
				<div className="mt-3 flex justify-center">
					<Loader color="primary" size="sm" />
				</div>
			)}
		</div>
	);
}
