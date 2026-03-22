import { z } from 'zod';

export const filterFormSchema = z.object({
	dateType: z.enum(['today', 'tomorrow', 'week', 'custom']).optional(),
	fromDate: z.date().nullable().optional(),
	toDate: z.date().nullable().optional(),
	age: z.number().int().min(1).max(16).nullable().optional(),
	gender: z.union([z.enum(['MALE', 'FEMALE', 'BOTH']), z.null()]).optional(),
	priceRange: z.tuple([z.number(), z.number()]),
});

export type FilterFormValues = z.infer<typeof filterFormSchema>;
