import { z } from 'zod';

// shared
const nameRegex = /^[A-Za-z\u00C0-\u017F\u0400-\u04FF\s'.-]+$/;

const parseDDMMYYYY = (dateStr: string): Date | null => {
	if (!dateStr || dateStr.length !== 10) return null;
	const parts = dateStr.split('.');
	if (parts.length !== 3) return null;

	const day = parseInt(parts[0], 10);
	const month = parseInt(parts[1], 10) - 1;
	const year = parseInt(parts[2], 10);

	const d = new Date(year, month, day);
	if (d.getFullYear() !== year || d.getMonth() !== month || d.getDate() !== day)
		return null;

	return d;
};

const notInFuture = (dateStr: string): boolean => {
	const d = parseDDMMYYYY(dateStr);
	if (!d) return false;
	const today = new Date();
	// compare by date only (ignore time)
	d.setHours(0, 0, 0, 0);
	today.setHours(0, 0, 0, 0);
	return d.getTime() <= today.getTime();
};

const ageAtMost16 = (dateStr: string): boolean => {
	const d = parseDDMMYYYY(dateStr);
	if (!d) return false;

	const today = new Date();
	let age = today.getFullYear() - d.getFullYear();
	const monthDiff = today.getMonth() - d.getMonth();
	if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < d.getDate())) {
		age--;
	}
	return age <= 16;
};

export const createAddChildSchemas = (
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
		dob: z
			.string()
			.min(1, t('Validation.DOBRequired'))
			.regex(/^\d{2}\.\d{2}\.\d{4}$/, t('Validation.DOBFormat'))
			.refine(notInFuture, t('Validation.DOBNotFuture')) 
			.refine(ageAtMost16, t('Validation.AgeTooOld')),
		gender: z.enum(['MALE', 'FEMALE'], {
			message: t('Validation.GenderRequired'),
		}),
		city: z.string().optional().default('Tashkent'),
		district: z.string().min(1, t('Validation.DistrictRequired')),
	});

	const api = form.transform((data) => ({
		...data,
		dob: data.dob.split('.').reverse().join('-'),
		gender: data.gender.toUpperCase(),
	}));

	return { form, api };
};

export const createEditChildSchemas = (
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
		dob: z
			.string()
			.min(1, t('Validation.DOBRequired'))
			.regex(/^\d{2}\.\d{2}\.\d{4}$/, t('Validation.DOBFormat'))
			.refine(notInFuture, t('Validation.DOBNotFuture')) 
			.refine(ageAtMost16, t('Validation.AgeTooOld')),
		gender: z
			.enum(['MALE', 'FEMALE', 'male', 'female'], {
				message: t('Validation.GenderRequired'),
			})
			.transform((v) => v.toUpperCase() as 'MALE' | 'FEMALE'),
		city: z.string().optional().default('Tashkent'), // UI-only
		district: z.string().min(1, t('Validation.DistrictRequired')),
	});

	const api = form.transform((data) => ({
		...data,
		dob: data.dob.split('.').reverse().join('-'),
		gender: data.gender.toUpperCase(),
	}));

	return { form, api };
};
