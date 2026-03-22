import { z } from 'zod';

export type LoginSchema = z.infer<ReturnType<typeof createLoginSchema>>;

export const createLoginSchema = (t: (key: string, params?: any) => string) =>
	z.object({
		phone_number: z
			.string()
			.trim()
			.min(1, t('Validation.EnterPhoneFirst'))
			.superRefine((value, ctx) => {
				const digits = value.replace(/\D/g, '');
				if (digits.length < 12) {
					ctx.addIssue({
						code: z.ZodIssueCode.too_small,
						minimum: 9,
						type: 'string',
						inclusive: true,
						message: t('Validation.PhoneInvalid', { min: 9 }),
						origin: 'string',
					});
				}
				if (!/^\+?\d/.test(value)) {
					ctx.addIssue({
						code: z.ZodIssueCode.custom,
						message: t('Validation.PhoneInvalid'),
					});
				}
			}),
	});
