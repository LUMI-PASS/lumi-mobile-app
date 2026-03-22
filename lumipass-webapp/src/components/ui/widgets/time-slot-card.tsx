import React from 'react';
import cn from '@/utils/class-names';
import { Badge } from 'rizzui/badge';

interface TimeSlotProps {
	scheduleId: string;
	startTime: string;
	endTime: string;
	emptySeats: number;
	isBookingConflict: boolean;
	isAvailable: boolean;
	isSelected: boolean;
	onSelect: (scheduleId: string) => void;
}

export default function TimeSlotCard({
	scheduleId,
	startTime,
	endTime,
	emptySeats,
	isBookingConflict,
	isAvailable,
	isSelected,
	onSelect,
}: TimeSlotProps) {
	// Format time from ISO strings to display format (HH:MM)
	const formatTime = (timeString: string) => {
		// Check if it's already in HH:MM format
		if (timeString.includes(':') && !timeString.includes('T')) {
			return timeString;
		}

		try {
			// Parse the ISO time string
			const date = new Date(timeString);
			return date.toLocaleTimeString([], {
				hour: '2-digit',
				minute: '2-digit',
				hour12: false,
			});
		} catch {
			return timeString; // Return as is if there's an error
		}
	};

	// Determine if the slot can be selected
	const canSelect = isAvailable && !isBookingConflict && emptySeats > 0;

	return (
		<div className="relative">
			<div
				className={cn(
					'mb-4 rounded-2xl border border-white/90 bg-white/90 px-3 py-3 shadow-sm transition-all',
					canSelect
						? 'cursor-pointer'
						: 'cursor-not-allowed bg-gray-100 opacity-60',
					isSelected && canSelect
						? 'border-mainPurple/40 bg-mainPurple/10 text-mainPurple shadow-[0_8px_18px_rgba(166,82,199,0.2)]'
						: 'text-textGray'
				)}
				onClick={() => canSelect && onSelect(scheduleId)}
			>
				<div className={cn('flex flex-col items-center', !canSelect && 'blur-[1px]')}>
					{/* Time Range */}
					<div className="font-lexend text-sm font-bold text-inherit text-center">
						{formatTime(startTime)} - {formatTime(endTime)}
					</div>

					{/* Available Seats */}
					<div className="font-lexend text-[10px] text-inherit">
						{emptySeats} slots left
					</div>
				</div>

			</div>
			{/* Status Badges */}
			{isBookingConflict && (
				// <div className="absolute right-2 top-2 rounded-full bg-red-100 px-2 py-0.5 text-xs text-red-500">
				// 	booked
				// </div>
				<Badge
					size="sm"
					rounded="pill"
					variant="outline"
					color="primary"
					className="leading-0 absolute -right-2 -top-1.5 z-40 h-5 bg-white px-2 py-0 text-[9px] font-bold"
				>
					booked
				</Badge>
			)}

			{emptySeats === 0 && !isBookingConflict && (
				<Badge
					size="sm"
					rounded="pill"
					color="danger"
					variant="outline"
					className="leading-0 absolute -right-4 -top-1.5 z-40 h-5 bg-white px-2 py-0 text-[9px]"
				>
					no slots
				</Badge>
			)}
		</div>
	);
}
