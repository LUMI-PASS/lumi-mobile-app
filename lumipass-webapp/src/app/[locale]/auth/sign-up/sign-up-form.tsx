'use client';

import { useState, useEffect, useMemo } from 'react';
import { useRouter } from '@/i18n/routing';
import { Button, Input, AdvancedRadio, Text, Select } from 'rizzui';
import { Form } from '@/components/ui/form';
import { Controller } from 'react-hook-form';
import { useAuth } from '@/contexts/auth-context';
import { toast } from 'react-hot-toast';
import { routes } from '@/config/routes';
import {
	PiMapPinAreaDuotone,
	PiPhoneCallDuotone,
	PiUserDuotone,
} from 'react-icons/pi';
import { tashkentDistricts } from '@/config/constants';
import {
	createSignUpSchema,
	type SignUpSchema,
} from '@/validators/sign-up.schema';
import { useTranslations } from 'next-intl';
import { useNavigationLock } from '@/hooks/use-navigation-lock';

export default function SignUpForm() {
	const t = useTranslations('Auth');
	const schema = useMemo(() => createSignUpSchema(t), [t]);
	const [isSubmitting, setIsSubmitting] = useState(false);
	const { phoneNumber, register: registerUser } = useAuth();
	const router = useRouter();

	useNavigationLock(isSubmitting);

	useEffect(() => {
		if (!phoneNumber) {
			toast.error(t('Validation.EnterPhoneFirst'));
			router.replace(`${routes.auth.signIn}`);
		}
	}, [phoneNumber, router, t]);

	const handleSubmit = async (data: SignUpSchema) => {
		try {
			setIsSubmitting(true);
			if (!phoneNumber) {
				toast.error(t('Validation.PhoneMissing'));
				router.replace(`${routes.auth.signIn}`);
				return;
			}
			const userData = {
				first_name: data.first_name,
				last_name: data.last_name,
				phone_number: phoneNumber,
				gender: data.gender,
				city: 'Tashkent',
				district: data.district,
			};
			const success = await registerUser(userData);
			if (success) {
				toast.success(t('RegistrationStarted'));
				router.push(`${routes.auth.otp}?flow=register`);
			}
		} catch {
			// console.error('Registration error:', error);
			toast.error(t('RegistrationFailed'));
		} finally {
			setIsSubmitting(false);
		}
	};

	return (
		<Form<SignUpSchema>
			validationSchema={schema}
			onSubmit={handleSubmit}
			className="flex w-full flex-1 flex-col"
			useFormProps={{
				defaultValues: {
					first_name: '',
					last_name: '',
					gender: 'MALE',
					city: 'Tashkent',
					district: '',
				},
			}}
		>
			{({ register, control, formState: { errors } }) => (
				<div className="flex flex-grow flex-col items-center gap-5">
					{/* First Name */}
					<div className="w-full">
						<Input
							label={t('FirstName')}
							autoFocus
							inputMode="text"
							prefix={
								<PiUserDuotone
									size={18}
									className="pointer-events-none text-lightGray group-focus-within:text-primary"
								/>
							}
							type="text"
							placeholder={t('FirstName')}
							className="!ring-none group w-full rounded-xl !border-none text-textGray focus:outline-none focus:ring-2 focus:ring-mainPurple"
							inputClassName="h-12 rounded-xl border border-mainPurple/15 bg-white/90 text-base text-textGray shadow-sm"
							{...register('first_name')}
						/>
						{errors.first_name?.message && (
							<p className="mt-2 text-xs text-red-500">
								{errors.first_name?.message}
							</p>
						)}
					</div>

					{/* Last Name */}
					<div className="w-full">
						<Input
							label={t('LastName')}
							inputMode="text"
							prefix={
								<PiUserDuotone
									size={18}
									className="pointer-events-none text-lightGray group-focus-within:text-primary"
								/>
							}
							type="text"
							placeholder={t('LastName')}
							className="!ring-none group w-full rounded-xl !border-none text-textGray focus:outline-none focus:ring-2 focus:ring-mainPurple"
							inputClassName="h-12 rounded-xl border border-mainPurple/15 bg-white/90 text-base text-textGray shadow-sm"
							{...register('last_name')}
						/>
						{errors.last_name?.message && (
							<p className="mt-2 text-xs text-red-500">
								{errors.last_name?.message}
							</p>
						)}
					</div>

					{/* Phone (read-only) */}
					<div className="w-full">
						<Input
							label={t('PhoneNumber')}
							inputMode="tel"
							prefix={
								<PiPhoneCallDuotone
									size={18}
									className="pointer-events-none text-lightGray"
								/>
							}
							type="tel"
							placeholder={t('PhoneNumber')}
							value={phoneNumber}
							readOnly
							className="!ring-none w-full rounded-xl !border-none text-textGray focus:outline-none focus:ring-2 focus:ring-mainPurple"
							inputClassName="h-12 rounded-xl border border-mainPurple/15 bg-white/90 text-base text-textGray shadow-sm"
							aria-readonly
						/>
					</div>

					{/* Gender */}
					<div className="w-full">
						<Text className="mb-2 block px-2 text-sm font-medium text-textGray">
							{t('Gender')}
						</Text>
						<Controller
							name="gender"
							control={control}
							render={({ field }) => (
								<div className="flex space-x-4">
									<AdvancedRadio
										checked={field.value === 'MALE'}
										size="md"
										value="MALE"
										alignment="center"
										onChange={() => field.onChange('MALE')}
										className="!ring-none rounded-xl !border border-mainPurple/15 bg-white/90 text-textGray focus:outline-none focus:ring-2 focus:ring-mainPurple"
										contentClassName="text-textGray rounded-lg text-sm"
									>
										{t('Male')}
									</AdvancedRadio>
									<AdvancedRadio
										checked={field.value === 'FEMALE'}
										size="md"
										value="FEMALE"
										alignment="center"
										onChange={() => field.onChange('FEMALE')}
										className="!ring-none rounded-xl !border border-mainPurple/15 bg-white/90 text-textGray focus:outline-none focus:ring-2 focus:ring-mainPurple"
										contentClassName="text-textGray rounded-lg text-sm"
									>
										{t('Female')}
									</AdvancedRadio>
								</div>
							)}
						/>
					</div>

					{/* District */}
					<div className="w-full">
						<Controller
							name="district"
							control={control}
							render={({
								field: { value, onChange },
								fieldState: { error },
							}) => (
								<Select
									label={t('District')}
									prefix={
										<PiMapPinAreaDuotone
											size={18}
											className="pointer-events-none text-lightGray group-focus-within:text-primary"
										/>
									}
									options={tashkentDistricts}
									value={value}
									onChange={onChange}
									getOptionValue={(option) => option.value}
									displayValue={(selected) =>
										tashkentDistricts.find((d) => d.value === selected)
											?.label ?? ''
									}
									placeholder={t('District')}
									className="!ring-none group w-full rounded-xl !border-none text-textGray focus:outline-none focus:ring-2 focus:ring-mainPurple"
									selectClassName="h-12 rounded-xl border border-mainPurple/15 bg-white/90 text-base text-textGray shadow-sm"
									optionClassName="[&>div]:text-textGray [&>div]:[-webkit-text-fill-color:currentColor]"
									dropdownClassName="rounded-md bg-white text-textGray z-50 [&>li]:text-textGray [&>li>div]:text-textGray [&>li>div]:[-webkit-text-fill-color:currentColor] [&>li:hover]:bg-purple-50 [&>li[data-headlessui-state~='selected']]:bg-purple-50 [&>li[data-headlessui-state~='selected']>div]:text-gray-900"
									error={error?.message || errors.district?.message}
									clearable={false}
								/>
							)}
						/>
					</div>

					{/* Register */}
					<Button
						className="mt-4 w-full cursor-pointer rounded-2xl bg-mainPurple py-6 text-base font-bold text-white shadow-[0_8px_22px_rgba(166,82,199,0.35)] hover:brightness-95"
						type="submit"
						size="md"
						isLoading={isSubmitting}
						disabled={isSubmitting}
					>
						{t('Register')}
					</Button>
				</div>
			)}
		</Form>
	);
}
