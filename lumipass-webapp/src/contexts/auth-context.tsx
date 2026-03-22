'use client';

import {
	createContext,
	useContext,
	useState,
	useEffect,
	ReactNode,
} from 'react';
import { useRouter } from '@/i18n/routing';
import { toast } from 'react-hot-toast';
import { setCookie, deleteCookie, getCookie } from 'cookies-next';
import * as api from '@/services/api';
import { routes } from '@/config/routes';
import { jwtDecode } from 'jwt-decode';
import { useTranslations } from 'next-intl';
import { AuthContextType, User } from '@/types/index';

const AuthContext = createContext<AuthContextType | undefined>(undefined);
export function AuthProvider({ children }: { children: ReactNode }) {
	const [user, setUser] = useState<User | null>(null);
	const [token, setToken] = useState<string | null>(null);
	const [phoneNumber, setPhoneNumberState] = useState<string>('');
	const [isLoading, setIsLoading] = useState<boolean>(true);
	const router = useRouter();
	const t = useTranslations('Auth');

	const setPhoneNumber = (phone: string) => {
		const formattedPhone = phone.startsWith('+') ? phone : `+${phone}`;
		setPhoneNumberState(formattedPhone);
		setCookie('phone_number', formattedPhone, { maxAge: 3600 }); // 1 hour
	};

	// Initialize auth state
	useEffect(() => {
		const storedUser =
			typeof window !== 'undefined' ? localStorage.getItem('user') : null;
		const storedToken =
			typeof window !== 'undefined' ? localStorage.getItem('token') : null;
		const cookiePhone = getCookie('phone_number');

		// If either is missing, force logout immediately
		if (!storedUser || !storedToken) {
			setIsLoading(false); // avoid spinner hanging
			logout();
			return;
		}

		try {
			setUser(JSON.parse(storedUser));
			setToken(storedToken);
		} catch {
			localStorage.removeItem('user');
			localStorage.removeItem('token');
			setIsLoading(false);
			logout();
			return;
		}

		if (cookiePhone && typeof cookiePhone === 'string') {
			setPhoneNumberState(cookiePhone);
		}
		setIsLoading(false);
	}, []);

	// Check for token expiry
	useEffect(() => {
		if (!token) return;

		const checkTokenExpiry = () => {
			if (!token) return;
			const { exp } = jwtDecode<{ exp: number }>(token);
			if (Date.now() >= exp * 1000) {
				logout();
				toast.error(t('SessionExpired'));
			}
		};
		checkTokenExpiry();
		const interval = setInterval(checkTokenExpiry, 60 * 10000); // Check every minute
		return () => clearInterval(interval);
	}, [token]);

	const isAuthenticated = !!token && !!user;

	// Login flow: Check if user exists and redirect accordingly
	const login = async (phone: string) => {
		setIsLoading(true);
		try {
			setPhoneNumber(phone);
			const userExists = await api.checkPhoneExists(phone);
			if (userExists) {
				router.push(`${routes.auth.otp}?flow=login`);
			} else {
				router.push(routes.auth.signUp);
			}
		} catch (error) {
			// console.error('Login error:', error);
			toast.error(t('ServerError'));
		} finally {
			setIsLoading(false);
		}
	};

	// Register a new user
	const register = async (userData: any): Promise<boolean> => {
		setIsLoading(true);
		try {
			const response = await api.registerUser(userData);
			if (!response.success) {
				throw new Error(response.message || 'Registration failed');
			}
			setPhoneNumber(userData.phone_number);
			return true;
		} catch (error) {
			// console.error('Registration error:', error);
			toast.error(t('RegistrationFailed'));
			return false;
		} finally {
			setIsLoading(false);
		}
	};

	// Verify OTP code
	const verifyOtp = async (
		code: string,
		isRegistration = false
	): Promise<boolean> => {
		setIsLoading(true);
		try {
			const verifyFn = isRegistration
				? api.verifyRegistrationOtp
				: api.verifyLoginOtp;
			const response = await verifyFn(phoneNumber, code);
			if (!response.success) {
				throw new Error('Invalid verification code');
			}
			const { user: userData, token: authToken, expires_at } = response.data;
			setUser(userData);
			setToken(authToken);
			localStorage.setItem('user', JSON.stringify(userData));
			localStorage.setItem('token', authToken);
			localStorage.setItem('tokenExpiry', expires_at);
			deleteCookie('phone_number');
			return true;
		} catch (error) {
			// console.error('OTP verification error:', error);
			toast.error(t('InvalidCode'));
			return false;
		} finally {
			setIsLoading(false);
		}
	};

	// Resend OTP code
	const resendOtp = async (isRegistration = false): Promise<boolean> => {
		setIsLoading(true);
		try {
			const resendFn = isRegistration
				? api.resendRegistrationOtp
				: api.resendLoginOtp;
			const response = await resendFn(phoneNumber);
			if (!response.success) {
				throw new Error('Failed to resend code');
			}
			return true;
		} catch (error) {
			// console.error('Error resending code:', error);
			toast.error(t('ResendFailed'));
			return false;
		} finally {
			setIsLoading(false);
		}
	};

	// Logout
	const logout = () => {
		setUser(null);
		setToken(null);
		localStorage.removeItem('user');
		localStorage.removeItem('token');
		localStorage.removeItem('tokenExpiry');
		deleteCookie('phone_number');
		setTimeout(() => {
			router.push(routes.auth.signIn);
		}, 500);
	};

	return (
		<AuthContext.Provider
			value={{
				user,
				token,
				phoneNumber,
				isAuthenticated,
				isLoading,
				setPhoneNumber,
				login,
				register,
				verifyOtp,
				resendOtp,
				logout,
			}}
		>
			{children}
		</AuthContext.Provider>
	);
}

export function useAuth() {
	const context = useContext(AuthContext);
	if (!context) {
		throw new Error('useAuth must be used within an AuthProvider');
	}
	return context;
}
