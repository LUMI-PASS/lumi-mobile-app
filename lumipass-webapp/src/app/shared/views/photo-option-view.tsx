'use client';

import { useDrawer } from '@/app/shared/drawer-views/use-drawer';
import { Badge } from 'rizzui';
import { PiCamera, PiCameraDuotone, PiImage, PiImageDuotone, PiXBold } from 'react-icons/pi';
import cn from '@/utils/class-names';
import { useTranslations } from 'next-intl';

export default function PhotoPickerDrawerView({
	onPickFromGallery,
	onTakePhoto,
	title = 'Profile photo',
	chooseLabel = 'Choose from gallery',
	takeLabel = 'Take a photo',
	closeLabel = 'Close',
}: {
	onPickFromGallery: () => void;
	onTakePhoto: () => void;
	title?: string;
	chooseLabel?: string;
	takeLabel?: string;
	closeLabel?: string;
}) {
	const { closeDrawer } = useDrawer();
	const t = useTranslations('Drawers.Photo');
	const _title = title ?? t('Title');
	const _choose = chooseLabel ?? t('Choose');
	const _take = takeLabel ?? t('Take');
	const _close = closeLabel ?? t('Close');

	return (
		<div className="flex h-full flex-col gap-2 px-5 pb-10">
			<div className="relative flex items-center justify-between">
				<h3
					className={cn(
						'flex-1 text-center text-2xl font-semibold text-textGray'
					)}
				>
					{_title}
				</h3>
				<Badge
					onClick={closeDrawer}
					className="absolute bottom-0 right-0 top-0 cursor-pointer rounded-xl bg-gray-100 text-textGray"
					variant="flat"
					size="md"
				>
					{_close}
				</Badge>
			</div>

			<div className="my-auto space-y-3">
				<button
					type="button"
					onClick={() => {
						onPickFromGallery();
						closeDrawer();
					}}
					className={cn(
						'flex w-full items-center justify-between rounded-xl bg-white px-4 py-3 text-left ring-1 ring-black/5 transition',
						'focus:outline-none focus:ring-2 focus:ring-primary/40'
					)}
				>
					<span className="flex items-center gap-3">
						<PiImageDuotone className="size-5" />
						{_choose}
					</span>
					<PiXBold className="size-5 opacity-0" />
				</button>

				<button
					type="button"
					onClick={() => {
						onTakePhoto();
						closeDrawer();
					}}
					className={cn(
						'flex w-full items-center justify-between rounded-xl bg-white px-4 py-3 text-left ring-1 ring-black/5 transition',
						'focus:outline-none focus:ring-2 focus:ring-primary/40'
					)}
				>
					<span className="flex items-center gap-3">
						<PiCameraDuotone className="size-5" />
						{_take}
					</span>
					<PiXBold className="size-5 opacity-0" />
				</button>
			</div>
		</div>
	);
}
