import { z } from 'zod';
const nameRegex = /^[\p{L}\p{M}\s'.’ʼʻ-]+$/u;
export const createSignUpSchema = (t: (key: string, params?: any) => string) =>
	z.object({
		first_name: z
			.string()
			.nonempty(t('Validation.FirstNameRequired'))
			.trim()
			.regex(nameRegex, t('Validation.NameLettersOnly')),
		last_name: z
			.string()
			.nonempty(t('Validation.LastNameRequired'))
			.trim()
			.regex(nameRegex, t('Validation.NameLettersOnly')),
		gender: z.enum(['MALE', 'FEMALE']).refine((val) => !!val, {
			message: t('Validation.GenderRequired'),
		}),
		city: z.string().default('Tashkent'),
		district: z.string().nonempty(t('Validation.DistrictRequired')),
	});

export type SignUpSchema = z.infer<ReturnType<typeof createSignUpSchema>>;
