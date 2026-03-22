'use client';

import { useState, useRef, useEffect } from 'react';
import Image from 'next/image';
import { Button } from 'rizzui';
import {
	PiCamera,
	PiImage,
	PiUser,
	PiSealCheckFill,
	PiCameraDuotone,
	PiImageDuotone,
} from 'react-icons/pi';
import { toast } from 'react-hot-toast';
import { getChildImageUrl } from '@/services/api';
import CameraView from '@/components/ui/cameraview';
import { useNavbar } from '@/contexts/navbar-context';
import { useTranslations } from 'next-intl';

interface EditChildPhotoProps {
	childId: string;
	hasExistingPhoto: boolean;
	isVerified: boolean;
	onSubmit: (photo: File) => void | Promise<unknown>;
	onSkip: () => void;
	isLoading: boolean;
}

export default function EditChildPhoto({
	childId,
	hasExistingPhoto,
	isVerified,
	onSubmit,
	onSkip,
	isLoading,
}: EditChildPhotoProps) {
	const [photo, setPhoto] = useState<File | null>(null);
	const [previewUrl, setPreviewUrl] = useState<string | null>(null);
	const [showCamera, setShowCamera] = useState<boolean>(false);
	const fileInputRef = useRef<HTMLInputElement>(null);
	const { hideNavbar, showNavbar } = useNavbar();
	const t = useTranslations('Profile.Children.Photo');

	useEffect(() => {
		hideNavbar();
		return () => showNavbar();
	}, [hideNavbar, showNavbar]);

	const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
		if (e.target.files && e.target.files[0]) {
			const selectedFile = e.target.files[0];

			// 10MB limit
			if (selectedFile.size > 10 * 1024 * 1024) {
				toast.error(t('SizeLimit'));
				return;
			}

			setPhoto(selectedFile);
			if (previewUrl) URL.revokeObjectURL(previewUrl);
			setPreviewUrl(URL.createObjectURL(selectedFile));
		}
	};

	const handleUploadClick = (e: React.MouseEvent) => {
		e.preventDefault();
		e.stopPropagation();
		fileInputRef.current?.click();
	};

	const handleCameraClick = (e: React.MouseEvent) => {
		e.preventDefault();
		e.stopPropagation();
		setShowCamera(true);
	};

	const handleCapturedPhoto = (imageFile: File) => {
		setPhoto(imageFile);
		if (previewUrl) URL.revokeObjectURL(previewUrl);
		setPreviewUrl(URL.createObjectURL(imageFile));
		setShowCamera(false);
	};

	const isPromise = (v: unknown): v is Promise<unknown> =>
		!!v && typeof (v as any).then === 'function';

	const handleSubmit = async () => {
		if (!photo) {
			if (hasExistingPhoto) {
				onSkip();
				return;
			}
			toast.error(t('PhotoRequired'));
			return;
		}
		try {
			const result = onSubmit(photo);
			if (isPromise(result)) {
				await toast.promise(result, {
					loading: t('Uploading') || 'Uploading…',
					success: t('UpdateSuccess') || 'Photo uploaded!',
					error: t('UpdateFail') || 'Failed to upload photo',
				});
			} else {
				toast.success(t('UpdateSuccess') || 'Photo uploaded!');
			}
		} catch {
			// console.error('Photo upload failed');
		}
	};

	useEffect(() => {
		return () => {
			if (previewUrl) URL.revokeObjectURL(previewUrl);
		};
	}, [previewUrl]);

	if (showCamera) {
		return (
			<CameraView
				onCapture={handleCapturedPhoto}
				onClose={() => setShowCamera(false)}
			/>
		);
	}

	return (
		<div className="flex flex-col items-center px-6">
			{/* <h2 className="mb-4 text-center text-lg font-bold text-gray-800">
				{hasExistingPhoto ? t('UpdateTitle') : t('AddTitle')}
			</h2> */}

			<p className="my-6 text-center text-sm text-gray-600">
				{hasExistingPhoto ? t('UpdateHint') : t('AddHint')}
			</p>

			{/* Photo Preview */}
			<div className="mb-8 flex flex-col items-center w-full">
				<div
					onClick={handleUploadClick}
					className="relative mb-4 h-44 w-44 cursor-pointer overflow-hidden rounded-full border-4 border-mainPurple bg-gray-100 shadow-md"
				>
					{previewUrl ? (
						<Image
							src={previewUrl}
							alt="Child Photo Preview"
							fill
							className="object-cover"
						/>
					) : hasExistingPhoto ? (
						<Image
							src={getChildImageUrl(childId)}
							alt="Child Photo"
							fill
							className="object-cover"
						/>
					) : (
						<div className="flex h-full w-full items-center justify-center">
							<PiUser className="h-20 w-20 text-gray-400" />
						</div>
					)}
				</div>

				{/* Upload/Camera Buttons */}
				<div className="flex w-full items-center gap-2 mt-3">
					<Button
						size="md"
						variant="outline"
						onClick={handleUploadClick}
						className="flex w-full items-center justify-center gap-1.5 rounded-xl bg-white text-xs"
					>
						<PiImageDuotone className="size-4 text-inherit" />
						<span>{t('Upload')}</span>
					</Button>

					<Button
						size="md"
						variant="outline"
						onClick={handleCameraClick}
						className="flex w-full items-center justify-center gap-1.5 rounded-xl bg-white text-xs"
					>
						<PiCameraDuotone className="size-4 text-inherit" />
						<span>{t('Take')}</span>
					</Button>

					<input
						type="file"
						accept=".png,.jpg,.jpeg,.heic"
						onChange={handleFileChange}
						ref={fileInputRef}
						className="hidden"
					/>
				</div>
			</div>

			<div className="mt-auto flex w-full gap-4 pt-2">
				<Button
					type="button"
					variant="outline"
					color="danger"
					className="flex-1 rounded-xl bg-white py-4"
					onClick={onSkip}
					disabled={isLoading}
				>
					{hasExistingPhoto ? t('Cancel') : t('Skip')}
				</Button>

				<Button
					type="button"
					variant="solid"
					className="flex-1 rounded-xl bg-mainPurple py-4 text-white hover:bg-mainPurple/90"
					onClick={handleSubmit}
					disabled={isLoading || (!photo && !hasExistingPhoto)}
					isLoading={isLoading}
				>
					{t('Submit')}
				</Button>
			</div>
		</div>
	);
}
