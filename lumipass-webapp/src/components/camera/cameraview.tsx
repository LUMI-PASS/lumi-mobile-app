'use client';

import { useRef, useState, useCallback, useEffect } from 'react';
import Webcam from 'react-webcam';
import { Button } from 'rizzui';
import {
	PiArrowLeft,
	PiFlipHorizontalFill,
	PiUploadSimple,
} from 'react-icons/pi';
import { toast } from 'react-hot-toast';
import { useTranslations } from 'next-intl';
import { useNavbar } from '@/contexts/navbar-context'; // ⬅️ ADD

interface CameraViewProps {
	onCapture: (photo: File) => void;
	onClose: () => void;
}

export default function CameraView({ onCapture, onClose }: CameraViewProps) {
	const webcamRef = useRef<Webcam | null>(null);
	const fileInputRef = useRef<HTMLInputElement>(null);
	const [devices, setDevices] = useState<MediaDeviceInfo[]>([]);
	const [cameraError, setCameraError] = useState<string | null>(null);
	const [isLoading, setIsLoading] = useState(true);
	const [isSecureContext, setIsSecureContext] = useState(true);
	const [facingMode, setFacingMode] = useState<'user' | 'environment'>('user');
	const t = useTranslations('Profile.CameraView');
	const { hideNavbar, showNavbar } = useNavbar(); // ⬅️ ADD

	// ⬇️ Hide bottom nav while camera is open, restore on close
	useEffect(() => {
		hideNavbar();
		return () => showNavbar();
	}, [hideNavbar, showNavbar]);

	useEffect(() => {
		if (typeof window !== 'undefined') {
			setIsSecureContext(window.isSecureContext);
			if (!window.isSecureContext) setCameraError(t('HttpsRequired'));
		}
	}, [t]);

	useEffect(() => {
		const getDevices = async () => {
			try {
				if (!navigator.mediaDevices?.enumerateDevices)
					throw new Error('Media Devices API not supported');
				const all = await navigator.mediaDevices.enumerateDevices();
				const videoDevices = all.filter((d) => d.kind === 'videoinput');
				setDevices(videoDevices);
				if (!videoDevices.length) setCameraError(t('NoCameras'));
			} catch {
				setCameraError(t('DeviceAccessFailed'));
			} finally {
				setIsLoading(false);
			}
		};
		getDevices();
	}, [t]);

	useEffect(() => {
		const timer = setTimeout(() => {
			if (isLoading) {
				setIsLoading(false);
				if (!cameraError && !webcamRef.current) setCameraError(t('InitFailed'));
			}
		}, 5000);
		return () => clearTimeout(timer);
	}, [isLoading, cameraError, t]);

	const takePhoto = useCallback(() => {
		if (!webcamRef.current) {
			toast.error(t('NoAccess'));
			return;
		}
		const imageSrc = webcamRef.current.getScreenshot();
		if (!imageSrc) {
			toast.error(t('FailedToCapture'));
			return;
		}
		const base64 = imageSrc.replace(/^data:image\/jpeg;base64,/, '');
		const bytes = new Uint8Array(
			atob(base64)
				.split('')
				.map((c) => c.charCodeAt(0))
		);
		const file = new File(
			[new Blob([bytes], { type: 'image/jpeg' })],
			`photo_${Date.now()}.jpg`,
			{ type: 'image/jpeg' }
		);
		onCapture(file);
	}, [onCapture, t]);

	const switchCamera = useCallback(() => {
		if (devices.length <= 1) return;
		setFacingMode((m) => (m === 'user' ? 'environment' : 'user'));
	}, [devices.length]);

	const handleWebcamError = useCallback((err: unknown) => {
		const msg =
			typeof err === 'string'
				? err
				: (err as DOMException)?.message || 'Camera error';
		setCameraError(msg);
		setIsLoading(false);
	}, []);

	const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
		if (e.target.files?.[0]) onCapture(e.target.files[0]);
	};

	const openFileDialog = () => fileInputRef.current?.click();

	const videoConstraints = {
		facingMode,
		width: { ideal: 1280 },
		height: { ideal: 720 },
	};

	if (cameraError || !isSecureContext) {
		return (
			<div className="fixed inset-0 z-50 flex h-screen w-screen flex-col bg-white">
				<div className="flex items-center justify-between bg-white px-4 py-3 shadow-sm">
					<Button
						variant="text"
						onClick={onClose}
						className="flex items-center text-gray-800"
					>
						<PiArrowLeft size={24} />
						<span className="ml-2">{t('Back')}</span>
					</Button>
				</div>

				<div className="flex flex-1 flex-col items-center justify-center p-6">
					<div className="mb-6 text-center">
						<h3 className="mb-2 text-xl font-bold text-red-800">
							{t('CameraNotAvailable')}
						</h3>
						<p className="text-gray-600">{t('CheckPermissions')}</p>
					</div>

					<Button
						variant="solid"
						onClick={openFileDialog}
						className="flex items-center justify-center gap-2 rounded-xl bg-mainPurple px-6 py-4 text-white"
					>
						<PiUploadSimple size={20} />
						<span>{t('Choose')}</span>
					</Button>

					<input
						type="file"
						accept=".png,.jpg,.jpeg,.heic"
						onChange={handleFileUpload}
						ref={fileInputRef}
						className="hidden"
					/>
				</div>
			</div>
		);
	}

	if (isLoading) {
		return (
			<div className="fixed inset-0 z-50 flex h-screen w-screen flex-col items-center justify-center bg-black">
				<div className="text-center text-white">
					<div className="mb-4 h-12 w-12 animate-spin rounded-full border-4 border-white border-t-transparent"></div>
					<p>{t('Initializing')}</p>
					<p className="mt-2 text-sm text-gray-300">{t('EnsurePermissions')}</p>
				</div>
			</div>
		);
	}

	return (
		<div className="fixed inset-0 z-50 flex h-screen w-screen flex-col bg-black">
			{/* Header */}
			<div className="flex items-center justify-between bg-black px-4 py-3">
				<Button
					variant="text"
					onClick={onClose}
					className="flex items-center gap-2 text-white"
				>
					<PiArrowLeft size={24} />
					{t('Back')}
				</Button>
				<Button
					variant="text"
					onClick={switchCamera}
					className="flex items-center gap-2 text-white"
				>
					<PiFlipHorizontalFill size={24} />
					{t('Flip')}
				</Button>
			</div>

			{/* Camera (mirror the front camera) */}
			<div className="relative flex max-h-[65vh] flex-1 items-center justify-center bg-black">
				<Webcam
					ref={webcamRef}
					audio={false}
					videoConstraints={videoConstraints}
					screenshotFormat="image/jpeg"
					screenshotQuality={1}
					mirrored={facingMode === 'user'}
					onUserMediaError={handleWebcamError}
					className="h-full w-full object-contain"
					style={{ maxHeight: '100%', maxWidth: '100%' }}
				/>
			</div>

			{/* Shutter */}
			<div className="z-10 mt-auto flex h-24 items-center justify-center bg-black px-4">
				<div className="relative flex w-full items-center justify-center">
					<Button
						variant="outline"
						onClick={takePhoto}
						className="z-20 h-16 w-16 rounded-full border-4 border-white"
					>
						<span className="h-12 w-12 rounded-full bg-white"></span>
					</Button>
				</div>
			</div>
		</div>
	);
}
