'use client';

import React, {
	createContext,
	useContext,
	useState,
	ReactNode,
	useEffect,
} from 'react';
import { usePathname } from '@/i18n/routing';
import { isAuthRoute } from '@/utils/route-utils';

interface NavbarContextType {
	isNavbarVisible: boolean;
	hideNavbar: () => void;
	showNavbar: () => void;
}

const NavbarContext = createContext<NavbarContextType | undefined>(undefined);

export function NavbarProvider({ children }: { children: ReactNode }) {
	const [isNavbarVisible, setIsNavbarVisible] = useState(true);
	const pathname = usePathname();

	// Hide navbar on auth routes automatically
	useEffect(() => {
		if (isAuthRoute(pathname)) {
			setIsNavbarVisible(false);
		} else {
			// Default to showing navbar when changing routes
			// (unless a component specifically calls hideNavbar)
			setIsNavbarVisible(true);
		}
	}, [pathname]);

	const hideNavbar = () => setIsNavbarVisible(false);
	const showNavbar = () => setIsNavbarVisible(true);

	return (
		<NavbarContext.Provider value={{ isNavbarVisible, hideNavbar, showNavbar }}>
			{children}
		</NavbarContext.Provider>
	);
}

export function useNavbar() {
	const context = useContext(NavbarContext);
	if (context === undefined) {
		throw new Error('useNavbar must be used within a NavbarProvider');
	}
	return context;
}
