'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import { useRouter } from '@/i18n/routing';
import { Input, Button, Loader, Select } from 'rizzui';
import {
	PiMapPinSimple,
	PiPhoneCall,
	PiUser,
	PiSealCheckFill,
	PiPhoneCallDuotone,
	PiMapPinAreaDuotone,
	PiUserDuotone,
} from 'react-icons/pi';
import Image from 'next/image';
import {
	getImageUrl,
	getParentProfile,
	updateParentProfile,
} from '@/services/api';
import { toast } from 'react-hot-toast';
import { routes } from '@/config/routes';
import ProfileHeader from '@/components/ui/page-header';
import { tashkentDistricts } from '@/config/constants';
import { useTranslations } from 'next-intl';
import {
	formatPhoneForDisplay,
	maskUzPhoneInput,
} from '@/utils/format-phone-number';
import { createAccountSchemas } from '@/validators/account-schema';

import DrawerButton from '@/components/ui/buttons/drawer-button';
import PhotoPickerDrawerView from '@/app/shared/views/photo-option-view';
import CameraView from '@/components/camera/cameraview';
import { AccountFormSkeleton, HeaderSkeleton } from '@/components/ui/skeletons';
import CheckNetwork from '@/app/[locale]/(other-pages)/check-network/check-network';

export default function AccountInfo() {
	const [profileData, setProfileData] = useState<any>(null);
	const [isLoading, setIsLoading] = useState<boolean>(true);
	const [isSaving, setIsSaving] = useState<boolean>(false);
	const [error, setError] = useState<string | null>(null);

	const [profileImage, setProfileImage] = useState<File | null>(null);
	const [previewUrl, setPreviewUrl] = useState<string | null>(null);
	const [cameraOpen, setCameraOpen] = useState(false);

	const fileInputRef = useRef<HTMLInputElement>(null);
	const cameraInputRef = useRef<HTMLInputElement>(null); // keep as fallback, optional
	const phoneInputRef = useRef<HTMLInputElement>(null);

	const router = useRouter();
	const t = useTranslations('Profile.Account');

	const { api: accountApiSchema } = useMemo(() => createAccountSchemas(t), [t]);

	const [formData, setFormData] = useState({
		first_name: '',
		last_name: '',
		phone_number: '',
		city: 'Tashkent',
		district: '',
	});

	const [errors, setErrors] = useState<Record<string, string>>({});

	useEffect(() => {
		const fetchProfileData = async () => {
			try {
				setIsLoading(true);
				const response = await getParentProfile();
				setProfileData(response.data);

				const profile = response.data.profile;
				setFormData({
					first_name: profile.first_name || '',
					last_name: profile.last_name || '',
					phone_number: formatPhoneForDisplay(profile.phone_number || ''),
					city: profile.city || 'Tashkent',
					district: profile.district || '',
				});
			} catch (err: any) {
				setError(err.message || 'Failed to load account information');
				// console.error('Error fetching account information:', err);
			} finally {
				setIsLoading(false);
			}
		};

		fetchProfileData();
	}, []);

	// PHONE MASK
	const handlePhoneChange = (e: React.ChangeEvent<HTMLInputElement>) => {
		const { value, selectionStart } = e.target;
		const { value: masked, caret } = maskUzPhoneInput(
			value,
			selectionStart ?? 0
		);
		setFormData((prev) => ({ ...prev, phone_number: masked }));
		requestAnimationFrame(() =>
			phoneInputRef.current?.setSelectionRange(caret, caret)
		);
		if (errors.phone_number) setErrors(({ phone_number, ...rest }) => rest);
	};

	const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
		const { name, value } = e.target;
		if (name === 'phone_number') return handlePhoneChange(e);
		setFormData((prev) => ({ ...prev, [name]: value }));
		if (errors[name])
			setErrors((prev) => {
				const n = { ...prev };
				delete n[name];
				return n;
			});
	};

	const handleDistrictChange = (value: string) => {
		setFormData((prev) => ({ ...prev, district: value }));
		if (errors.district) {
			setErrors((prev) => {
				const n = { ...prev };
				delete n.district;
				return n;
			});
		}
	};

	// IMAGE: gallery file
	const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
		if (e.target.files?.[0]) {
			const file = e.target.files[0];
			setProfileImage(file);
			setPreviewUrl(URL.createObjectURL(file));
		}
	};

	const handleGalleryClick = () => fileInputRef.current?.click();
	const handleCameraClick = () => setCameraOpen(true); // open overlay camera

	// Camera capture callback
	const handleCapture = (file: File) => {
		setProfileImage(file);
		setPreviewUrl(URL.createObjectURL(file));
		setCameraOpen(false);
	};

	const handleSubmit = async (e: React.FormEvent) => {
		e.preventDefault();

		const parsed = accountApiSchema.safeParse(formData);
		if (!parsed.success) {
			const fieldErrors: Record<string, string> = {};
			parsed.error.issues.forEach((err) => {
				const key = (err.path[0] as string) ?? 'form';
				if (!fieldErrors[key]) fieldErrors[key] = err.message;
			});
			setErrors(fieldErrors);
			return;
		}

		try {
			setIsSaving(true);
			await updateParentProfile(parsed.data);
			toast.success(t('Toast.Saved'));
			setTimeout(() => router.push(routes.profile.base), 800);
		} catch (err: any) {
			toast.error(t('Toast.SaveError'));
			// console.error('Error updating account information:', err);
		} finally {
			setIsSaving(false);
		}
	};

	if (isLoading) {
		return (
			<div className="flex h-screen flex-col pb-20">
				<HeaderSkeleton />
				<AccountFormSkeleton />
			</div>
		);
	}

	if (error && !isLoading) {
		return <CheckNetwork />;
	}

	const isVerified = profileData?.profile?.is_verified || false;
	const hasPhoto = profileData?.profile?.has_photo || false;

	return (
		<div className="flex h-screen flex-col pb-16">
			<ProfileHeader title={t('Title')} href={routes.profile.base} compact />

			<form
				onSubmit={handleSubmit}
				className="flex h-full flex-1 flex-col items-center gap-7 px-7 pb-3 pt-10"
			>
				{/* Avatar */}
				{/* <div className="relative my-0.5">
					<DrawerButton
						size="sm"
						modalView={
							<PhotoPickerDrawerView
								title={t('Photo.Title')}
								chooseLabel={t('Photo.Choose')}
								takeLabel={t('Photo.Take')}
								closeLabel={t('Photo.Close')}
								onPickFromGallery={handleGalleryClick}
								onTakePhoto={() => setCameraOpen(true)}
							/>
						}
						placement="bottom"
						height="33vh"
						className="!border-0 !bg-transparent !p-0 !shadow-none !ring-0"
					>
						<div className="relative h-28 w-28 cursor-pointer overflow-hidden rounded-full border-4 border-white/90 bg-gray-200 shadow-md">
							{previewUrl ? (
								<Image
									src={previewUrl}
									alt="Profile"
									fill
									className="object-cover"
								/>
							) : hasPhoto ? (
								<Image
									src={`/api/v1/users/parents/profile/photo?${new Date().getTime()}`}
									alt="Profile"
									fill
									className="object-cover"
								/>
							) : (
								<div className="flex h-full w-full items-center justify-center bg-gray-100">
									<PiUserDuotone className="h-14 w-14 text-gray-400" />
								</div>
							)}
						</div>
					</DrawerButton>

					<input
						type="file"
						accept=".png,.jpg,.jpeg,.heic"
						ref={fileInputRef}
						onChange={handleImageChange}
						className="hidden"
					/>
					<input
						type="file"
						accept=".png,.jpg,.jpeg,.heic"
						capture="user"
						ref={cameraInputRef}
						onChange={handleImageChange}
						className="hidden"
					/>
				</div> */}

				{/* First Name */}
				<div className="group w-full">
					<Input
						prefix={
							<PiUserDuotone className="h-4 w-4 text-inherit group-focus-within:text-mainPurple" />
						}
						label={t('Labels.FirstName')}
						type="text"
						labelClassName="text-textGray font-bold text-sm"
						name="first_name"
						value={formData.first_name}
						onChange={handleInputChange}
						placeholder={t('Placeholders.FirstName')}
						className="w-full border-none outline-none ring-0"
						inputClassName="h-14 rounded-xl border-0 bg-white text-xs ring-0 focus:border-0 focus:outline-none focus:ring-0"
						size="lg"
					/>
					{errors.first_name && (
						<p className="mt-1 text-xs text-red-500">{errors.first_name}</p>
					)}
				</div>

				{/* Last Name */}
				<div className="group w-full">
					<Input
						prefix={
							<PiUserDuotone className="h-4 w-4 text-inherit group-focus-within:text-mainPurple" />
						}
						label={t('Labels.LastName')}
						type="text"
						labelClassName="text-textGray font-bold text-sm"
						name="last_name"
						value={formData.last_name}
						onChange={handleInputChange}
						placeholder={t('Placeholders.LastName')}
						className="w-full border-none outline-none ring-0"
						inputClassName="h-14 rounded-xl border-0 bg-white text-xs ring-0 focus:border-0 focus:outline-none focus:ring-0"
						size="lg"
					/>
					{errors.last_name && (
						<p className="mt-1 text-xs text-red-500">{errors.last_name}</p>
					)}
				</div>

				{/* Phone */}
				<div className="group w-full">
					<Input
						label={t('Labels.PhoneNumber')}
						labelClassName="text-textGray font-bold text-sm"
						type="tel"
						inputMode="tel"
						autoComplete="tel"
						prefix={
							<PiPhoneCallDuotone className="h-4 w-4 text-inherit group-focus-within:text-mainPurple" />
						}
						name="phone_number"
						value={formData.phone_number}
						onChange={handlePhoneChange}
						placeholder={t('Placeholders.PhonePlaceholder')}
						className="w-full border-none outline-none ring-0"
						inputClassName="h-14 rounded-xl border-0 bg-white text-xs ring-0 focus:border-0 focus:outline-none focus:ring-0"
						disabled={true}
						size="lg"
						ref={phoneInputRef}
					/>
					{errors.phone_number && (
						<p className="mt-1 text-xs text-red-500">{errors.phone_number}</p>
					)}
				</div>

				{/* District */}
				<div className="group w-full">
					<Select
						label={t('Labels.District')}
						name="district"
						labelClassName="text-textGray font-bold text-sm"
						prefix={
							<PiMapPinAreaDuotone
								size={18}
								className="text-inherit group-focus-within:text-mainPurple"
							/>
						}
						options={tashkentDistricts}
						value={formData.district}
						onChange={(v) => handleDistrictChange(String(v))}
						getOptionValue={(option) => option.value}
						displayValue={(selected) =>
							tashkentDistricts.find((d) => d.value === selected)?.label ?? ''
						}
						placeholder={t('Placeholders.District')}
						className="w-full outline-none ring-0"
						selectClassName="h-14 rounded-xl border-0 bg-white text-xs outline-0 ring-0 focus:border-0 focus:ring-0"
						dropdownClassName="[&>li:hover]:bg-purple-50 rounded-md"
					/>
					{errors.district && (
						<p className="mt-1 text-xs text-red-500">{errors.district}</p>
					)}
				</div>

				{/* Save */}
				<Button
					type="submit"
					disabled={isSaving}
					isLoading={isSaving}
					size="lg"
					className="mt-auto w-full rounded-2xl bg-mainPurple py-6 text-sm font-bold text-white shadow-[0_10px_22px_rgba(166,82,199,0.32)] hover:brightness-95"
				>
					{t('Actions.SaveChanges')}
				</Button>
			</form>

			{/* Camera overlay */}
			{cameraOpen && (
				<CameraView
					onCapture={handleCapture}
					onClose={() => setCameraOpen(false)}
				/>
			)}
		</div>
	);
}
