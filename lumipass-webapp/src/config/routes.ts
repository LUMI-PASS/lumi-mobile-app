import { notFound } from "next/navigation";

export const routes = {
	home: '/',
	schedules: '/schedules',
	scheduleDetails: (ticketId: string) => `/schedules/${ticketId}`,
	explore: '/explore',
	profile: {
		base: '/profile',
		account: '/profile/account',
		myChildren: '/profile/children',
		editChild: (childId: string) => {
			if (!childId) {
				notFound();
			}
			return `/profile/children/${childId}`;
		},
		paymentMethods: '/profile/payment-methods',
		faqs: '/profile/faqs',
		attendanceHistory: '/profile/attendance-history',
		attendanceDetails: (id: string) => `/profile/attendance-history/${id}`,
	},
	wallet: '/wallet',
	classDetails: (classId: string) => {
		if (!classId) {
			notFound();
		}
		return `/home/classes/${classId}`;
	},
	branchDetails: (branchId: string) => {
		if (!branchId) {
			notFound();
		}
		return `/explore/${branchId}`;
	},
	bookingSuccess: (id: string) => `/home/classes/booking-success/${id}`,
	auth: {
		signIn: '/auth/sign-in',
		signUp: '/auth/sign-up',
		otp: '/auth/otp',
	},

	accessDenied: '/access-denied',
	comingSoon : 'coming-soon',
	notFound: '/not-found',
};
