'use client';

import React from 'react';
import { Modal, Button, Title, Text, ActionIcon } from 'rizzui';
import { XMarkIcon } from '@heroicons/react/24/outline';
import cn from '@/utils/class-names';

interface ActionProps {
	label: string;
	onClick: () => void;
	variant?: 'outline' | 'solid';
	color?: 'primary' | 'secondary' | 'danger';
	icon?: React.ReactNode;
	className?: string;
}

interface CustomModalProps {
	isOpen: boolean;
	onClose: () => void;
	title: string;
	description?: string;
	children?: React.ReactNode;
	primaryAction?: ActionProps;
	secondaryAction?: ActionProps;
	size?: 'sm' | 'md' | 'lg' | 'xl';
	hideCloseButton?: boolean;
	className?: string;
}

export default function CustomModal({
	isOpen,
	onClose,
	title,
	description,
	children,
	primaryAction,
	secondaryAction,
	size = 'md',
	hideCloseButton = false,
	className = '',
}: CustomModalProps) {
	// Size mapping
	const sizeClasses = {
		sm: '!max-w-sm',
		md: '!max-w-md',
		lg: '!max-w-lg',
		xl: '!max-w-xl',
	};

	return (
		<Modal
			isOpen={isOpen}
			onClose={onClose}
			containerClassName={`relative !rounded-3xl !border !border-white/80 !bg-white/95 !shadow-[0_18px_36px_rgba(38,56,120,0.24)] ${sizeClasses[size]} ${className}`}
		>
			<div className="px-5 py-6">
				<div className="mb-4 flex items-center justify-between">
					<Title as="h3" className="font-balsamiqSans text-2xl font-bold text-textGray">
						{title}
					</Title>
					{!hideCloseButton && (
						<ActionIcon
							size="sm"
							variant="text"
							onClick={onClose}
							className="absolute right-3 top-3 rounded-xl bg-mainPurple/10 text-mainPurple hover:bg-mainPurple/15 hover:text-mainPurple"
						>
							<XMarkIcon className="h-auto w-5 font-bold" />
						</ActionIcon>
					)}
				</div>

				{description && (
					<Text className="mb-5 text-sm leading-relaxed text-gray-600">{description}</Text>
				)}

				{children && <div className="mb-5">{children}</div>}

				{(primaryAction || secondaryAction) && (
					<div className="flex items-center justify-end gap-3">
						{secondaryAction && (
							<Button
								size="md"
								variant={secondaryAction.variant || 'outline'}
								color={secondaryAction.color || 'primary'}
								onClick={secondaryAction.onClick}
								className="flex flex-1 items-center justify-center rounded-2xl border-mainPurple/30 bg-white text-mainPurple"
							>
								{secondaryAction.icon && (
									<span className="mr-2">{secondaryAction.icon}</span>
								)}
								{secondaryAction.label}
							</Button>
						)}
						{primaryAction && (
							<Button
								size="md"
								variant={primaryAction.variant || 'solid'}
								color={primaryAction.color || 'primary'}
								onClick={primaryAction.onClick}
								className={cn(
									'flex flex-1 items-center justify-center rounded-2xl bg-mainPurple text-white shadow-[0_8px_20px_rgba(166,82,199,0.3)]',
									primaryAction.className
								)}
							>
								{primaryAction.icon && (
									<span className="mr-2">{primaryAction.icon}</span>
								)}
								{primaryAction.label}
							</Button>
						)}
					</div>
				)}
			</div>
		</Modal>
	);
}
