'use client';

import { useState, useMemo } from 'react';
import { Loader } from 'rizzui';
import { generateTelegramCode } from '@/services/api';
import { Link } from '@/i18n/routing';
import {
	PiCaretRight,
	PiSignOutDuotone,
	PiBellRingingDuotone,
} from 'react-icons/pi';
import { profileMenuItems } from '@/config/constants';
import { useAuth } from '@/contexts/auth-context';
import toast from 'react-hot-toast';
import CustomModal from '@/components/ui/custom-modal';
import { useTranslations } from 'next-intl';

function buildTelegramUrl(code: string) {
	return `https://t.me/lumipassbot?start=${encodeURIComponent(code)}`;
}

export default function Profile() {
	const t = useTranslations('Profile.Overview');
	const [isLogoutModalOpen, setIsLogoutModalOpen] = useState(false);
	const [linking, setLinking] = useState(false);
	const { logout } = useAuth();

	const handleLogoutClick = () => setIsLogoutModalOpen(true);

	const handleLogout = () => {
		setIsLogoutModalOpen(false);
		logout();
		toast.success(t('Logout.ToastSuccess'));
	};

	const handleLinkTelegram = async () => {
		try {
			setLinking(true);
			const { data } = await generateTelegramCode();
			const url = buildTelegramUrl(data.code);
			window.open(url, '_blank', 'noopener,noreferrer');
		} catch {
			// console.error(e);
			toast.error(t('TgCodeGenerationError'));
		} finally {
			setLinking(false);
		}
	};

	const menuCopy = useMemo(
		() => ({
			'/profile/account': {
				title: t('Menu.AccountTitle'),
				desc: t('Menu.AccountDesc'),
			},
			'/profile/children': {
				title: t('Menu.ChildrenTitle'),
				desc: t('Menu.ChildrenDesc'),
			},
			'/wallet': {
				title: t('Menu.WalletTitle'),
				desc: t('Menu.WalletDesc'),
			},
			'/profile/attendance-history': {
				title: t('Menu.AttendanceTitle'),
				desc: t('Menu.AttendanceDesc'),
			},
			'/profile/faqs': {
				title: t('Menu.FaqsTitle'),
				desc: t('Menu.FaqsDesc'),
			},
		}),
		[t]
	);

	// if (isLoading) {
	// 	return (
	// 		<div className="flex min-h-screen flex-col pb-20">
	// 			<div className="p-6 pb-4">
	// 				<PageTitleSkeleton />
	// 			</div>
	// 			<div className="flex-1 px-4">
	// 				<ProfileMenuSkeleton rows={6} />
	// 			</div>
	// 		</div>
	// 	);
	// }

	return (
		<div className="flex min-h-screen flex-col pb-24">
			<div className="px-6 pb-2 pt-8">
				<h1 className="my-3 inline-flex rounded-2xl bg-white/75 px-4 py-2 font-balsamiqSans text-4xl font-bold text-textGray shadow-sm">
					{t('Title')}
				</h1>
			</div>

			<div className="flex-1 px-4">
				<div className="flex flex-col gap-y-4">
					{profileMenuItems.map((item, index) => {
						const labels = menuCopy[item.href as keyof typeof menuCopy];
						return (
							<Link href={item.href} key={index}>
								<div className="stagger-in flex items-center justify-between rounded-2xl border border-white/90 bg-white/90 px-4 py-4 shadow-[0_8px_20px_rgba(60,83,154,0.12)]">
									<div className="flex items-center">
										<div className="mr-4">{item.icon}</div>
										<div>
											<h3 className="text-base font-semibold text-textGray">
												{labels?.title ?? item.title}
											</h3>
											<p className="text-xs text-gray-400">
												{labels?.desc ?? item.description}
											</p>
										</div>
									</div>
									<PiCaretRight size={20} className="text-mainPurple/90" />
								</div>
							</Link>
						);
					})}

					{/* Link Telegram */}
					<button
						key="link-telegram"
						onClick={handleLinkTelegram}
						disabled={linking}
						className="stagger-in flex items-center justify-between rounded-2xl border border-white/90 bg-white/90 px-4 py-4 shadow-[0_8px_20px_rgba(60,83,154,0.12)]"
					>
						<div className="flex items-center">
							<div className="mr-4">
								<PiBellRingingDuotone size={32} className="text-mainPurple" />
							</div>
							<div className="text-left">
								<h3 className="text-base font-semibold text-textGray">
									{t('LinkTelegram.Title')}
								</h3>
								<p className="text-xs text-gray-400">
									{t('LinkTelegram.Desc')}
								</p>
							</div>
						</div>
						{linking ? (
							<Loader size="sm" color="primary" />
						) : (
							<PiCaretRight size={20} className="text-mainPurple" />
						)}
					</button>

					{/* Logout */}
					<button
						onClick={handleLogoutClick}
						className="stagger-in flex w-full items-center justify-between rounded-2xl border border-white/90 bg-white/90 p-4 shadow-[0_8px_20px_rgba(60,83,154,0.12)]"
					>
						<div className="flex items-center">
							<div className="mr-4">
								<PiSignOutDuotone size={32} className="text-mainPurple" />
							</div>
							<div>
								<h3 className="text-start text-base font-semibold text-textGray">
									{t('Logout.RowTitle')}
								</h3>
								<p className="text-sm text-gray-400">{t('Logout.RowDesc')}</p>
							</div>
						</div>
						<PiCaretRight size={20} className="text-mainPurple" />
					</button>
				</div>
			</div>

			<CustomModal
				isOpen={isLogoutModalOpen}
				onClose={() => setIsLogoutModalOpen(false)}
				title={t('Logout.ModalTitle')}
				description={t('Logout.ModalDesc')}
				secondaryAction={{
					label: t('Logout.Confirm'),
					onClick: handleLogout,
					variant: 'outline',
				}}
				primaryAction={{
					label: t('Logout.Cancel'),
					onClick: () => setIsLogoutModalOpen(false),
					variant: 'solid',
				}}
				size="sm"
			/>
		</div>
	);
}
