'use client';

import { atom, useAtomValue, useSetAtom } from 'jotai';
export type DrawerPlacements = 'left' | 'right' | 'top' | 'bottom';

export type DrawerType = {
	id: string;
	view: React.ReactNode;
	isOpen: boolean;
	placement: DrawerPlacements;
	height?: string | number;
	containerClassName?: string;
};

const drawerAtom = atom<DrawerType | null>(null);
let closeTimer: ReturnType<typeof setTimeout> | null = null;

export function useDrawer() {
	const drawer = useAtomValue(drawerAtom);
	const setDrawer = useSetAtom(drawerAtom);

	const openDrawer = ({
		view,
		placement = 'bottom',
		height,
		containerClassName,
	}: {
		view: React.ReactNode;
		placement?: DrawerPlacements;
		height?: string | number;
		containerClassName?: string;
	}) => {
		if (closeTimer) {
			clearTimeout(closeTimer);
			closeTimer = null;
		}

		const newDrawer = {
			id: `drawer-${Date.now()}`,
			view,
			isOpen: true,
			placement,
			height,
			containerClassName,
		};

		setDrawer(newDrawer);
	};

	const closeDrawer = () => {
		setDrawer((prev) => (prev ? { ...prev, isOpen: false } : null));
		if (closeTimer) clearTimeout(closeTimer);
		closeTimer = setTimeout(() => {
			setDrawer((prev) => (prev && prev.isOpen ? prev : null));
			closeTimer = null;
		}, 320);
	};

	return {
		drawer,
		openDrawer,
		closeDrawer,
	};
}
