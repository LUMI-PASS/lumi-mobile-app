'use client';
import { useEffect, useRef } from 'react';
import { useSearchParams } from 'next/navigation';
import { usePathname } from '@/i18n/routing';
import ym, { YMInitializer } from 'react-yandex-metrika';
import { env } from '@/env.mjs';

const YM_ID = env.NEXT_PUBLIC_YM_ID;

export default function YandexMetrika() {
	const pathname = usePathname();
	const search = useSearchParams();
	const prevRef = useRef<string>('');

	useEffect(() => {
		if (!YM_ID || !pathname) return;
		const url = search?.toString() ? `${pathname}?${search}` : pathname;

		ym('hit', url, {
			referer: prevRef.current || undefined,
			title: document?.title,
		});
		prevRef.current = url;
	}, [pathname, search]);

	if (!YM_ID) return null;

	return (
		<YMInitializer
			accounts={[YM_ID]}
			options={{
				defer: true,
				webvisor: true,
				clickmap: true,
				trackLinks: true,
				accurateTrackBounce: true,
				ecommerce: 'dataLayer',
			}}
			version="2"
		/>
	);
}
