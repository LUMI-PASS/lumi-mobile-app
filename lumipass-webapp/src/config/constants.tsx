import {
	PiClockCounterClockwiseDuotone,
	PiQuestionDuotone,
	PiUserCircleDuotone,
	PiUsersDuotone,
} from 'react-icons/pi';
import { routes } from './routes';
import { LangCode } from '@/types';

// Navigation colors
export const NAV_COLOR_ACTIVE = '#A652C7';
export const NAV_COLOR_INACTIVE = '#6A4A85';

export const GRADIENTS = [
	'from-violet-500 via-fuchsia-500 to-indigo-500',
	'from-purple-400 via-pink-400 to-rose-400',
	'from-indigo-400 via-violet-400 to-fuchsia-400',
	'from-amber-300 via-orange-400 to-pink-400',
	'from-violet-400 via-fuchsia-500 to-purple-500',
];

// Explore page sort options
export const sortOptions = [
	{ label: 'Low price', value: 'price:asc' },
	{ label: 'High price', value: 'price:desc' },
	{ label: 'Latest', value: 'created_at:desc' },
];

// Tashkent city districts
export const tashkentDistricts = [
	{ value: 'Bektemir', label: 'Bektemir' },
	{ value: 'Chilonzor', label: 'Chilonzor' },
	{ value: 'Mirobod', label: 'Mirobod' },
	{ value: `Mirzo Ulug'bek`, label: `Mirzo Ulug'bek` },
	{ value: 'Sergeli', label: 'Sergeli' },
	{ value: 'Shayxontohur', label: 'Shayxontohur' },
	{ value: 'Olmazor', label: 'Olmazor' },
	{ value: 'Uchtepa', label: 'Uchtepa' },
	{ value: 'Yakkasaroy', label: 'Yakkasaroy' },
	{ value: 'Yunusobod', label: 'Yunusobod' },
	{ value: 'Yashnobod', label: 'Yashnobod' },
	{ value: 'Yangihayot', label: 'Yangihayot' },
	{ value: 'Boshqa', label: 'Boshqa' },
];

// Profile menu items
export const profileMenuItems = [
	{
		icon: <PiUserCircleDuotone size={32} className="text-mainPurple" />,
		title: 'Account Information',
		description: 'Change your Account information',
		href: routes.profile.account,
	},
	{
		icon: <PiUsersDuotone size={32} className="text-mainPurple" />,
		title: 'Your children',
		description: 'Change your children information',
		href: routes.profile.myChildren,
	},
	// {
	// 	icon: <PiWalletDuotone size={32} className="text-mainPurple" />,
	// 	title: 'Wallets',
	// 	description: 'Buy more coins for your child',
	// 	href: routes.wallet,
	// },
	{
		icon: (
			<PiClockCounterClockwiseDuotone size={32} className="text-mainPurple" />
		),
		title: 'Attendance history',
		description: 'View your attendance',
		href: routes.profile.attendanceHistory,
	},
	{
		icon: <PiQuestionDuotone size={32} className="text-mainPurple" />,
		title: 'FAQs',
		description: 'Find an answer for all your questions',
		href: routes.profile.faqs,
	},
];

// faqs data

export const faqIds = ['1', '2', '3', '4', '5', '6', '7'] as const;

// Explore page filter view options

export const FULL_PRICE_RANGE: [number, number] = [0, 100];

export const LANGUAGES: Array<{ code: LangCode; label: string; flag: string }> = [
	{ code: 'uz', label: 'O‘zbekcha', flag: '/icons/flags/uz.png' },
	{ code: 'ru', label: 'Русский', flag: '/icons/flags/ru.png' },
	{ code: 'en', label: 'English', flag: '/icons/flags/en.png' }, 
];
