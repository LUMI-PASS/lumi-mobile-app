'use client';

import {
	useDrawer,
	type DrawerPlacements,
} from '@/app/shared/drawer-views/use-drawer';
import { Button, ButtonProps } from 'rizzui';
import cn from '@/utils/class-names';
import { useState } from 'react';

interface DrawerButtonProps extends Omit<ButtonProps, 'onClick'> {
	modalView: React.ReactNode | (() => Promise<React.ReactNode>);
	placement?: DrawerPlacements;
	height?: string | number;
	children: React.ReactNode;
	containerClassName?: string;
}

export default function DrawerButton({
	className,
	placement = 'bottom',
	height,
	modalView,
	children,
	containerClassName,
	...props
}: DrawerButtonProps) {
	const { openDrawer } = useDrawer();
	const [isLoading, setIsLoading] = useState(false);

	const handleClick = async () => {
		setIsLoading(true);

		try {
			if (typeof modalView === 'function') {
				const view = await modalView();
				openDrawer({
					view,
					placement,
					height,
					containerClassName: cn(
						'max-w-full w-full md:max-w-[520px]',
						containerClassName
					),
				});
			} else {
				openDrawer({
					view: modalView,
					placement,
					height,
					containerClassName: cn(
						'max-w-full w-full md:max-w-[520px]',
						containerClassName
					),
				});
			}
		} catch {
			// console.error('Error opening drawer:', error);
		} finally {
			setIsLoading(false);
		}
	};

	return (
		<Button
			{...props}
			className={cn(
				'flex w-full items-center justify-center rounded-2xl bg-mainPurple text-white shadow-[0_8px_22px_rgba(166,82,199,0.35)] transition hover:brightness-95 active:scale-[0.99]',
				className
			)}
			onClick={handleClick}
			isLoading={isLoading}
		>
			{children}
		</Button>
	);
}
