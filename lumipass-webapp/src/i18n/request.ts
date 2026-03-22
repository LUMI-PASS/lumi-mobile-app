import { getRequestConfig } from 'next-intl/server';
import { routing } from './routing';
import { hasLocale } from 'next-intl';
import enMessages from '../../messages/en.json';
import ruMessages from '../../messages/ru.json';
import uzMessages from '../../messages/uz.json';

const messagesByLocale = {
	en: enMessages,
	ru: ruMessages,
	uz: uzMessages,
} as const;

export default getRequestConfig(async ({ requestLocale }) => {
	const requested = await requestLocale;
	const locale = hasLocale(routing.locales, requested)
		? requested
		: routing.defaultLocale;

	return {
		locale,
		messages: messagesByLocale[locale],
	};
});
