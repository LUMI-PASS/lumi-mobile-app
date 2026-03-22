export interface ApiResponse<T> {
	total_pages(total_pages: any): unknown;
	number(number: any): unknown;
	content?: any;
	success: boolean;
	data: T;
	message?: string;
}

export interface AuthResponse {
	user: User;
	token: string;
	expires_at: string;
}

export interface CheckPhoneResponse {
	is_user_found: boolean;
}

export interface AuthContextType {
	user: User | null;
	token: string | null;
	phoneNumber: string;
	isAuthenticated: boolean;
	isLoading: boolean;
	setPhoneNumber: (phone: string) => void;
	login: (phone: string) => Promise<void>;
	register: (userData: any) => Promise<boolean>;
	verifyOtp: (code: string, isRegistration?: boolean) => Promise<boolean>;
	resendOtp: (isRegistration?: boolean) => Promise<boolean>;
	logout: () => void;
}

export interface User {
	id: string;
	first_name: string;
	last_name: string;
	phone_number: string;
	type: string;
	is_verified?: boolean;
	dob?: string;
	gender: string;
	city: string;
	district: string;
	created_at: string;
	updated_at: string;
	[key: string]: any;
}

export interface Banner {
	id: string;
	title: string;
	url: string;
	created_at: string;
	updated_at: string;
}

export interface Category {
	id: string;
	title: string;
	description: string;
	created_at?: string;
	updated_at?: string;
	deleted_at?: string | null;
	has_photo: boolean;
}
export interface CategoryCardProps {
	category: Category;
	href?: string;
	variant?: 'overlay' | 'below';
	size?: 'sm' | 'md' | 'lg';
	active?: boolean;
	onClick?: () => void;
	className?: string;
}

export interface Class {
	id: string;
	branch: Branch;
	category: string | Category;
	title: string;
	description: string;
	duration: number;
	price: number;
	trial_price?: number;
	trial_enabled?: boolean;
	lesson_price_uzs?: number;
	coin_conversion_price_uzs?: number;
	min_age: number;
	max_age: number;
	gender: 'MALE' | 'FEMALE' | 'BOTH';
	is_active: boolean;
	has_photo: boolean;
	distance?: number;
	created_at: string;
	updated_at: string;
	deleted_at: string | null;
}

export interface Branch {
	id: string;
	title: string;
	address: string;
	longitude: number;
	latitude: number;
	partner_id: string;
	manager_id: string;
	description: string;
	distance?: number;
	is_active: boolean;
	has_photo: boolean;
	created_at: string;
	updated_at: string;
	deleted_at: string | null;
}

export type BranchCardData = {
	id: string;
	title: string;
	description?: string;
	address?: string;
	distance?: number | null; // km
	has_photo?: boolean;
	category?: string | { id: string; title: string } | null;
	is_active?: boolean;
};

export interface BranchCardProps {
	branch: BranchCardData;
	variant?: 'vertical' | 'horizontal';
	density?: 'comfortable' | 'compact';
	showDescription?: boolean;
	showCategory?: boolean;
	showStatus?: boolean;
	showDistance?: boolean;
	hoverable?: boolean;
	href?: string;
	onBookmarkToggle?: (id: string) => void;
	isBookmarked?: boolean;
	onClick?: () => void;
	className?: string;
}

export interface ClassCardData {
	id: string;
	title: string;
	description?: string;
	price?: number;
	trial_price?: number;
	trial_enabled?: boolean;
	min_age?: number;
	max_age?: number;
	gender?: Gender | null;
	has_photo?: boolean;
	duration?: number;
	branch?: {
		id?: string;
		title?: string;
		address?: string;
		distance?: number | null;
	};
	category?: string | { id: string; title: string } | null;
}

export interface ClassCardProps {
	classItem: ClassCardData;
	variant?: 'vertical' | 'horizontal';
	density?: 'comfortable' | 'compact';
	wrapBranch?: boolean;
	showDescription?: boolean;
	showCategory?: boolean;
	showAge?: boolean;
	showGender?: boolean;
	showPrice?: boolean;
	showDistance?: boolean;
	showDuration?: boolean;
	hoverable?: boolean;
	onBookmarkToggle?: (id: string) => void;
	isBookmarked?: boolean;
	className?: string;
}

export interface ClassDetail {
	id: string;
	branch: Branch;
	category: Category;
	title: string;
	description: string;
	duration: number;
	price: number;
	trial_price?: number;
	trial_enabled?: boolean;
	lesson_price_uzs?: number;
	coin_conversion_price_uzs?: number;
	min_age: number;
	max_age: number;
	gender: 'MALE' | 'FEMALE' | 'BOTH';
	is_active: boolean;
	has_photo: boolean;
	distance?: number;
	created_at: string;
	updated_at: string;
	deleted_at: string | null;
}

export interface UpcomingClass {
	class_id: string;
	schedule_id: string;
	booking_id: string;
	class_name: string;
	branch_name: string;
	branch_address: string;
	category_name: string;
	start_time: string;
	end_time: string;
	count: number;
	distance: string;
	for_child: ChildData;
	related_bookings?: RelatedBooking[];
}

export interface HomeFeedResponse {
	success: boolean;
	data: {
		for_user: User;
		upcoming_class: UpcomingClass;
		banners: Banner[];
		categories: {
			page: number;
			limit: number;
			data: Category[];
		};
		new_classes: {
			page: number;
			limit: number;
			data: Class[];
		};
		near_classes: {
			page: number;
			limit: number;
			data: Class[];
		};
	};
}

export interface ChildData {
	id: string;
	parent_id: string;
	first_name: string;
	last_name: string;
	type: string;
	age: number;
	child_age_type: string;
	is_eligible: boolean;
	has_photo?: boolean;
	reason?: string;
	is_verified?: boolean;
	remaining_trials?: number;
	paid_coin_accumulator?: number;
	unlock_cycles_granted?: number;
	coins_into_unlock_cycle?: number;
	coins_to_next_unlock?: number;
	next_unlock_at_total_paid_coins?: number;
	unlock_threshold_coin?: number;
	effective_class_price?: number;
	will_use_trial?: boolean;
	created_at: string;
	updated_at: string;
	deleted_at?: string | null;
}

export interface ParentProfileChild {
	id: string;
	first_name: string;
	last_name: string;
}

export interface TrialSummaryChild {
	child_id: string;
	child_first_name: string;
	child_last_name: string;
	remaining_trials: number;
	paid_coin_accumulator: number;
	unlock_cycles_granted: number;
	coins_into_unlock_cycle: number;
	coins_to_next_unlock: number;
	next_unlock_at_total_paid_coins: number;
}

export interface ParentTrialSummary {
	total_remaining_trials: number;
	unlock_threshold_coin: number;
	unlock_batch_trials: number;
	children: TrialSummaryChild[];
}

export interface ParentProfileData {
	profile: User;
	children: ParentProfileChild[];
	trial_summary?: ParentTrialSummary;
}

export interface ChildCardProps {
	isForProfilePage?: boolean;
	child: ChildData;
	isSelected: boolean;
	onSelect: (id: string) => void;
	age?: number;
	isEditable?: boolean;
}

export interface ClassEligibilityData {
	class_id: string;
	class_title: string;
	class_price: number;
	class_trial_price?: number;
	class_trial_enabled?: boolean;
	min_age: number;
	max_age: number;
	gender?: Gender;
	is_balance_enough: boolean;
	is_balance_enough_for_trial_price?: boolean;
	wallet_balance: number;
	trial_unlock_threshold_coin?: number;
	trial_unlock_batch_lessons_per_unlock?: number;
	children: ChildData[];
}

export interface SelectChildViewProps {
	eligibilityData: ClassEligibilityData;
	initialSelectedChildId?: string;
}

export interface BookingViewProps {
	classId: string;
	childId: string;
	initialFromDate: string;
	initialToDate: string;
	eligibilityData: ClassEligibilityData;
}

export interface BookingRequest {
	schedule_id: string;
	child_id: string;
	subscription_id: string;
}

export interface TimeSlot {
	schedule_id: string;
	for_date: string;
	start_time: string;
	end_time: string;
	capacity: number;
	booked_count: number;
	empty_seats: number;
	is_booking_conflict: boolean;
	is_available: boolean;
}

export interface BookingData {
	class_id: string;
	child_id: string;
	from_date: string;
	to_date: string;
	time_slots: TimeSlot[];
	total_slots: number;
	available_slots: number;
}

export type ScheduleStatus = 'SCHEDULED' | 'CANCELLED' | 'COMPLETED' | string;

export interface ScheduleClass {
	id: string;
	title?: string;
	description?: string;
	price?: number;
	trial_price?: number;
	trial_enabled?: boolean;
	duration?: number;
	gender?: Gender;
	min_age?: number;
	max_age?: number;
	category_id?: string;
	branch_id?: string;

	branch?: string | null;

	has_photo?: boolean;

	created_at?: string;
	updated_at?: string;
	deleted_at?: string | null;
	is_active?: boolean;
}

export interface RelatedBooking {
	id: string;
	schedule_id?: string;
	child_id?: string;
	booking_status?: string;
	charged_coin_amount?: number;
	is_trial_booking?: boolean;
	attendance_status?: string;
	created_at?: string;
	updated_at?: string;
	deleted_at?: string | null;
}

export interface ScheduleCardProps {
	schedule: {
		id: string;
		class: ScheduleClass;
		day_of_week: string;
		for_date: string;
		start_time: string;
		end_time: string;
		capacity: number;
		status: ScheduleStatus;
		start_date: string;
		end_date?: string;
		notes: string | null;
		created_at?: string;
		updated_at?: string;
		for_child: ChildData;
		related_bookings?: RelatedBooking[];
	};
}

export interface IntegrationCodeData {
	code: string;
	expires_at: string;
	for_user: string;
}

// ======= Filter Form Types =======

export interface FilterState {
	fromDate: string | null;
	toDate: string | null;
	age: number | null;
	gender: 'MALE' | 'FEMALE' | 'BOTH' | null;
	minPrice: number | null;
	maxPrice: number | null;
}

export interface FilterProps {
	initialFilters: FilterState;
	onApply: (filters: FilterState) => void;
	onSelect: (filters: FilterState) => void;
	onReset: () => void;
}

// transaction types

export type PackageItem = {
	id: string;
	title: string;
	description?: string;
	price: number;
	coins: number;
	valid_days: number;
	created_at?: string;
	updated_at?: string;
	discount?: number;
	isPopular?: boolean;
};

export interface TariffsResponse {
	success: boolean;
	data: PackageItem[];
}
export interface WalletResponse {
	id: string;
	parent_id: string;
	balance: number;
	actual_deadline: string;
}

export type CoinUsageItem = {
	id: string;
	coins_spent: number;
	booking_id: string;
	created_at: string;
};

export type CoinFlow = {
	id: string;
	amount: number;
	type: 'WITHDRAW' | 'INCOMING';
	created_at: string; 
};

export type PurchaseTariffResponse = {
	id: string;
	parent_id: string;
	tariff_id: string;
	start_date: string;
	end_date: string;
	status: string;
	coins: number;
	amount: number;
	transaction: {
		id: string;
		payment_method: string;
		status: string;
		checkout_url: string;
		created_at: string;
		updated_at: string;
	};
	created_at: string;
	updated_at: string;
};

export type LangCode = 'uz' | 'ru' | 'en';
export type Gender = 'MALE' | 'FEMALE' | 'BOTH';
