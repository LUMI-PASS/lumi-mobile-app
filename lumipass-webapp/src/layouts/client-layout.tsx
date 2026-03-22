'use client';

import NavigationBar from '@/components/navigation-bar';
import { memo } from 'react';
import { usePathname } from '@/i18n/routing';
import { isAuthRoute } from '@/utils/route-utils';
import { useNavbar } from '@/contexts/navbar-context';

function ClientLayout({ children }: { children: React.ReactNode }) {
	const pathname = usePathname();
	const { isNavbarVisible } = useNavbar();

	// If it's an auth route, just render children without any layout
	if (isAuthRoute(pathname)) {
		return <>{children}</>;
	}

	return (
		<div className="flex flex-1 flex-col">
			{children}

			{isNavbarVisible && (
				<div className="bottom-nav-fixed fixed bottom-0 left-0 right-0 z-50 px-3 pb-2">
					<div className="mx-auto w-full max-w-[620px] rounded-[28px] border border-white/90 bg-white/85 shadow-[0_16px_30px_rgba(57,79,154,0.2)] backdrop-blur-xl">
						<NavigationBar />
					</div>
				</div>
			)}
		</div>
	);
}

export default memo(ClientLayout);
