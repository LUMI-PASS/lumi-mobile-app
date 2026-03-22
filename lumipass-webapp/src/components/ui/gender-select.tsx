'use client';

import { Fragment } from 'react';
import { Listbox, Transition } from '@headlessui/react';
import { PiCaretDownBold } from 'react-icons/pi';
import cn from '@/utils/class-names';
// import { BoyIcon, GirlIcon, BothIcon } from './gender-icons';

type Val = 'MALE' | 'FEMALE' | 'BOTH';

export const GENDER_META: Record<Val, { label: string; cls: string }> = {
	MALE: { label: 'Boys', cls: 'text-indigo-600' },
	FEMALE: { label: 'Girls', cls: 'text-pink-600' },
	BOTH: { label: 'Both', cls: 'text-purple-600' },
};

export default function GenderSelect({
	value, // may be null/undefined
	onChange,
	labels = { male: 'Boys', female: 'Girls', both: 'Both' },
	disabled = false,
	error,
	size = 'md',
	className,
	onClear,
}: {
	value?: Val | null;
	onChange: (v: Val) => void; // emits UPPERCASE
	labels?: { male: string; female: string; both: string }; // UI labels
	disabled?: boolean;
	error?: string;
	size?: 'sm' | 'md';
	className?: string;
	onClear?: () => void;
}) {
	// Use a safe internal value for rendering (default to BOTH visually)
	const internal: Val = (value ?? 'BOTH') as Val;
	const meta = GENDER_META[internal];

	return (
		<Listbox value={internal} onChange={onChange} disabled={disabled}>
			<div className={cn('relative', className)}>
				{/* control */}
				<Listbox.Button
					aria-invalid={!!error}
					className={cn(
						'flex w-full items-center justify-between gap-3 rounded-xl border bg-white p-4 text-left',
						error ? 'border-red-300' : 'border-gray-100'
					)}
				>
					<span className="flex items-center gap-2">
						{/* <SelectedIcon className={cn('h-5 w-8 shrink-0', meta.cls)} /> */}
						{/* You can make these lowercase in CSS if desired: className="lowercase" */}
						<span className="text-gray-700">
							{internal === 'MALE'
								? labels.male
								: internal === 'FEMALE'
									? labels.female
									: labels.both}
						</span>
					</span>
					<PiCaretDownBold className="h-4 w-4 text-gray-500" />
				</Listbox.Button>

				{/* dropdown */}
				<Transition
					as={Fragment}
					enter="transition ease-out duration-100"
					enterFrom="opacity-0 scale-95"
					enterTo="opacity-100 scale-100"
					leave="transition ease-in duration-75"
					leaveFrom="opacity-100 scale-100"
					leaveTo="opacity-0 scale-95"
				>
					<Listbox.Options className="absolute z-30 mt-1 w-full overflow-hidden rounded-xl border border-gray-100 bg-white p-1 shadow-lg focus:outline-none">
						{(['MALE', 'FEMALE', 'BOTH'] as Val[]).map((v) => {
							return (
								<Listbox.Option
									key={v}
									value={v}
									className={({ active, selected }) =>
										cn(
											'cursor-pointer rounded-lg px-3 py-2',
											active && 'bg-gray-50',
											selected && 'bg-primary/10'
										)
									}
								>
									{({ selected }) => (
										<div className="flex items-center gap-2">
											{/* <Icon className={cn('h-5 w-8 shrink-0', m.cls)} /> */}
											<span className="text-sm text-gray-800">
												{v === 'MALE'
													? labels.male
													: v === 'FEMALE'
														? labels.female
														: labels.both}
											</span>
											{selected && (
												<span className="ml-auto text-primary">✓</span>
											)}
										</div>
									)}
								</Listbox.Option>
							);
						})}
					</Listbox.Options>
				</Transition>
			</div>
		</Listbox>
	);
}
