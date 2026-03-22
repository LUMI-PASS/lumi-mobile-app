'use client';

import { useState, useEffect } from 'react';
import { useRouter } from '@/i18n/routing';
import { Stepper } from 'rizzui';
import ProfileHeader from '@/components/ui/page-header';
import { routes } from '@/config/routes';
import { toast } from 'react-hot-toast';
import AddChildForm from '../forms/add-child-form';
import AddChildPhoto from '../forms/add-child-photo';
import { PiUserCircleDuotone, PiCameraDuotone } from 'react-icons/pi';
import { addNewChild, getParentProfile, uploadChildPhoto } from '@/services/api';
import { useTranslations } from 'next-intl';
import { useAuth } from '@/contexts/auth-context';

export default function AddChildPage() {
	const router = useRouter();
	const [currentStep, setCurrentStep] = useState(0);
	const [childId, setChildId] = useState<string | null>(null);
	const [isLoading, setIsLoading] = useState(false);
	const [parentLocation, setParentLocation] = useState({
		city: 'Tashkent',
		district: '',
	});
	const t = useTranslations('Profile.Children');
	const { user } = useAuth();

	useEffect(() => {
		setParentLocation({
			city: user?.city || 'Tashkent',
			district: user?.district || '',
		});

		const fetchParentLocation = async () => {
			try {
				const response = await getParentProfile();
				const profile = response?.data?.profile;
				if (!profile) return;
				setParentLocation({
					city: profile.city || user?.city || 'Tashkent',
					district: profile.district || user?.district || '',
				});
			} catch {
				// keep auth-context fallback
			}
		};

		void fetchParentLocation();
	}, [user?.city, user?.district]);

	// Step 1 submission handler
	const handleFormSubmit = async (formData: any) => {
		setIsLoading(true);
		try {
			const payload = {
				...formData,
				city: parentLocation.city || user?.city || 'Tashkent',
				district: parentLocation.district || user?.district || '',
			};
			const response = await addNewChild(payload);
			setChildId(response.data.id);
			toast.success(t('Add.AddSuccess'));
			setCurrentStep(1);
		} catch (error: any) {
			toast.error(t('Add.FailedToAdd'));
		} finally {
			setIsLoading(false);
		}
	};

	// Step 2 submission handler
	const handlePhotoSubmit = async (photo: File) => {
		if (!childId) {
			toast.error(t('ChildIdMissing'));
			return;
		}
		setIsLoading(true);
		try {
				await uploadChildPhoto(childId, photo);
				setTimeout(() => {
					router.push(routes.profile.myChildren);
				}, 600);
		} catch (error: any) {
			toast.error(t('Photo.AddFail'));
		} finally {
			setIsLoading(false);
		}
	};

	// Cancel handler
	const handleCancel = () => {
		router.push(routes.profile.myChildren);
	};

	return (
		<div className="flex min-h-screen flex-col pb-20">
			<ProfileHeader
				isRequiredPage={true}
				title={t('Add.Title')}
				href={routes.profile.myChildren}
			/>

			{/* Stepper */}
			<div className="p-6">
				<Stepper currentIndex={currentStep} className="w-full">
					<Stepper.Step
						variant="outline"
						title={t('Add.Stepper.Info')}
						icon={<PiUserCircleDuotone className="h-5 w-5" />}
					/>
					<Stepper.Step
						variant="outline"
						title={t('Add.Stepper.Photo')}
						icon={<PiCameraDuotone className="h-5 w-5" />}
					/>
				</Stepper>
			</div>

			{/* Step content */}
			<div className="flex-1">
				{currentStep === 0 && (
					<AddChildForm
						onSubmit={handleFormSubmit}
						isLoading={isLoading}
						parentCity={parentLocation.city}
						parentDistrict={parentLocation.district}
					/>
				)}

					{currentStep === 1 && (
						<AddChildPhoto
							onSubmit={handlePhotoSubmit}
							onCancel={handleCancel}
							isLoading={isLoading}
						/>
					)}
			</div>
		</div>
	);
}
