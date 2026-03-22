import { createEnv } from '@t3-oss/env-nextjs';
import { z } from 'zod';

export const env = createEnv({
	server: {
		NODE_ENV: z.enum(['development', 'test', 'production']),
	},
	client: {
		NEXT_PUBLIC_API_URL: z.string().min(1),
		NEXT_PUBLIC_API_PREFIX: z.string().min(1),
		NEXT_PUBLIC_GOOGLE_MAPS_API_KEY: z.preprocess(
			(v) => (v === undefined || v === '' ? undefined : String(v)),
			z.string().min(1).optional()
		),
		NEXT_PUBLIC_YM_ID: z.preprocess(
			(v) => (v === undefined || v === '' ? undefined : Number(v)),
			z.number().int().positive().optional()
		),
	},
	runtimeEnv: {
		NODE_ENV: process.env.NODE_ENV,
		NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
		NEXT_PUBLIC_API_PREFIX: process.env.NEXT_PUBLIC_API_PREFIX,
		NEXT_PUBLIC_GOOGLE_MAPS_API_KEY:
			process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY,
		NEXT_PUBLIC_YM_ID: process.env.NEXT_PUBLIC_YM_ID,
	},
	skipValidation: !!process.env.SKIP_ENV_VALIDATION,
});
