import { z } from 'zod';

/* ---------- helpers ---------- */
const nameRegex = /^[\p{L}\s'.-]+$/u;

const normalizeDigits = (s: string) => (s || '').replace(/\D+/g, '');

const toE164UzLocal = (input: string): string | null => {
	const digits = normalizeDigits(input);
	if (digits.length === 12 && digits.startsWith('998')) {
		return `+${digits}`;
	}
	return null;
};

export const createAccountSchemas = (
	t: (key: string, params?: any) => string
) => {
	const form = z.object({
		first_name: z
			.string()
			.min(1, t('Validation.FirstNameRequired'))
			.max(50, t('Validation.FirstNameMax', { max: 50 }))
			.regex(nameRegex, t('Validation.NameChars')),
		last_name: z
			.string()
			.min(1, t('Validation.LastNameRequired'))
			.max(50, t('Validation.LastNameMax', { max: 50 }))
			.regex(nameRegex, t('Validation.NameChars')),
		phone_number: z
			.string()
			.min(1, t('Validation.PhoneRequired'))
			.refine((v) => !!toE164UzLocal(v), t('Validation.PhoneInvalid')),
		city: z.string().min(1, t('Validation.CityRequired')).default('Tashkent'),
		district: z.string().min(1, t('Validation.DistrictRequired')),
	});

	const api = form.transform((data) => ({
		...data,
		phone_number: toE164UzLocal(data.phone_number)!,
	}));

	return { form, api };
};
