'use client';

import React, { useState, useEffect } from 'react';
import { Button, Input, Text } from 'rizzui';
import { PiCalendarCheck, PiCaretDownBold } from 'react-icons/pi';
import { useDrawer } from '@/app/shared/drawer-views/use-drawer';
import { format, addDays } from 'date-fns';
import cn from '@/utils/class-names';
import { Controller, useForm, SubmitHandler } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { DatePicker } from '@/components/ui/datepicker';
import RangeCard from '@/components/ui/widgets/range-card';
import FormGroup from '@/components/ui/form-group';
import GenderSelect from '@/components/ui/gender-select';
import {
	filterFormSchema,
	FilterFormValues,
} from '@/validators/filter-form.schema';
import { FilterState, FilterProps } from '@/types/index';
import { FULL_PRICE_RANGE } from '@/config/constants';
import CloseDrawerButton from '@/components/ui/buttons/close-drawer-button';
import { useTranslations } from 'next-intl';

const transformFormToFilterState = (
	formValues: FilterFormValues
): FilterState => {
	const [pMin, pMax] = formValues.priceRange;
	const changedPrice =
		pMin !== FULL_PRICE_RANGE[0] || pMax !== FULL_PRICE_RANGE[1];

	const normalizedGender =
		formValues.gender === 'BOTH' || formValues.gender == null
			? null
			: formValues.gender;

	return {
		fromDate: formValues.fromDate
			? format(formValues.fromDate, 'yyyy-MM-dd')
			: null,
		toDate: formValues.toDate ? format(formValues.toDate, 'yyyy-MM-dd') : null,
		age: formValues.age as number | null,
		gender: normalizedGender, // ✅
		minPrice: changedPrice ? pMin : null,
		maxPrice: changedPrice ? pMax : null,
	};
};

const transformFilterStateToForm = (
	filterState: FilterState
): Partial<FilterFormValues> => {
	let dateType: 'today' | 'tomorrow' | 'week' | 'custom' = 'custom';
	let fromDate: Date | null = null;
	let toDate: Date | null = null;

	if (filterState.fromDate && filterState.toDate) {
		const from = new Date(filterState.fromDate);
		const to = new Date(filterState.toDate);

		const today = new Date();
		today.setHours(0, 0, 0, 0);

		const tomorrow = new Date(today);
		tomorrow.setDate(tomorrow.getDate() + 1);

		const weekLater = new Date(today);
		weekLater.setDate(weekLater.getDate() + 7);

		if (
			from.getTime() === today.getTime() &&
			to.getTime() === today.getTime()
		) {
			dateType = 'today';
		} else if (
			from.getTime() === tomorrow.getTime() &&
			to.getTime() === tomorrow.getTime()
		) {
			dateType = 'tomorrow';
		} else if (
			from.getTime() === today.getTime() &&
			to.getTime() === weekLater.getTime()
		) {
			dateType = 'week';
		} else {
			dateType = 'custom';
		}

		fromDate = from;
		toDate = to;
	}

	return {
		dateType,
		fromDate,
		toDate,
		age: filterState.age,
		// Convert to lower-case for the form control (GenderSelect)
		gender: filterState.gender
			? (filterState.gender.toLowerCase() as unknown as FilterFormValues['gender'])
			: null,
		priceRange: [
			filterState.minPrice ?? FULL_PRICE_RANGE[0],
			filterState.maxPrice ?? FULL_PRICE_RANGE[1],
		],
	};
};

// ---------------- Component ----------------

export default function ExploreFilterView({
	initialFilters,
	onApply,
	onSelect,
	onReset,
}: FilterProps) {
	const { closeDrawer } = useDrawer();
	const [isCalendarOpen, setIsCalendarOpen] = useState<boolean>(false);
	const t = useTranslations('Drawers.Explore');

	const {
		control,
		handleSubmit,
		watch,
		setValue,
		reset,
		formState: { errors },
	} = useForm<FilterFormValues>({
		resolver: zodResolver(filterFormSchema) as any,
		defaultValues: {
			dateType: 'custom', // neutral by default (no implicit date)
			fromDate: null,
			toDate: null,
			age: null,
			gender: null, // keep null in form until user picks
			priceRange: [
				initialFilters.minPrice ?? FULL_PRICE_RANGE[0],
				initialFilters.maxPrice ?? FULL_PRICE_RANGE[1],
			],
			...transformFilterStateToForm(initialFilters),
		},
	});

	// Watch & sync draft filters with parent
	const formValues = watch();
	const dateType = watch('dateType');

	useEffect(() => {
		const transformed = transformFormToFilterState(formValues);
		onSelect(transformed);
	}, [formValues, onSelect]);

	// Date presets
	const handleDateSelect = (type: 'today' | 'tomorrow' | 'week') => {
		const today = new Date();
		today.setHours(0, 0, 0, 0);

		let fromDate: Date = today;
		let toDate: Date = today;

		if (type === 'tomorrow') {
			fromDate = addDays(today, 1);
			toDate = addDays(today, 1);
		} else if (type === 'week') {
			toDate = addDays(today, 7);
		}

		setValue('dateType', type);
		setValue('fromDate', fromDate);
		setValue('toDate', toDate);
	};

	// Apply
	const onSubmitForm: SubmitHandler<FilterFormValues> = (data) => {
		const transformed = transformFormToFilterState(data);
		onApply(transformed);
		closeDrawer();
	};

	// Reset
	const handleReset = () => {
		reset({
			dateType: 'custom',
			fromDate: null,
			toDate: null,
			age: null,
			gender: null,
			priceRange: [FULL_PRICE_RANGE[0], FULL_PRICE_RANGE[1]],
		});
		onReset();
		closeDrawer();
	};

	return (
		<div className="flex h-full flex-col px-5 pb-6 ">
			{/* Header */}
			<div className="relative mb-6 flex items-center">
				<h2 className="flex-1 text-center font-balsamiqSans text-2xl text-textGray">
					{t('Filters')}
				</h2>
				<CloseDrawerButton onClick={closeDrawer} />
			</div>

			<form
				onSubmit={handleSubmit(onSubmitForm)}
				className="flex h-full flex-1 flex-col overflow-y-auto"
			>
				<div className="mb-6 space-y-8">
					{/* Date Filter */}
					<div className="space-y-5 px-1">
						{/* Date Filter Buttons */}
						<div className="grid grid-cols-3 gap-3">
							<button
								type="button"
								onClick={() => handleDateSelect('today')}
								className={cn(
									'rounded-xl border border-white/90 bg-white/90 py-2 text-center text-sm font-semibold shadow-sm',
									dateType === 'today'
										? 'border-mainPurple bg-mainPurple text-white'
										: 'text-textGray'
								)}
							>
								{t('Today')}
							</button>
							<button
								type="button"
								onClick={() => handleDateSelect('tomorrow')}
								className={cn(
									'rounded-xl border border-white/90 bg-white/90 py-2 text-center text-sm font-semibold shadow-sm',
									dateType === 'tomorrow'
										? 'border-mainPurple bg-mainPurple text-white'
										: 'text-textGray'
								)}
							>
								{t('Tomorrow')}
							</button>
							<button
								type="button"
								onClick={() => handleDateSelect('week')}
								className={cn(
									'rounded-xl border border-white/90 bg-white/90 py-2 text-center text-sm font-semibold shadow-sm',
									dateType === 'week'
										? 'border-mainPurple bg-mainPurple text-white'
										: 'text-textGray'
								)}
							>
								{t('ThisWeek')}
							</button>
						</div>

						{/* Custom Date Picker */}
						<div className="space-y-3">
							<button
								type="button"
								className={cn(
									'flex w-full items-center justify-between gap-3 rounded-xl border border-white/90 bg-white/90 px-4 py-3 shadow-sm transition-colors duration-200',
									dateType === 'custom' && isCalendarOpen && 'border-mainPurple'
								)}
								onClick={() => {
									setValue('dateType', 'custom');
									setIsCalendarOpen(!isCalendarOpen);
								}}
							>
								<div className="flex items-center gap-3">
									<PiCalendarCheck
										className={cn(
											'size-5 text-gray-500',
											isCalendarOpen && 'text-mainPurple'
										)}
									/>
									<span className={cn('text-gray-700')}>
										{t('ChooseFromCalendar')}
									</span>
								</div>
								<PiCaretDownBold
									size={16}
									className={cn(
										'text-gray-500',
										isCalendarOpen &&
											'rotate-180 text-mainPurple transition-transform duration-200'
									)}
								/>
							</button>

							{/* Calendar dropdown */}
							{isCalendarOpen && (
								<div className="rounded-lg border border-white/90 bg-white/90 p-4 shadow-sm transition-transform duration-300">
									<div className="grid gap-3">
										<Text className="font-medium">{t('FromDate')}</Text>
										<Controller
											control={control}
											name="fromDate"
											render={({ field: { value, onChange } }) => (
												<DatePicker
													selected={value}
													onChange={(date: any) => {
														onChange(date);
														setValue('dateType', 'custom');
													}}
													dateFormat="dd.MM.yyyy"
													placeholderText="01.10.2025"
													className="w-full"
												/>
											)}
										/>

										<Text className="font-medium">{t('ToDate')}</Text>
										<Controller
											control={control}
											name="toDate"
											render={({ field: { value, onChange } }) => (
												<DatePicker
													selected={value}
													onChange={(date: any) => {
														onChange(date);
														setValue('dateType', 'custom');
													}}
													dateFormat="dd.MM.yyyy"
													placeholderText="31.12.2025"
													className="w-full"
												/>
											)}
										/>
									</div>
								</div>
							)}
						</div>
					</div>

					{/* Age & Gender */}
					<div className="flex items-center gap-4 px-1">
						{/* Age */}
						<FormGroup title={t('Age')} className="flex-1">
							<Controller
								control={control}
								name="age"
								render={({ field }) => (
									<Input
										type="text"
										inputMode="numeric"
										min={1}
										max={16}
										placeholder="3"
										suffix={t('AgeSuffix')}
										suffixClassName="text-gray-500"
										{...field}
										value={field.value === null ? '' : field.value}
										onChange={(e) => {
											const v = e.target.value;
											const n =
												v === ''
													? null
													: Math.min(16, Math.max(1, parseInt(v, 10) || 0));
											field.onChange(n);
										}}
										error={errors.age?.message}
										inputClassName="h-[54px] rounded-xl border border-mainPurple/15 bg-white/90 !ring-0 focus:border-mainPurple focus:ring-0"
									/>
								)}
							/>
						</FormGroup>

						{/* Gender */}
						<FormGroup title={t('Gender')} className="flex-1">
							<Controller
								control={control}
								name="gender"
								rules={{ required: false }} 
								render={({
									field: { value, onChange },
									fieldState: { error },
								}) => (
									<GenderSelect
										value={value ?? null} 
										onChange={(v) => onChange(v)} 
										error={error?.message}
										labels={{
											male: t('GenderBoys'), 
											female: t('GenderGirls'),
											both: t('GenderBoth'),
										}}
									/>
								)}
							/>
						</FormGroup>
					</div>

					{/* Price Range */}
					<FormGroup title={t('PriceRange')} className="px-1">
						<Controller
							control={control}
							name="priceRange"
							render={({ field: { value, onChange } }) => (
								<RangeCard
									title={t('ChoosePriceRange')}
									min={FULL_PRICE_RANGE[0]}
									max={FULL_PRICE_RANGE[1]}
									initialMin={value[0]}
									initialMax={value[1]}
									onChange={onChange}
								/>
							)}
						/>
					</FormGroup>
				</div>

				{/* Action Buttons */}
				<div className="mt-auto grid grid-cols-2 gap-4 pb-10 pt-4">
					<Button
						type="button"
						variant="outline"
						onClick={handleReset}
						className="rounded-xl border-mainPurple/30 bg-white py-6 font-bold text-mainPurple shadow-sm"
						size="lg"
					>
						{t('Reset')}
					</Button>
					<Button
						type="submit"
						className="rounded-xl bg-mainPurple py-6 font-bold text-white shadow-[0_8px_20px_rgba(166,82,199,0.3)]"
						size="lg"
					>
						{t('Apply')}
					</Button>
				</div>
			</form>
		</div>
	);
}
