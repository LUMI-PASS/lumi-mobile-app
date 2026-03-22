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
import { useNavbar } from '@/contexts/navbar-context';
import { useTranslations } from 'next-intl';
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
	const { hideNavbar } = useNavbar();
	const [facingMode, setFacingMode] = useState<'user' | 'environment'>('user');
	const t = useTranslations('Profile.CameraView');

	// Check if we're in a secure context (needed for camera access)
	useEffect(() => {
		if (typeof window !== 'undefined') {
			setIsSecureContext(window.isSecureContext);
			if (!window.isSecureContext) {
				setCameraError(
					'Camera requires HTTPS to work. Please use a secure connection.'
				);
			}
		}
	}, []);

	useEffect(() => {
		hideNavbar();
	}, [hideNavbar]);

	// Fetch available video devices
	useEffect(() => {
		const getDevices = async () => {
			try {
				if (
					!navigator.mediaDevices ||
					!navigator.mediaDevices.enumerateDevices
				) {
					throw new Error('Media Devices API not supported');
				}

				const devices = await navigator.mediaDevices.enumerateDevices();
				const videoDevices = devices.filter(
					(device) => device.kind === 'videoinput'
				);

				setDevices(videoDevices);

				if (videoDevices.length === 0) {
					setCameraError('No cameras detected on your device');
				}
			} catch (error) {
				// console.error('Error accessing media devices:', error);
				setCameraError('Failed to access camera devices');
			} finally {
				setIsLoading(false);
			}
		};

		getDevices();
	}, []);

	// Add a loading state timeout
	useEffect(() => {
		const timer = setTimeout(() => {
			if (isLoading) {
				setIsLoading(false);
				if (!cameraError && !webcamRef.current) {
					setCameraError(
						'Could not initialize camera. Please check your permissions or try uploading instead.'
					);
				}
			}
		}, 5000);

		return () => clearTimeout(timer);
	}, [isLoading, cameraError]);

	// Take photo
	const takePhoto = useCallback(() => {
		if (!webcamRef.current) {
			toast.error(t('NoAccess'));
			return;
		}

		try {
			const imageSrc = webcamRef.current.getScreenshot();
			if (!imageSrc) {
				toast.error(t('FailedToCapture'));
				return;
			}

			// Convert base64 to file
			const base64Data = imageSrc.replace(/^data:image\/jpeg;base64,/, '');
			const byteCharacters = atob(base64Data);
			const byteNumbers = new Array(byteCharacters.length);

			for (let i = 0; i < byteCharacters.length; i++) {
				byteNumbers[i] = byteCharacters.charCodeAt(i);
			}

			const byteArray = new Uint8Array(byteNumbers);
			const blob = new Blob([byteArray], { type: 'image/jpeg' });

			// Create file from blob
			const fileName = `photo_${Date.now()}.jpg`;
			const file = new File([blob], fileName, { type: 'image/jpeg' });

			onCapture(file);
		} catch (err) {
			// console.error('Error taking photo:', err);
			toast.error(t('FailedToCapture'));
		}
	}, [onCapture]);

	// Switch camera
	const switchCamera = useCallback(() => {
		if (devices.length <= 1) return;

		// Toggle between front and back camera
		setFacingMode((prevMode) => (prevMode === 'user' ? 'environment' : 'user'));
	}, [devices.length]);

	// Handle errors from webcam
	const handleWebcamError = useCallback((err: string | DOMException) => {
		// console.error('Webcam error:', err);
		const errorMessage =
			typeof err === 'string' ? err : err.message || 'Camera error occurred';
		setCameraError(errorMessage);
		setIsLoading(false);
	}, []);

	// Handle file upload as fallback
	const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
		if (e.target.files && e.target.files[0]) {
			onCapture(e.target.files[0]);
		}
	};

	// Open file dialog
	const openFileDialog = () => {
		if (fileInputRef.current) {
			fileInputRef.current.click();
		}
	};

	// Webcam configuration
	const videoConstraints = {
		facingMode: facingMode,
		width: { ideal: 1280 },
		height: { ideal: 720 },
	};

	// Render fallback UI when camera is not available or loading
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

						<div className="mt-4 rounded-md bg-yellow-50 p-4">
							<h5 className="font-bold text-yellow-800">
								{t('TroubleShooting')}
							</h5>
							<ul className="mt-2 list-inside list-disc text-left text-sm text-yellow-700">
								<li>{t('Tip1')}</li>
								<li>{t('Tip2')}</li>
								<li>{t('Tip3')}</li>
								<li>{t('Tip4')}</li>
								<li>{t('Tip5')}</li>
							</ul>
						</div>
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

			{/* Camera View */}
			<div className="relative flex max-h-[65vh] flex-1 items-center justify-center bg-black">
				<Webcam
					ref={webcamRef}
					audio={false}
					videoConstraints={videoConstraints}
					screenshotFormat="image/jpeg"
					screenshotQuality={1}
					mirrored={facingMode === 'environment'}
					onUserMediaError={handleWebcamError}
					className="h-full w-full object-contain"
					style={{ maxHeight: '100%', maxWidth: '100%' }}
				/>
			</div>

			<div className="z-10 mt-auto flex h-24 items-center justify-center bg-black px-4">
				<div className="relative flex w-full items-center justify-center">
					<Button
						variant="outline"
						onClick={takePhoto}
						className="z-20 h-16 w-16 rounded-full border-4 border-white"
					>
						<span className="h-12 w-12 rounded-full bg-white"></span>
					</Button>

					{/* <Button
						variant="text"
						onClick={openFileDialog}
						className="absolute right-2 z-20 text-white"
					>
						<PiUploadSimple size={24} />
						<span className="ml-1">{t('Choose')}</span>
					</Button> */}
				</div>

				{/* <input
					type="file"
					accept=".png,.jpg,.jpeg,.heic"
					onChange={handleFileUpload}
					ref={fileInputRef}
					className="hidden"
				/> */}
			</div>
		</div>
	);
}
