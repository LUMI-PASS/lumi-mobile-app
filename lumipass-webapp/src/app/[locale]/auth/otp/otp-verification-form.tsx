'use client';

import { useState, useRef, useEffect } from 'react';
import { useSearchParams } from 'next/navigation';
import { useRouter } from '@/i18n/routing';
import { Button, Text, Title, Loader } from 'rizzui';
import { useAuth } from '@/contexts/auth-context';
import { toast } from 'react-hot-toast';
import { routes } from '@/config/routes';
import { useTranslations } from 'next-intl';
import { useNavigationLock } from '@/hooks/use-navigation-lock';

export default function OtpVerificationForm() {
	const t = useTranslations('Auth');
	const [otp, setOtp] = useState<string[]>(['', '', '', '']);
	const [isVerifying, setIsVerifying] = useState(false);
	const [isResending, setIsResending] = useState(false);
	const [timeLeft, setTimeLeft] = useState(270);
	const [activeIndex, setActiveIndex] = useState(0);
	const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

	const { phoneNumber, verifyOtp, resendOtp } = useAuth();
	const router = useRouter();
	const searchParams = useSearchParams();
	const isRegistration = searchParams?.get('flow') === 'register';

	// Prevent back/forward during verify/resend
	const busy = isVerifying || isResending;
	useNavigationLock(busy);

	// Keep a stable phone to avoid blank flicker
	const stablePhoneRef = useRef<string | null>(null);
	useEffect(() => {
		if (phoneNumber) {
			stablePhoneRef.current = phoneNumber;
			try {
				sessionStorage.setItem('auth_phone', phoneNumber);
			} catch {}
		} else if (!stablePhoneRef.current && typeof window !== 'undefined') {
			stablePhoneRef.current = sessionStorage.getItem('auth_phone');
		}
	}, [phoneNumber]);

	const displayPhone = phoneNumber ?? stablePhoneRef.current ?? '';

	useEffect(() => {
		if (!displayPhone && !busy) {
			toast.error(t('EnterPhoneFirst'));
			router.replace(routes.auth.signIn);
		}
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [displayPhone, router]);

	useEffect(() => {
		if (timeLeft > 0) {
			const timer = setTimeout(() => setTimeLeft((s) => s - 1), 1000);
			return () => clearTimeout(timer);
		} else {
			toast.error(t('TimeExpired'));
			router.push(routes.auth.signIn);
		}
	}, [timeLeft, router, t]);

	useEffect(() => {
		if (!busy && otp.every((d) => d !== '')) void handleVerify();
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [otp, busy]);

	useEffect(() => {
		inputRefs.current[0]?.focus();
	}, []);

	const formatTime = () =>
		`(${String(Math.floor(timeLeft / 60)).padStart(2, '0')}:${String(timeLeft % 60).padStart(2, '0')})`;

	const handleChange = (index: number, value: string) => {
		if (value.length > 1) value = value[value.length - 1];
		if (!/^\d?$/.test(value)) return;
		const next = [...otp];
		next[index] = value;
		setOtp(next);
		if (value && index < 3) inputRefs.current[index + 1]?.focus();
	};

	const handleKeyDown = (
		index: number,
		e: React.KeyboardEvent<HTMLInputElement>
	) => {
		if (e.key === 'Backspace' && !otp[index] && index > 0)
			inputRefs.current[index - 1]?.focus();
	};

	const handlePaste = (e: React.ClipboardEvent<HTMLInputElement>) => {
		const text = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 4);
		if (!text) return;
		e.preventDefault();
		const next = ['', '', '', ''];
		for (let i = 0; i < text.length; i++) next[i] = text[i];
		setOtp(next);
		inputRefs.current[Math.min(text.length, 3)]?.focus();
	};

	const handleVerify = async () => {
		try {
			setIsVerifying(true);
			const code = otp.join('');
			if (code.length !== 4) {
				toast.error(t('InvalidOtp'));
				return;
			}
			const success = await verifyOtp(code, isRegistration);
			if (success) {
				toast.success(
					isRegistration ? t('RegistrationSuccess') : t('SignInSuccess')
				);
				router.replace(routes.home);
			}
		} catch {
			// console.error('Verification error:', error);
			toast.error(t('VerificationFailed'));
		} finally {
			setIsVerifying(false);
		}
	};

	const handleResendCode = async () => {
		setIsResending(true);
		try {
			const success = await resendOtp(isRegistration);
			if (success) {
				toast.success(t('OtpSent'));
				setTimeLeft(270);
				setOtp(['', '', '', '']);
				inputRefs.current[0]?.focus();
			}
		} catch {
			// console.error('Error resending code:', error);
			toast.error(t('ResendFailed'));
		} finally {
			setIsResending(false);
		}
	};

	const setInputRef = (index: number) => (el: HTMLInputElement | null) => {
		inputRefs.current[index] = el;
	};

	if (!displayPhone) return null;

	return (
		<div className="z-30 rounded-3xl border border-white/80 bg-white/95 px-6 py-8 shadow-[0_16px_30px_rgba(38,56,120,0.26)] backdrop-blur">
			<Title className="mb-1 text-center font-balsamiqSans text-2xl font-bold text-textGray">
				{t('VerifyPhoneTitle')}
			</Title>
			<Text as="p" className="mb-4 text-center font-balsamiqSans text-gray-500">
				{t('CodeSentTelegram')}
			</Text>

			<div className="mb-8 text-center font-semibold text-textGray">
				{displayPhone}
			</div>

			<div className="mb-2 flex justify-center gap-3">
				{[0, 1, 2, 3].map((index) => (
					<div
						key={index}
						className={`flex h-14 w-14 items-center justify-center rounded-2xl border bg-white/90 transition-all duration-150 ${
							otp[index] ? 'border-mainPurple shadow-[0_8px_18px_rgba(166,82,199,0.22)]' : 'border-mainPurple/35'
						} ${activeIndex === index ? 'border-2' : 'border-1'}`}
					>
						<input
							ref={setInputRef(index)}
							type="tel"
							inputMode="numeric"
							pattern="[0-9]*"
							autoComplete="one-time-code"
							enterKeyHint="done"
							aria-label={`OTP digit ${index + 1}`}
							className="h-full w-full rounded-xl border-0 text-center text-2xl font-bold outline-none"
							maxLength={1}
							value={otp[index]}
							onChange={(e) => handleChange(index, e.target.value)}
							onKeyDown={(e) => handleKeyDown(index, e)}
							onFocus={() => setActiveIndex(index)}
							onBlur={() => setActiveIndex(-1)}
							onPaste={handlePaste}
						/>
					</div>
				))}
			</div>

			<div className="mb-8 text-end text-gray-400">{formatTime()}</div>

			<Button
				className="mb-4 w-full rounded-2xl bg-mainPurple !py-6 text-white shadow-[0_8px_22px_rgba(166,82,199,0.35)] hover:brightness-95"
				onClick={handleVerify}
				isLoading={isVerifying}
				disabled={busy || otp.join('').length !== 4}
			>
				{t('Verify')}
			</Button>

			<Button
				variant="outline"
				className="w-full rounded-2xl border border-mainPurple/20 bg-mainPurple/8 !py-6 text-mainPurple"
				onClick={handleResendCode}
				disabled={busy || timeLeft > 240}
			>
				{isResending ? <Loader size="sm" /> : t('SendAgain')}
			</Button>
		</div>
	);
}
