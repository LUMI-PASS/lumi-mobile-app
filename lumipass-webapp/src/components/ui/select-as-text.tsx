import { useState, useRef, useEffect } from 'react';
import { ChevronDownIcon, ChevronUpIcon } from '@heroicons/react/24/outline';
import {
	PiCheckBold,
	PiXBold,
} from 'react-icons/pi';
import cn from '@/utils/class-names';
const CustomSelect = ({
	options,
	value,
	onChange,
}: {
	options: { label: string; value: string }[];
	value: string | null;
	onChange: (val: string | null) => void;
}) => {
	const [open, setOpen] = useState(false);
	const dropdownRef = useRef<HTMLDivElement>(null);

	// Close dropdown when clicked outside
	useEffect(() => {
		const handleClickOutside = (event: MouseEvent) => {
			if (
				dropdownRef.current &&
				!dropdownRef.current.contains(event.target as Node)
			) {
				setOpen(false);
			}
		};
		document.addEventListener('mousedown', handleClickOutside);
		return () => {
			document.removeEventListener('mousedown', handleClickOutside);
		};
	}, []);

	const selectedLabel =
		options.find((o) => o.value === value)?.label || 'Sort by:';

	return (
		<div className="relative" ref={dropdownRef}>
			<div className="w-fit">
				{/* Trigger button */}
				<button
					onClick={() => setOpen(!open)}
					className="flex w-full items-center justify-between gap-2 px-3 py-2 text-sm font-medium text-textGray"
				>
					<span>{selectedLabel}</span>
					{open ? (
						<ChevronUpIcon className="size-4 font-semibold" />
					) : (
						<ChevronDownIcon className="size-4 font-semibold" />
					)}
				</button>
			</div>
			{/* Dropdown menu */}
			{open && (
				<div className="border-0.5 absolute z-10 mt-1 w-40 overflow-hidden rounded-md bg-white shadow-lg">
					{options.map((option) => (
						<button
							key={option.value}
							onClick={() => {
								onChange(option.value);
								setOpen(false);
							}}
							className={`flex w-full items-center justify-between whitespace-nowrap border-b border-gray-100 px-3 py-2 text-left text-sm last:border-none hover:bg-gray-100 ${
								option.value === value
									? 'font-medium text-mainPurple'
									: 'text-gray-700'
							}`}
						>
							{option.label}
							<PiCheckBold
								className={cn(
									'size-5',
									option.value === value ? 'text-mainPurple' : 'hidden'
								)}
							/>
						</button>
					))}

					{/* Cancel option */}
					{
						<button
							onClick={() => {
								onChange(null);
								setOpen(false);
							}}
							className="flex w-full items-center justify-between whitespace-nowrap border-t border-gray-100 px-3 py-2 text-left text-sm text-red-600 hover:bg-gray-100"
						>
							Cancel
							<PiXBold className="size-5" />
						</button>
					}
				</div>
			)}
		</div>
	);
};

export default CustomSelect;
