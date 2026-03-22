'use client';

import React, { useEffect, useMemo, useState } from 'react';
import { Input, Button, RadioGroup, Radio, Text } from 'rizzui';
import { maskDateInput, apiDateToMask } from '@/utils/date-mask';
import { PiCalendarDuotone, PiUserDuotone, PiWarning } from 'react-icons/pi';
import { routes } from '@/config/routes';
import { useRouter } from '@/i18n/routing';
import { useTranslations } from 'next-intl';
import { createEditChildSchemas } from '@/validators/child-schemas';

interface EditChildFormProps {
	initialData: any;
	onSubmit: (formData: any) => void;
	isLoading: boolean;
	parentCity: string;
	parentDistrict: string;
}

export default function EditChildForm({
	initialData,
	onSubmit,
	isLoading,
	parentCity,
	parentDistrict,
}: EditChildFormProps) {
	const router = useRouter();
	const t = useTranslations('Profile.Children.Form');

	const { api: editChildApiSchema } = useMemo(
		() => createEditChildSchemas(t),
		[t]
	);

	const [formData, setFormData] = useState({
		first_name: initialData.first_name || '',
		last_name: initialData.last_name || '',
		dob: apiDateToMask(initialData.dob) || '',
		gender: (initialData.gender || 'MALE').toString().toUpperCase(),
		city: parentCity || initialData.city || 'Tashkent',
		district: parentDistrict || initialData.district || '',
	});

	const [errors, setErrors] = useState<Record<string, string>>({});

	useEffect(() => {
		setFormData((prev) => ({
			...prev,
			city: parentCity || initialData.city || 'Tashkent',
			district: parentDistrict || initialData.district || '',
		}));
	}, [initialData.city, initialData.district, parentCity, parentDistrict]);

	type ChangeEventType =
		| React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
		| string;

	const clearFieldError = (name: string) =>
		setErrors((prev) => {
			const next = { ...prev };
			delete next[name];
			return next;
		});

	const handleInputChange = (e: ChangeEventType, fieldName?: string) => {
		if (typeof e === 'string' && fieldName) {
			setFormData((prev) => ({ ...prev, [fieldName]: e }));
			clearFieldError(fieldName);
			return;
		}

		if (typeof e === 'object' && e !== null && 'target' in e) {
			const { name, value } = e.target as HTMLInputElement;

			if (name === 'dob') {
				const maskedDate = maskDateInput(value);
				setFormData((prev) => ({ ...prev, dob: maskedDate }));
				clearFieldError('dob');
			} else if (name === 'first_name') {
				const lettersOnly = (value || '').replace(/[^\p{L}\s'.-]/gu, '');
				setFormData((prev) => ({ ...prev, first_name: lettersOnly }));
				clearFieldError('first_name');
			} else if (name === 'last_name') {
				const lettersOnly = (value || '').replace(/[^\p{L}\s'.-]/gu, '');
				setFormData((prev) => ({ ...prev, last_name: lettersOnly }));
				clearFieldError('last_name');
			} else {
				setFormData((prev) => ({ ...prev, [name]: value }));
				clearFieldError(name);
			}
		}
	};

	const handleGenderChange = (value: string | ((prev: string) => string)) => {
		const v = typeof value === 'string' ? value : value(formData.gender);
		setFormData((prev) => ({ ...prev, gender: v.toUpperCase() }));
		clearFieldError('gender');
	};

	const handleSubmit = (e: React.FormEvent) => {
		e.preventDefault();
		const payload = {
			...formData,
			city: parentCity || initialData.city || 'Tashkent',
			district: parentDistrict || initialData.district || '',
		};
		const parsed = editChildApiSchema.safeParse(payload);
		if (!parsed.success) {
			const fieldErrors: Record<string, string> = {};
			parsed.error.issues.forEach((err) => {
				const key = (err.path[0] as string) ?? 'form';
				if (!fieldErrors[key]) fieldErrors[key] = err.message;
			});
			setErrors(fieldErrors);
			return;
		}
		onSubmit(parsed.data);
	};

	const handleCancel = () => router.push(routes.profile.myChildren);

	return (
		<form onSubmit={handleSubmit} className="flex-1 space-y-7 px-6">
			{/* First Name */}
			<div className="group">
				<Input
					prefix={
						<PiUserDuotone className="h-4 w-4 text-inherit group-focus-within:text-mainPurple" />
					}
					label={t('Labels.FirstName')}
					type="text"
					labelClassName="text-textGray font-bold text-sm"
					name="first_name"
					value={formData.first_name}
					onChange={handleInputChange}
					placeholder={t('Placeholders.FirstName')}
					className="w-full border-none outline-none ring-0"
					inputClassName="bg-white text-xs rounded-xl border-0 ring-0 focus:ring-0 focus:border-0 focus:outline-none"
					size="lg"
					required
					aria-invalid={!!errors.first_name}
				/>
				{errors.first_name && (
					<Text className="mt-1 text-xs text-red-500">{errors.first_name}</Text>
				)}
			</div>

			{/* Last Name */}
			<div className="group">
				<Input
					prefix={
						<PiUserDuotone className="h-4 w-4 text-inherit group-focus-within:text-mainPurple" />
					}
					label={t('Labels.LastName')}
					type="text"
					labelClassName="text-textGray font-bold text-sm"
					name="last_name"
					value={formData.last_name}
					onChange={handleInputChange}
					placeholder={t('Placeholders.LastName')}
					className="w-full border-none outline-none ring-0"
					inputClassName="bg-white text-xs rounded-xl border-0 ring-0 focus:ring-0 focus:border-0 focus:outline-none"
					size="lg"
					required
					aria-invalid={!!errors.last_name}
				/>
				{errors.last_name && (
					<Text className="mt-1 text-xs text-red-500">{errors.last_name}</Text>
				)}
			</div>

			{/* Date of Birth */}
			<div className="group space-y-1">
				<Input
					prefix={
						<PiCalendarDuotone className="h-4 w-4 text-inherit group-focus-within:text-mainPurple" />
					}
					label={t('Labels.DOB')}
					type="text"
					labelClassName="text-textGray font-bold text-sm"
					name="dob"
					value={formData.dob}
					onChange={handleInputChange}
					placeholder={t('Placeholders.DOB')}
					className={`w-full border-none outline-none ring-0 ${errors.dob ? 'border-red-500' : ''}`}
					inputClassName={`h-14 bg-white text-xs rounded-xl border-0 ring-0 focus:ring-0 focus:border-0 focus:outline-none ${errors.dob ? 'border-red-500 focus:border-red-500 text-red-500' : ''}`}
					size="lg"
					required
					aria-invalid={!!errors.dob}
				/>
				{errors.dob && (
					<div className="flex items-center text-red-500">
						<PiWarning className="mr-1 h-4 w-4" />
						<Text className="text-xs">{errors.dob}</Text>
					</div>
				)}
			</div>

			{/* Gender (keep values UPPERCASE for backend & proper preselect) */}
			<div>
				<label className="mb-2 block text-sm font-bold text-textGray">
					{t('Labels.Gender')}
				</label>
				<RadioGroup
					value={formData.gender}
					setValue={handleGenderChange}
					className="flex gap-4"
				>
					<Radio
						size="sm"
						inputClassName="bg-white"
						label={t('Labels.Male')}
						value="MALE"
					/>
					<Radio
						size="sm"
						inputClassName="bg-white"
						label={t('Labels.Female')}
						value="FEMALE"
					/>
				</RadioGroup>
				{errors.gender && (
					<Text className="mt-1 text-xs text-red-500">{errors.gender}</Text>
				)}
			</div>
			{errors.district && (
				<Text className="text-xs text-red-500">{errors.district}</Text>
			)}

			{/* Actions */}
			<div className="flex w-full gap-4 pt-4">
				<Button
					variant="outline"
					color="danger"
					className="flex-1 rounded-xl bg-white py-4"
					onClick={handleCancel}
					disabled={isLoading}
				>
					{t('Buttons.Cancel')}
				</Button>
				<Button
					type="submit"
					value="solid"
					disabled={isLoading}
					isLoading={isLoading}
					className="flex-1 rounded-xl bg-mainPurple py-4 text-white hover:bg-mainPurple/90"
				>
					{t('Buttons.Next')}
				</Button>
			</div>
		</form>
	);
}
