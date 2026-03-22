import { env } from '@/env.mjs';
import isUuid from '@/utils/uuid-utils';
import {
	BookingRequest,
	CoinFlow,
	IntegrationCodeData,
	PurchaseTariffResponse,
	WalletResponse,
} from '@/types/index';
import {
	getCachedLocation,
	getLastLocationSync,
	warmLocation,
} from '@/utils/location-cache';
import {
	ApiResponse,
	CheckPhoneResponse,
	AuthResponse,
	User,
} from '@/types/index';

const BASE_URL = env.NEXT_PUBLIC_API_URL;
const API_PREFIX = env.NEXT_PUBLIC_API_PREFIX;
const SUPPORTED_LOCALES = ['en', 'uz', 'ru'] as const;
type SupportedLocale = (typeof SUPPORTED_LOCALES)[number];

function getLocaleForApi(): SupportedLocale {
	if (typeof window !== 'undefined') {
		const htmlLang = document.documentElement.lang?.toLowerCase();
		if (SUPPORTED_LOCALES.includes(htmlLang as SupportedLocale)) {
			return htmlLang as SupportedLocale;
		}
		const seg = window.location.pathname.split('/')[1]?.toLowerCase();
		if (SUPPORTED_LOCALES.includes(seg as SupportedLocale)) {
			return seg as SupportedLocale;
		}
	}
	return 'en';
}

function appendQuery(
	endpoint: string,
	params: Record<string, string | number | undefined | null>
) {
	const [path, qs = ''] = endpoint.split('?');
	const search = new URLSearchParams(qs);
	for (const [k, v] of Object.entries(params)) {
		if (v == null) continue;
		if (!search.has(k)) search.set(k, String(v));
	}
	const query = search.toString();
	return query ? `${path}?${query}` : path;
}

// Helper function to add auth token to requests
const getHeaders = () => {
	const headers: HeadersInit = {
		'Content-Type': 'application/json',
		Accept: 'application/json',
	};
	// Optional, but recommended for servers that also read headers:
	const lang = getLocaleForApi();
	(headers as Record<string, string>)['Accept-Language'] = lang;

	if (typeof window !== 'undefined') {
		const token = localStorage.getItem('token');
		if (token) {
			(headers as Record<string, string>)['Authorization'] = `Bearer ${token}`;
		}
	}
	return headers;
};

async function apiRequest<T>(
	endpoint: string,
	options: RequestInit = {}
): Promise<ApiResponse<T>> {
	try {
		const last = getLastLocationSync();
		if (!last) warmLocation();
		const lang = getLocaleForApi();

		const modifiedOptions: RequestInit = { ...options };
		let modifiedEndpoint = endpoint;
		const method = (options.method || 'GET').toUpperCase();

		if (method === 'GET') {
			modifiedEndpoint = appendQuery(endpoint, {
				lat: last?.latitude,
				lng: last?.longitude,
				lang,
			});
		} else {
			const body = options.body;
			if (body instanceof FormData) {
				if (!body.has('lat') && last?.latitude != null)
					body.append('lat', String(last.latitude));
				if (!body.has('lng') && last?.longitude != null)
					body.append('lng', String(last.longitude));
				if (!body.has('lang')) body.append('lang', lang);
				modifiedOptions.body = body;
			} else if (typeof body === 'string') {
				const asJson = JSON.parse(body || '{}');
				modifiedOptions.body = JSON.stringify({
					lang,
					lat: asJson?.lat ?? last?.latitude,
					lng: asJson?.lng ?? last?.longitude,
					...asJson,
				});
			} else if (body == null) {
				modifiedOptions.body = JSON.stringify({
					lang,
					lat: last?.latitude,
					lng: last?.longitude,
				});
			}
		}

		const url = `${BASE_URL}${API_PREFIX}${modifiedEndpoint}`;
		const response = await fetch(url, {
			headers: getHeaders(),
			...modifiedOptions,
		});

		// console.log('Api response:', { url, options: modifiedOptions, response });

		let data: any = null;
		try {
			data = await response.json();
		} catch {
			// ignore json parse errors (204 etc.)
		}

		if (!response.ok) {
			const err = new Error(
				data?.message || `API error: ${response.status}`
			) as any;
			err.status = response.status; // ← expose HTTP status
			err.code = response.status; // ← optional alias
			throw err;
		}

		return data as ApiResponse<T>;
	} catch (error) {
		// console.error(`API request error (${endpoint}):`, error);
		throw error;
	}
}

// ============= AUTH API CALLS =============
// Check if phone number exists
export const checkPhoneExists = async (
	phoneNumber: string
): Promise<boolean> => {
	try {
		const response = await apiRequest<CheckPhoneResponse>(
			'/auth/check-number',
			{
				method: 'POST',
				body: JSON.stringify({ phone_number: phoneNumber }),
			}
		);

		return response.data.is_user_found;
	} catch (error) {
		// console.error('Error checking phone:', error);
		throw error;
	}
};

// Register new user
export const registerUser = async (
	userData: any
): Promise<ApiResponse<User>> => {
	return apiRequest<User>('/auth/register', {
		method: 'POST',
		body: JSON.stringify(userData),
	});
};

// Verify OTP for login
export const verifyLoginOtp = async (
	phoneNumber: string,
	code: string
): Promise<ApiResponse<AuthResponse>> => {
	return apiRequest<AuthResponse>('/auth/verify-login', {
		method: 'POST',
		body: JSON.stringify({
			phone_number: phoneNumber,
			code: parseInt(code, 10),
		}),
	});
};

// Verify OTP for registration
export const verifyRegistrationOtp = async (
	phoneNumber: string,
	code: string
): Promise<ApiResponse<AuthResponse>> => {
	return apiRequest<AuthResponse>('/auth/verify', {
		method: 'POST',
		body: JSON.stringify({
			phone_number: phoneNumber,
			code: parseInt(code, 10),
		}),
	});
};

// Resend OTP for login
export const resendLoginOtp = async (
	phoneNumber: string
): Promise<ApiResponse<any>> => {
	return apiRequest<any>('/auth/resend', {
		method: 'POST',
		body: JSON.stringify({ phone_number: phoneNumber }),
	});
};

// Resend OTP for registration
export const resendRegistrationOtp = async (
	phoneNumber: string
): Promise<ApiResponse<any>> => {
	return apiRequest<any>('/auth/resend', {
		method: 'POST',
		body: JSON.stringify({ phone_number: phoneNumber }),
	});
};

// ============= DATA API CALLS =============

// Get home feed data
export const getHomeFeed = async (
	params: Record<string, string | number>
): Promise<ApiResponse<any>> => {
	try {
		const queryParams = new URLSearchParams();
		Object.entries(params).forEach(([key, value]) => {
			if (value !== null && value !== undefined && value !== '') {
				queryParams.append(key, String(value));
			}
		});
		return await apiRequest(`/discovery/feed?${queryParams.toString()}`);
	} catch (err) {
		// console.error('Error loading Feed', err);
		throw err;
	}
};

// Get category by ID
export const getCategoryById = async (categoryId: string): Promise<any> => {
	if (!isUuid(categoryId)) {
		return {
			success: true,
			data: {
				id: 'unknown',
				title: categoryId, // Use the name as the title
			},
		};
	} else {
		try {
			return await apiRequest(`/categories/${categoryId}`);
		} catch (error) {
			// console.error(`Error fetching category with ID ${categoryId}:`, error);
			return {
				success: false,
				error: 'Failed to fetch category',
			};
		}
	}
};

//get all categories
export const getAllCategories = async (): Promise<any> => {
	try {
		return await apiRequest('/categories');
	} catch (error) {
		// console.error('Error fetching categories:', error);
		throw error;
	}
};

// Get classes list
export const getClasses = async (
	params: Record<string, string | number>
): Promise<ApiResponse<any>> => {
	try {
		const queryParams = new URLSearchParams();
		Object.entries(params).forEach(([key, value]) => {
			if (value !== null && value !== undefined && value !== '') {
				queryParams.append(key, String(value));
			}
		});
		return await apiRequest(`/classes?${queryParams.toString()}`);
	} catch (error) {
		// console.error('Error fetching classes:', error);
		throw error;
	}
};

// Get class by ID
export const getClassById = async (classId: string) => {
	try {
		const response = await apiRequest(`/classes/${classId}`, {});
		return response;
	} catch (error) {
		// console.error('Error fetching class details:', error);
		throw error;
	}
};
// Get branch by ID
export const getBranchById = async (branchId: string) => {
	try {
		return await apiRequest(`/branches/${branchId}`, {});
	} catch (error) {
		// console.error('Error fetching class details:', error);
		throw error;
	}
};

// Check class eligibility for parent's children
export const checkClassEligibility = async (classId: string): Promise<any> => {
	try {
		return await apiRequest(`/classes/${classId}/check-eligibility`);
	} catch (error) {
		// console.error('Error checking class eligibility:', error);
		throw error;
	}
};

// Create a booking
export const createBooking = async (
	bookingData: BookingRequest
): Promise<any> => {
	try {
		return await apiRequest(`/bookings`, {
			method: 'POST',
			body: JSON.stringify(bookingData),
		});
	} catch (error) {
		// console.error('Error creating booking:', error);
		throw error;
	}
};

// Cancel a booking
export const cancelBooking = async (
	bookingId: string,
	reason: string
): Promise<any> => {
	try {
		return await apiRequest(`/bookings/${bookingId}/cancel`, {
			method: 'PATCH',
			body: JSON.stringify({ reason }),
		});
	} catch (error) {
		// console.error('Error cancelling booking:', error);
		throw error;
	}
};

// Get all time slots for a class
export const getClassAvailability = async (
	classId: string,
	childId: string,
	fromDate: string,
	toDate: string
): Promise<any> => {
	try {
		return await apiRequest(
			`/schedules/class/${classId}/check-availability?child_id=${childId}&from_date=${fromDate}&to_date=${toDate}`
		);
	} catch (error) {
		// console.error('Error fetching class availability:', error);
		throw error;
	}
};

// Get parent schedules
export const getParentSchedules = async (parentId: string): Promise<any> => {
	try {
		return await apiRequest(
			`/schedules/parent?attendance_status=NOT_APPLICABLE&booking_status=CONFIRMED`
		);
	} catch (error) {
		// console.error('Error fetching parent schedules:', error);
		throw error;
	}
};

// Get booking by ID
export const getBookingById = async (bookingId: string): Promise<any> => {
	try {
		return await apiRequest(`/bookings/${bookingId}`);
	} catch (error) {
		// console.error('Error fetching booking details:', error);
		throw error;
	}
};

// Get schedule by ID
export const getScheduleById = async (scheduleId: string): Promise<any> => {
	try {
		return await apiRequest(`/schedules/${scheduleId}`);
	} catch (error) {
		// console.error('Error fetching booking details:', error);
		throw error;
	}
};

// ============= Profile and such related API CALLS =============

// Get parent profile with children
export const getParentProfile = async (): Promise<any> => {
	try {
		return await apiRequest('/users/parents/profile');
	} catch (error) {
		// console.error('Error fetching parent profile:', error);
		throw error;
	}
};

// Update parent profile
export const updateParentProfile = async (data: any): Promise<any> => {
	try {
		return await apiRequest('/users/parents/profile', {
			method: 'PATCH',
			body: JSON.stringify(data),
		});
	} catch (error) {
		// console.error('Error updating parent profile:', error);
		throw error;
	}
};

//get parent's children
export const getChildrenList = async (): Promise<any> => {
	try {
		return await apiRequest('/users/children/parent');
	} catch (error) {
		// console.error('Error fetching children list:', error);
		throw error;
	}
};

// Get specific child details
export const getChildDetails = async (childId: string): Promise<any> => {
	try {
		return await apiRequest(`/users/parents/profile/children/${childId}`);
	} catch (error) {
		// console.error('Error fetching child details:', error);
		throw error;
	}
};

// Update child information
export const updateChildInfo = async (
	childId: string,
	data: any
): Promise<any> => {
	try {
		return await apiRequest(`/users/parents/profile/children/${childId}`, {
			method: 'PATCH',
			body: JSON.stringify(data),
		});
	} catch (error) {
		// console.error('Error updating child information:', error);
		throw error;
	}
};

// Add new child
export const addNewChild = async (data: any): Promise<any> => {
	try {
		return await apiRequest('/users/parents/profile/children', {
			method: 'POST',
			body: JSON.stringify(data),
		});
	} catch (error) {
		// console.error('Error adding new child:', error);
		throw error;
	}
};

// Upload child photo
export const uploadChildPhoto = async (
	childId: string,
	file: File
): Promise<any> => {
	try {
		const formData = new FormData();
		formData.append('file', file);

		const token = localStorage.getItem('token');

		const url = `${BASE_URL}${API_PREFIX}/assets/files/child-photo/${childId}`;
		const response = await fetch(url, {
			method: 'POST',
			body: formData,
			headers: {
				Authorization: `Bearer ${token}`,
			},
		});

		const data = await response.json();
		if (!response.ok) {
			throw new Error(data.message || `API error: ${response.status}`);
		}

		return data;
	} catch (error) {
		// console.error('Error uploading child photo:', error);
		throw error;
	}
};

// explore page (search classes or branches)
export const exploreClasses = async (
	params: Record<string, string | number>
): Promise<ApiResponse<any>> => {
	try {
		const queryParams = new URLSearchParams();
		Object.entries(params).forEach(([key, value]) => {
			if (value !== null && value !== undefined && value !== '') {
				queryParams.append(key, String(value));
			}
		});
		// console.log('Explore API params:', params);
		const res = await apiRequest(
			`/discovery/explore?${queryParams.toString()}`
		);
		// console.log('Explore API response:', res);
		return res;
	} catch (error) {
		// console.error('Error exploring classes/centers:', error);
		throw error;
	}
};

// Get child attendance history
export const getChildAttendanceHistory = async (childId: string) => {
	try {
		return await apiRequest(`/attendance/history/child/${childId}`);
	} catch (error) {
		// console.error('Error fetching attendance history:', error);
		throw error;
	}
};

// Generate Telegram integration code
export const generateTelegramCode = async (): Promise<
	ApiResponse<IntegrationCodeData>
> => {
	return apiRequest<IntegrationCodeData>('/users/integration/generate-code', {
		method: 'POST',
		body: JSON.stringify({}),
	});
};

// ============= Payment and Tariff related API CALLS =============
// Get user wallet info
export const getUserBalance = async () => {
	try {
		const response = await apiRequest('/transaction/wallets/me');
		return response;
	} catch (err) {
		// console.error('Error fetching user balance:', err);
		return { balance: 0 } as WalletResponse;
	}
};

// Get tariffs (packages)
export const getTariffs = async () => {
	try {
		const response = await apiRequest('/tariffs');
		return response;
	} catch (error) {
		// console.error('Error fetching tariffs:', error);
		throw error;
	}
};

const unwrap = <T>(r: any): T =>
	r && typeof r === 'object' && 'data' in r ? r.data : r;
// Purchase tariff
export const purchaseTariff = async (
	tariffId: string
): Promise<PurchaseTariffResponse> => {
	try {
		const res = await apiRequest<any>('/transaction/subscriptions/', {
			method: 'POST',
			body: JSON.stringify({ tariff_id: tariffId, payment_method: 'PAYME' }),
		});

		const payload = unwrap<PurchaseTariffResponse>(res);

		// (optional) runtime sanity check
		if (!payload?.transaction?.checkout_url) {
			throw new Error('Missing checkout_url in purchase response');
		}

		return payload;
	} catch (error) {
		// console.error('Error purchasing tariff:', error);
		throw error;
	}
};

// Get coin usage history (with pagination)
export const getCoinUsage = async () => {
	try {
		const res = await apiRequest<CoinFlow[]>('/transaction/coin-flows/me');
		const data = (res as any)?.data ?? (res as any);
		if (!Array.isArray(data))
			throw new Error('Unexpected /transaction/coin-flows/me response');
		return data as CoinFlow[];
	} catch (error) {
		throw error;
	}
};

// ============ Assets API Calls =============
// Asset URL helper
export const getImageUrl = (entityId: string): string => {
	if (!entityId) return '/placeholder.avif';
	return `${BASE_URL}${API_PREFIX}/assets/files/${entityId}`;
};

// Child photo URL helper (resolves by child entity_id, not file id)
export const getChildImageUrl = (
	childId: string,
	options: { optimize?: boolean; cacheBust?: string | number } = {}
): string => {
	if (!childId) return '/placeholder.avif';

	const params = new URLSearchParams();
	if (options.optimize === false) {
		params.set('optimize', 'false');
	}
	if (options.cacheBust !== undefined && options.cacheBust !== null) {
		params.set('v', String(options.cacheBust));
	}

	const query = params.toString();
	const path = `/assets/files/child-photo/${childId}`;
	return `${BASE_URL}${API_PREFIX}${query ? `${path}?${query}` : path}`;
};

type BranchPhotosOptions = {
	optimize?: boolean;
	limit?: number;
};

const withQueryString = (path: string, query: string): string =>
	query ? `${path}?${query}` : path;

const BRANCH_PHOTO_ROUTE_BUILDERS: Array<
	(branchId: string, query: string) => string
> = [
	(branchId, query) => withQueryString(`/assets/files/branch-gallery/${branchId}`, query),
	(branchId, query) => withQueryString(`/assets/files/branch-photos/${branchId}`, query),
	(branchId, query) => withQueryString(`/assets/files/branch-photo/${branchId}`, query),
	(branchId, query) => withQueryString(`/assets/files/branches/${branchId}/gallery`, query),
	(branchId, query) => withQueryString(`/assets/files/branches/${branchId}/photos`, query),
	(branchId, query) => withQueryString(`/assets/files/branch/${branchId}/photos`, query),
	(branchId, query) => {
		const base = `/assets/files?entity=BRANCH&entity_id=${encodeURIComponent(branchId)}`;
		return query ? `${base}&${query}` : base;
	},
];
const CLASS_PHOTO_ROUTE_BUILDERS: Array<
	(classId: string, query: string) => string
> = [
	(classId, query) => withQueryString(`/assets/files/class-gallery/${classId}`, query),
	(classId, query) => withQueryString(`/assets/files/class-photos/${classId}`, query),
	(classId, query) => withQueryString(`/assets/files/class-photo/${classId}`, query),
	(classId, query) => withQueryString(`/assets/files/classes/${classId}/gallery`, query),
	(classId, query) => withQueryString(`/assets/files/classes/${classId}/photos`, query),
	(classId, query) => withQueryString(`/assets/files/class/${classId}/photos`, query),
	(classId, query) => {
		const base = `/assets/files?entity=CLASS&entity_id=${encodeURIComponent(classId)}`;
		return query ? `${base}&${query}` : base;
	},
	(classId, query) => {
		const base = `/assets/files?entity=CLASSES&entity_id=${encodeURIComponent(classId)}`;
		return query ? `${base}&${query}` : base;
	},
];
const CATEGORY_PHOTO_ROUTE_BUILDERS: Array<
	(categoryId: string, query: string) => string
> = [
	(categoryId, query) => withQueryString(`/assets/files/category-gallery/${categoryId}`, query),
	(categoryId, query) => withQueryString(`/assets/files/category-photos/${categoryId}`, query),
	(categoryId, query) => withQueryString(`/assets/files/category-photo/${categoryId}`, query),
	(categoryId, query) => withQueryString(`/assets/files/categories/${categoryId}/gallery`, query),
	(categoryId, query) => withQueryString(`/assets/files/categories/${categoryId}/photos`, query),
	(categoryId, query) => withQueryString(`/assets/files/category/${categoryId}/photos`, query),
	(categoryId, query) => {
		const base = `/assets/files?entity=CATEGORY&entity_id=${encodeURIComponent(categoryId)}`;
		return query ? `${base}&${query}` : base;
	},
	(categoryId, query) => {
		const base = `/assets/files?entity=CATEGORIES&entity_id=${encodeURIComponent(categoryId)}`;
		return query ? `${base}&${query}` : base;
	},
];

let preferredBranchPhotoRouteIndex: number | null = null;
let preferredClassPhotoRouteIndex: number | null = null;
let preferredCategoryPhotoRouteIndex: number | null = null;
const branchPhotosCache = new Map<string, Promise<string[]>>();
const classPhotosCache = new Map<string, Promise<string[]>>();
const categoryPhotosCache = new Map<string, Promise<string[]>>();

const toAssetFileUrl = (value: string): string | null => {
	const trimmed = value.trim();
	if (!trimmed) return null;

	if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
		return trimmed;
	}

	if (isUuid(trimmed)) {
		return getImageUrl(trimmed);
	}

	if (trimmed.startsWith('/')) {
		if (trimmed.startsWith(`${API_PREFIX}/`)) {
			return `${BASE_URL}${trimmed}`;
		}
		if (trimmed.startsWith('/assets/files/')) {
			return `${BASE_URL}${API_PREFIX}${trimmed}`;
		}
		return `${BASE_URL}${trimmed}`;
	}

	if (trimmed.startsWith('assets/files/')) {
		return `${BASE_URL}${API_PREFIX}/${trimmed}`;
	}

	return null;
};

const normalizeBranchPhotoEntry = (entry: unknown): string | null => {
	if (entry == null) return null;

	if (typeof entry === 'string') {
		return toAssetFileUrl(entry);
	}

	if (typeof entry !== 'object') return null;

	const obj = entry as Record<string, unknown>;

	const nested = [obj.file, obj.asset, obj.image, obj.photo];
	for (const candidate of nested) {
		const normalized = normalizeBranchPhotoEntry(candidate);
		if (normalized) return normalized;
	}

	const prioritizedUrlKeys = [
		'optimized_url',
		'optimizedUrl',
		'cdn_url',
		'cdnUrl',
		'url',
		'file_url',
		'fileUrl',
		'src',
		'path',
	];
	for (const key of prioritizedUrlKeys) {
		const value = obj[key];
		if (typeof value !== 'string') continue;
		const normalized = toAssetFileUrl(value);
		if (normalized) return normalized;
	}

	const idKeys = ['file_id', 'asset_id', 'image_id', 'id'];
	for (const key of idKeys) {
		const value = obj[key];
		if (typeof value !== 'string') continue;
		const normalized = toAssetFileUrl(value);
		if (normalized) return normalized;
	}

	return null;
};

const unwrapBranchPhotoList = (payload: unknown): unknown[] => {
	if (Array.isArray(payload)) return payload;
	if (!payload || typeof payload !== 'object') return [];

	const root = payload as Record<string, unknown>;
	const firstLevelCandidates = [
		root.data,
		root.items,
		root.files,
		root.photos,
		root.gallery,
		root.images,
	];

	for (const candidate of firstLevelCandidates) {
		if (Array.isArray(candidate)) return candidate;
		if (candidate && typeof candidate === 'object') {
			const nested = candidate as Record<string, unknown>;
			const secondLevelCandidates = [
				nested.data,
				nested.items,
				nested.files,
				nested.photos,
				nested.gallery,
				nested.images,
			];
			for (const secondCandidate of secondLevelCandidates) {
				if (Array.isArray(secondCandidate)) return secondCandidate;
			}
		}
	}

	return [];
};

const assetsJsonRequest = async (endpoint: string): Promise<any> => {
	const response = await fetch(`${BASE_URL}${API_PREFIX}${endpoint}`, {
		method: 'GET',
		headers: getHeaders(),
	});

	let payload: any = null;
	try {
		payload = await response.json();
	} catch {
		// ignore parse errors
	}

	if (!response.ok) {
		throw new Error(payload?.message || `API error: ${response.status}`);
	}

	return payload;
};

const getBranchPhotoQueryString = (options: BranchPhotosOptions): string => {
	const params = new URLSearchParams();
	const optimize = options.optimize ?? true;
	if (optimize) params.set('optimize', 'true');
	if (typeof options.limit === 'number' && options.limit > 0) {
		params.set('limit', String(Math.floor(options.limit)));
	}
	return params.toString();
};

const extractBranchPhotoUrls = (
	payload: unknown,
	limit?: number
): string[] => {
	const rows = unwrapBranchPhotoList(payload);
	const seen = new Set<string>();
	const urls: string[] = [];

	for (const row of rows) {
		const src = normalizeBranchPhotoEntry(row);
		if (!src || seen.has(src)) continue;
		seen.add(src);
		urls.push(src);
		if (typeof limit === 'number' && limit > 0 && urls.length >= limit) break;
	}

	return urls;
};

export const getBranchPhotos = async (
	branchId: string,
	options: BranchPhotosOptions = {}
): Promise<string[]> => {
	if (!branchId) return [];

	const optimize = options.optimize ?? true;
	const limit =
		typeof options.limit === 'number' && options.limit > 0
			? Math.floor(options.limit)
			: undefined;
	const cacheKey = `${branchId}|${optimize ? 1 : 0}|${limit ?? 'all'}`;

	if (branchPhotosCache.has(cacheKey)) {
		return branchPhotosCache.get(cacheKey)!;
	}

	const promise = (async () => {
		const query = getBranchPhotoQueryString({ optimize, limit });
		const defaultOrder = BRANCH_PHOTO_ROUTE_BUILDERS.map((_, idx) => idx);
		const routeOrder =
			typeof preferredBranchPhotoRouteIndex === 'number'
				? [
						preferredBranchPhotoRouteIndex,
						...defaultOrder.filter((idx) => idx !== preferredBranchPhotoRouteIndex),
					]
				: defaultOrder;

		for (const routeIndex of routeOrder) {
			const endpoint = BRANCH_PHOTO_ROUTE_BUILDERS[routeIndex](branchId, query);
			try {
				const payload = await assetsJsonRequest(endpoint);
				const urls = extractBranchPhotoUrls(payload, limit);
				if (urls.length > 0) {
					preferredBranchPhotoRouteIndex = routeIndex;
					return urls;
				}
			} catch {
				// keep probing candidate endpoints
			}
		}

		return [];
	})();

	branchPhotosCache.set(cacheKey, promise);
	return promise;
};

export const getClassPhotos = async (
	classId: string,
	options: BranchPhotosOptions = {}
): Promise<string[]> => {
	if (!classId) return [];

	const optimize = options.optimize ?? true;
	const limit =
		typeof options.limit === 'number' && options.limit > 0
			? Math.floor(options.limit)
			: undefined;
	const cacheKey = `${classId}|${optimize ? 1 : 0}|${limit ?? 'all'}`;

	if (classPhotosCache.has(cacheKey)) {
		return classPhotosCache.get(cacheKey)!;
	}

	const promise = (async () => {
		const query = getBranchPhotoQueryString({ optimize, limit });
		const defaultOrder = CLASS_PHOTO_ROUTE_BUILDERS.map((_, idx) => idx);
		const routeOrder =
			typeof preferredClassPhotoRouteIndex === 'number'
				? [
						preferredClassPhotoRouteIndex,
						...defaultOrder.filter((idx) => idx !== preferredClassPhotoRouteIndex),
					]
				: defaultOrder;

		for (const routeIndex of routeOrder) {
			const endpoint = CLASS_PHOTO_ROUTE_BUILDERS[routeIndex](classId, query);
			try {
				const payload = await assetsJsonRequest(endpoint);
				const urls = extractBranchPhotoUrls(payload, limit);
				if (urls.length > 0) {
					preferredClassPhotoRouteIndex = routeIndex;
					return urls;
				}
			} catch {
				// keep probing candidate endpoints
			}
		}

		return [];
	})();

	classPhotosCache.set(cacheKey, promise);
	return promise;
};

export const getCategoryPhotos = async (
	categoryId: string,
	options: BranchPhotosOptions = {}
): Promise<string[]> => {
	if (!categoryId) return [];

	const optimize = options.optimize ?? true;
	const limit =
		typeof options.limit === 'number' && options.limit > 0
			? Math.floor(options.limit)
			: undefined;
	const cacheKey = `${categoryId}|${optimize ? 1 : 0}|${limit ?? 'all'}`;

	if (categoryPhotosCache.has(cacheKey)) {
		return categoryPhotosCache.get(cacheKey)!;
	}

	const promise = (async () => {
		const query = getBranchPhotoQueryString({ optimize, limit });
		const defaultOrder = CATEGORY_PHOTO_ROUTE_BUILDERS.map((_, idx) => idx);
		const routeOrder =
			typeof preferredCategoryPhotoRouteIndex === 'number'
				? [
						preferredCategoryPhotoRouteIndex,
						...defaultOrder.filter(
							(idx) => idx !== preferredCategoryPhotoRouteIndex
						),
					]
				: defaultOrder;

		for (const routeIndex of routeOrder) {
			const endpoint = CATEGORY_PHOTO_ROUTE_BUILDERS[routeIndex](
				categoryId,
				query
			);
			try {
				const payload = await assetsJsonRequest(endpoint);
				const urls = extractBranchPhotoUrls(payload, limit);
				if (urls.length > 0) {
					preferredCategoryPhotoRouteIndex = routeIndex;
					return urls;
				}
			} catch {
				// keep probing candidate endpoints
			}
		}

		return [];
	})();

	categoryPhotosCache.set(cacheKey, promise);
	return promise;
};

export { BASE_URL, API_PREFIX };
