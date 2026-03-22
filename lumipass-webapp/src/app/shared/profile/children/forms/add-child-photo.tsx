'use client';

import { useState, useRef, useEffect } from 'react';
import Image from 'next/image';
import { Button } from 'rizzui';
import { PiCamera, PiCameraDuotone, PiImage, PiImageDuotone, PiUser } from 'react-icons/pi';
import { toast } from 'react-hot-toast';
import CameraView from '@components/ui/cameraview';
import { useNavbar } from '@/contexts/navbar-context';
import { useTranslations } from 'next-intl';
interface AddChildPhotoProps {
	onSubmit: (photo: File) => void;
	onCancel: () => void;
	isLoading: boolean;
}

export default function AddChildPhoto({
	onSubmit,
	onCancel,
	isLoading,
}: AddChildPhotoProps) {
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
			setPhoto(selectedFile);
			setPreviewUrl(URL.createObjectURL(selectedFile));
		}
	};

	const isPromise = (v: unknown): v is Promise<unknown> =>
		!!v && typeof (v as any).then === 'function';

	const handleUploadClick = () => {
		if (fileInputRef.current) {
			fileInputRef.current.click();
		}
	};

	const handleCameraClick = () => {
		setShowCamera(true);
	};

	const handleCapturedPhoto = (imageFile: File) => {
		setPhoto(imageFile);
		setPreviewUrl(URL.createObjectURL(imageFile));
		setShowCamera(false);
	};

	const handleSubmit = async () => {
		if (!photo) {
			toast.error(t('PhotoRequired'));
			return;
		}
		const result = onSubmit(photo);
		if (isPromise(result)) {
			await toast.promise(result, {
				loading: t('Uploading') || 'Uploading…',
				success: t('AddSuccess') || 'Photo uploaded!',
				error: t('AddFail') || 'Failed to upload photo',
			});
		} else {
			toast.success(t('AddSuccess') || 'Photo uploaded!');
		}
	};

	if (showCamera) {
		return (
			<CameraView
				onCapture={handleCapturedPhoto}
				onClose={() => setShowCamera(false)}
			/>
		);
	}

	return (
		<div className="flex flex-1 flex-col items-center px-6">
			<h2 className="mb-2 text-center text-lg font-black text-textGray">
				{t('AddTitle')}
			</h2>
			<p className="mb-6 text-center text-sm text-gray-600">{t('AddHint')}</p>

			{/* Photo Preview */}
			<div className="mb-8 flex flex-col items-center w-full">
				<div
					onClick={handleUploadClick}
					className="relative cursor-pointer mb-10 h-44 w-44 overflow-hidden rounded-full border-4 border-mainPurple bg-gray-100 shadow-md"
				>
					{previewUrl ? (
						<Image
							src={previewUrl}
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

				<div className="flex w-full items-center gap-2">
          <Button
            size='md'
						variant="outline"
						onClick={handleUploadClick}
						className="text-xs flex w-full items-center justify-center gap-1.5 rounded-xl bg-white"
					>
						<PiImageDuotone className='size-4 text-inherit' />
						<span>{t('Upload')}</span>
					</Button>

          <Button
            size='md'
						variant="outline"
						onClick={handleCameraClick}
						className="text-xs flex w-full items-center justify-center gap-1.5 rounded-xl bg-white"
					>
						<PiCameraDuotone className='size-4 text-inherit' />
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

			<div className="mt-auto w-full flex items-center justify-center pt-5">
				<Button
					type="submit"
					variant="solid"
					size="lg"
					className="flex-1 rounded-xl bg-mainPurple py-6 text-white hover:bg-mainPurple/90"
					onClick={handleSubmit}
					disabled={!photo || isLoading}
					isLoading={isLoading}
				>
					{t('Submit')}
				</Button>
			</div>
		</div>
	);
}
