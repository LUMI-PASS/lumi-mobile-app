import React, { useState, useRef, useEffect } from 'react';
import cn from '@/utils/class-names';
import {
	format,
	startOfMonth,
	endOfMonth,
	eachDayOfInterval,
	addMonths,
	subMonths,
	isSameDay,
	isToday,
	isBefore,
	startOfDay,
} from 'date-fns';
import { PiCaretLeftBold, PiCaretRightBold } from 'react-icons/pi';

interface DateSliderProps {
	selectedDate: Date;
	onDateSelect: (date: Date) => void;
}

export default function DateSlider({
	selectedDate,
	onDateSelect,
}: DateSliderProps) {
	const scrollContainerRef = useRef<HTMLDivElement>(null);
	const [currentMonth, setCurrentMonth] = useState(new Date());
	const today = startOfDay(new Date()); // Get current date at start of day

	// Generate all days for the current month
	const daysInMonth = eachDayOfInterval({
		start: startOfMonth(currentMonth),
		end: endOfMonth(currentMonth),
	});

	// Format month and year name
	const monthYearDisplay = format(currentMonth, 'MMMM yyyy');

	// Check if we can go to previous month (not before current month)
	const canGoToPreviousMonth = () => {
		const prevMonth = subMonths(currentMonth, 1);
		return !isBefore(endOfMonth(prevMonth), today);
	};

	// Navigate to previous month only if allowed
	const goToPreviousMonth = () => {
		if (canGoToPreviousMonth()) {
			setCurrentMonth((prev) => subMonths(prev, 1));
		}
	};

	// Navigate to next month
	const goToNextMonth = () => {
		setCurrentMonth((prev) => addMonths(prev, 1));
	};

	// Check if a date is selectable (not in the past)
	const isDateSelectable = (date: Date) => {
		return !isBefore(date, today);
	};

	// Handle date selection
	const handleDateSelect = (date: Date) => {
		if (isDateSelectable(date)) {
			onDateSelect(date);
		}
	};

	// Scroll to selected date when component mounts or selected date changes
	useEffect(() => {
		if (scrollContainerRef.current) {
			const container = scrollContainerRef.current;

			// Find the element for the selected date
			const selectedElement = Array.from(container.children).find((child) => {
				const dateAttr = child.getAttribute('data-date');
				return dateAttr && isSameDay(new Date(dateAttr), selectedDate);
			}) as HTMLElement;

			if (selectedElement) {
				const containerWidth = container.offsetWidth;
				const cardWidth = selectedElement.offsetWidth;
				const scrollPosition =
					selectedElement.offsetLeft - containerWidth / 2 + cardWidth / 2;

				container.scrollTo({
					left: scrollPosition,
					behavior: 'smooth',
				});
			}
		}
	}, [selectedDate, currentMonth]);

	// Make sure selected month shows the selected date
	useEffect(() => {
		// If selected date is not in the current month view, update the month
		if (
			selectedDate.getMonth() !== currentMonth.getMonth() ||
			selectedDate.getFullYear() !== currentMonth.getFullYear()
		) {
			setCurrentMonth(selectedDate);
		}
	}, [selectedDate]);

	// Make sure we don't start with a month in the past
	useEffect(() => {
		if (isBefore(endOfMonth(currentMonth), today)) {
			setCurrentMonth(today);
		}
	}, []);

	return (
		<div className="mb-6">
			{/* Month navigation */}
			<div className="mb-1 flex items-center justify-between">
				<button
					onClick={goToPreviousMonth}
					disabled={!canGoToPreviousMonth()}
					className={cn(
						'rounded-full p-1 text-textGray',
						canGoToPreviousMonth()
							? 'hover:bg-mainPurple/10'
							: 'cursor-not-allowed opacity-40'
					)}
				>
					<PiCaretLeftBold size={20} />
				</button>

				<h3 className="text-center text-base font-medium text-textGray">
					{monthYearDisplay}
				</h3>

				<button
					onClick={goToNextMonth}
					className="rounded-full p-1 text-textGray hover:bg-mainPurple/10"
				>
					<PiCaretRightBold size={20} />
				</button>
			</div>

			{/* Scrollable dates */}
			<div
				ref={scrollContainerRef}
				className="scrollbar-hide flex snap-x snap-mandatory gap-2 overflow-x-auto py-2"
				style={{ scrollSnapType: 'x mandatory' }}
			>
				{daysInMonth.map((date) => {
					const selectable = isDateSelectable(date);
					return (
						<div
							key={date.toISOString()}
							data-date={date.toISOString()}
							className={cn(
								'flex-shrink-0 snap-center',
								!selectable && 'cursor-not-allowed'
							)}
							onClick={() => selectable && handleDateSelect(date)}
						>
							<div
								className={cn(
									'flex size-16 flex-col items-center justify-center rounded-2xl border border-white/90 bg-white/90 shadow-sm transition-all',
									isSameDay(date, selectedDate) && selectable
										? 'border-mainPurple bg-mainPurple text-white shadow-[0_8px_18px_rgba(166,82,199,0.25)]'
										: isToday(date)
											? 'border-mainPurple/40 bg-mainPurple/10 text-mainPurple'
											: selectable
												? 'text-textGray'
												: 'bg-gray-100 text-gray-300'
								)}
							>
								<span className="text-lg font-bold">{format(date, 'd')}</span>
								<span className="mt-1 text-xs">
									{format(date, 'E').toLowerCase()}
								</span>
							</div>
						</div>
					);
				})}
			</div>
		</div>
	);
}
