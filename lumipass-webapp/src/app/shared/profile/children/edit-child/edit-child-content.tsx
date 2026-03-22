'use client';

import { useState, useEffect } from 'react';
import { useRouter } from '@/i18n/routing';
import { useParams } from 'next/navigation';
import { Stepper } from 'rizzui';
import ProfileHeader from '@/components/ui/page-header';
import { routes } from '@/config/routes';
import { toast } from 'react-hot-toast';
import EditChildForm from '../forms/edit-child-form';
import EditChildPhoto from '../forms/edit-child-photo';
import { PiUserCircle, PiCamera } from 'react-icons/pi';
import {
	getChildDetails,
	getParentProfile,
	updateChildInfo,
	uploadChildPhoto,
} from '@/services/api';
import CheckNetwork from '@/app/[locale]/(other-pages)/check-network/check-network';
import { useTranslations } from 'next-intl';
import {
	EditChildFormSkeleton,
	HeaderSkeleton,
	StepperSkeleton,
} from '@/components/ui/skeletons';
import { useAuth } from '@/contexts/auth-context';

export default function EditChildPage() {
	const params = useParams();
	const childId = params.id as string;
	const router = useRouter();
	const t = useTranslations('Profile.Children');
	const { user } = useAuth();

	const [currentStep, setCurrentStep] = useState(0);
	const [childData, setChildData] = useState<any>(null);
	const [parentLocation, setParentLocation] = useState({
		city: 'Tashkent',
		district: '',
	});
	const [isLoading, setIsLoading] = useState(true);
	const [isSubmitting, setIsSubmitting] = useState(false);
	const [error, setError] = useState<string | null>(null);

	// Fetch child data on mount
	useEffect(() => {
		setParentLocation({
			city: user?.city || 'Tashkent',
			district: user?.district || '',
		});

		const fetchChildData = async () => {
			try {
				setIsLoading(true);
				const [childResponse, parentResponse] = await Promise.all([
					getChildDetails(childId),
					getParentProfile().catch(() => null),
				]);
				setChildData(childResponse.data);
				const profile = parentResponse?.data?.profile;
				if (profile) {
					setParentLocation({
						city: profile.city || user?.city || 'Tashkent',
						district: profile.district || user?.district || '',
					});
				}
			} catch (err: any) {
				setError(err.message || 'Failed to load child information');
				toast.error(t('FailedToLoad'));
			} finally {
				setIsLoading(false);
			}
		};

		if (childId) {
			fetchChildData();
		}
	}, [childId, t, user?.city, user?.district]);

	// Step 1 submission handler
	const handleFormSubmit = async (formData: any) => {
		setIsSubmitting(true);
		try {
			const payload = {
				...formData,
				city: parentLocation.city || user?.city || 'Tashkent',
				district: parentLocation.district || user?.district || '',
			};
			await updateChildInfo(childId, payload);
			toast.success(t('Edit.UpdateSuccess'));
			setCurrentStep(1);
		} catch (error: any) {
			toast.error(t('Edit.FailedToEdit'));
		} finally {
			setIsSubmitting(false);
		}
	};

	// Step 2 submission handler
	const handlePhotoSubmit = async (photo: File) => {
		setIsSubmitting(true);
			try {
				await uploadChildPhoto(childId, photo);
				setTimeout(() => {
					router.push(routes.profile.myChildren);
				}, 600);
			} catch (error: any) {
				toast.error(t('Photo.UpdateFail'));
			} finally {
				setIsSubmitting(false);
		}
	};

	// Skip photo step handler
	const handleSkipPhoto = () => {
		router.push(routes.profile.myChildren);
	};

	if (isLoading) {
		return (
			<div className="flex min-h-screen flex-col pb-20">
				<HeaderSkeleton />
				<StepperSkeleton />
				<EditChildFormSkeleton />
			</div>
		);
	}

	if (error) {
		return <CheckNetwork />;
	}

	return (
		<div className="flex min-h-screen flex-col pb-20">
			<ProfileHeader
				isRequiredPage={true}
				title={t('Edit.Title')}
				href={routes.profile.myChildren}
			/>

			{/* Stepper */}
			<div className="px-6 py-4">
				<Stepper currentIndex={currentStep} className="w-full">
					<Stepper.Step
						variant="outline"
						title={t('Edit.Stepper.Info')}
						icon={<PiUserCircle className="h-5 w-5" />}
					/>
					<Stepper.Step
						variant="outline"
						title={t('Edit.Stepper.Photo')}
						icon={<PiCamera className="h-5 w-5" />}
					/>
				</Stepper>
			</div>

			{/* Step content */}
			<div className="flex-1">
				{currentStep === 0 && childData && (
					<EditChildForm
						initialData={childData}
						onSubmit={handleFormSubmit}
						isLoading={isSubmitting}
						parentCity={parentLocation.city}
						parentDistrict={parentLocation.district}
					/>
				)}

				{currentStep === 1 && (
					<EditChildPhoto
						childId={childId}
						hasExistingPhoto={childData?.has_photo || false}
						isVerified={childData?.is_verified || false}
						onSubmit={handlePhotoSubmit}
						onSkip={handleSkipPhoto}
						isLoading={isSubmitting}
					/>
				)}
			</div>
		</div>
	);
}
