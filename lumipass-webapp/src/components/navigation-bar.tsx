'use client';

import { Link, usePathname } from '@/i18n/routing';
import { NavbarItem } from './navbar-item';
import { navbarItems } from '@/config/navbar.config';
import { memo, useMemo } from 'react';
import { routing } from '@/i18n/routing';

interface NavigationBarProps {
	isRequiredPage?: boolean;
}

function NavigationBar({ isRequiredPage = false }: NavigationBarProps) {
	const pathname = usePathname();

	const { afterLocaleSegs } = useMemo(() => {
		const rawSegs = pathname.split('/').filter(Boolean);
		const maybeLocale = rawSegs[0];
		const isKnownLocale = routing.locales.includes(maybeLocale as any);
		const rest = isKnownLocale ? rawSegs.slice(1) : rawSegs;
		return { afterLocaleSegs: rest };
	}, [pathname]);

	if (isRequiredPage) return null;

	const isRouteActive = (item: any) => {
		if (item.label === 'home') {
			return afterLocaleSegs.length === 0;
		}

		const first = afterLocaleSegs[0] ?? '';
		return first === item.label;
	};

	return (
		<div className="flex flex-shrink-0 items-center justify-around px-3 py-3">
			{navbarItems.map((item) => (
				<Link href={item.route} key={item.route} className="block">
					<NavbarItem active={isRouteActive(item)} aria-label={item.label}>
						{item.icon}
					</NavbarItem>
				</Link>
			))}
		</div>
	);
}

export default memo(NavigationBar);
