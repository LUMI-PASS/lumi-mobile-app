'use client';

import { useEffect, useState } from 'react';
import { useRouter, usePathname } from '@/i18n/routing';
import { useAuth } from '@/contexts/auth-context';
import { routes } from '@/config/routes';

// Routes that don't require authentication
const publicRoutes = [
	routes.auth.signIn,
	routes.auth.signUp,
	routes.auth.otp,
	'/access-denied',
];

export default function AuthGuard({ children }: { children: React.ReactNode }) {
	const { isAuthenticated, isLoading } = useAuth();
	const router = useRouter();
	const pathname = usePathname();
	const [checking, setChecking] = useState(true);

	useEffect(() => {
		if (isLoading) return;

		const isPublicRoute = publicRoutes.some(
			(route) => pathname?.includes(route) || pathname === '/'
		);

		if (!isAuthenticated && !isPublicRoute) {
			router.replace(routes.auth.signIn);
		}

		setChecking(false);
	}, [isAuthenticated, isLoading, pathname, router]);

	// Don't render anything while checking auth status
	if (checking || isLoading) {
		return null;
	}

	return <>{children}</>;
}
