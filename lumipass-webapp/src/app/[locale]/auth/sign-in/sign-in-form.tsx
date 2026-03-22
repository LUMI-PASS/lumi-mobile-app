'use client';

import { useRef, useState, useMemo } from 'react';
import { Button, Input, Loader } from 'rizzui';
import { Controller, useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useAuth } from '@/contexts/auth-context';
import { toast } from 'react-hot-toast';
import { createLoginSchema, type LoginSchema } from '@/validators/login.schema';
import {
	formatPhoneForDisplay,
	maskUzPhoneInput,
	toE164Uz,
} from '@/utils/format-phone-number';
import { useTranslations } from 'next-intl';
import { useNavigationLock } from '@/hooks/use-navigation-lock';
import { PiPhoneCallDuotone } from 'react-icons/pi';

export default function SignInForm() {
	const t = useTranslations('Auth');
	const schema = useMemo(() => createLoginSchema(t), [t]);
	const form = useForm<LoginSchema>({
		resolver: zodResolver(schema),
		defaultValues: { phone_number: formatPhoneForDisplay('+998') },
		mode: 'onSubmit',
	});

	const [isSubmitting, setIsSubmitting] = useState(false);
	const { login } = useAuth();
	const inputRef = useRef<HTMLInputElement | null>(null);

	useNavigationLock(isSubmitting);

	const onSubmit = async (data: LoginSchema, e?: React.BaseSyntheticEvent) => {
		e?.preventDefault();
		setIsSubmitting(true);
		try {
			await login(toE164Uz(data.phone_number));
			// navigate only after success
			// router.replace(`${routes.auth.otp}?flow=login`);
		} catch {
			// console.error('Error during login:', error);
			toast.error(t('ErrorTryAgain'));
		} finally {
			setIsSubmitting(false);
		}
	};

	return (
		<form
			noValidate
			onSubmit={(e) => form.handleSubmit((d) => onSubmit(d, e))(e)}
			// avoid Enter key causing any native submit quirks in mobile webviews
			onKeyDownCapture={(e) => {
				if (e.key === 'Enter') e.stopPropagation();
			}}
			className="flex w-full flex-1 flex-col items-center"
		>
			<div className="flex w-full flex-col">
				<div className="w-full">
					<Controller
						name="phone_number"
						control={form.control}
						render={({ field }) => (
							<Input
								ref={(el) => {
									inputRef.current = el;
								}}
								prefix={
									<PiPhoneCallDuotone className="pointer-events-none text-2xl text-textGray group-focus-within:text-primary" />
								}
								type="tel"
								inputMode="tel"
								autoComplete="tel"
								autoFocus
								placeholder={t('EnterPhone')}
								className="w-full border-none bg-transparent text-lg text-textGray focus:outline-none"
								inputClassName="h-14 rounded-2xl border border-mainPurple/15 bg-white/90 px-2 text-base shadow-sm"
								rounded="lg"
								value={field.value ?? ''}
								onChange={(e) => {
									const { value, selectionStart } = e.target;
									const { value: masked, caret } = maskUzPhoneInput(
										value,
										selectionStart ?? 0
									);
									field.onChange(masked);
									requestAnimationFrame(() => {
										(e.target as HTMLInputElement).setSelectionRange(
											caret,
											caret
										);
									});
								}}
							/>
						)}
					/>
					{form.formState.errors.phone_number?.message && (
						<p className="mt-2 text-xs text-red-500">
							{form.formState.errors.phone_number?.message}
						</p>
					)}
				</div>

				<div className="mt-auto pt-8">
					<Button
						className="w-full rounded-2xl bg-mainPurple py-6 text-base font-bold text-white shadow-[0_8px_22px_rgba(166,82,199,0.35)] hover:brightness-95"
						type="submit"
						size="lg"
						disabled={isSubmitting}
					>
						{isSubmitting ? <Loader size="sm" /> : t('Continue')}
					</Button>
				</div>
			</div>
		</form>
	);
}
