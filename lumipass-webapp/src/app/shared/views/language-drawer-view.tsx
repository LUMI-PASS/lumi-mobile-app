'use client';

import Image from 'next/image';
import { useMemo } from 'react';
import { PiCheckBold } from 'react-icons/pi';
import { useDrawer } from '@/app/shared/drawer-views/use-drawer';
import { useLocale } from 'next-intl';
import { usePathname, useRouter } from '@/i18n/routing';
import { useSearchParams } from 'next/navigation';
import cn from '@/utils/class-names';
import CloseDrawerButton from '@/components/ui/buttons/close-drawer-button';
import { LangCode } from '@/types';
import { LANGUAGES } from '@/config/constants';
import { useTranslations } from 'next-intl';

export default function LanguageDrawerView() {
	const { closeDrawer } = useDrawer();
	const locale = useLocale() as LangCode;
	const router = useRouter();
	const pathname = usePathname();
	const searchParams = useSearchParams();
	const t = useTranslations('Language');

	const currentLang = LANGUAGES.find((l) => l.code === locale)?.code ?? 'en';
	const hrefWithQuery = useMemo(() => {
		const qs = searchParams?.toString() ?? '';
		return `${pathname}${qs ? `?${qs}` : ''}`;
	}, [pathname, searchParams]);

	const selectLanguage = (code: LangCode) => {
		if (code === currentLang) {
			return closeDrawer();
		}
		closeDrawer();
		setTimeout(() => {
			router.replace(hrefWithQuery, { locale: code });
		}, 350);
	};

	return (
		<div className="flex h-full flex-col px-5 pb-3">
			{/* Header (match your drawer header look) */}
			<div className="relative flex items-center justify-center">
				<h2 className="font-balsamiqSans text-2xl text-textGray">
					{t('Title')}
				</h2>
				<div className="absolute bottom-0 right-0 top-0">
					<CloseDrawerButton onClick={closeDrawer} />
				</div>
			</div>

			{/* List */}
			<div className="flex-1 overflow-y-auto px-1 py-4">
				<div className="space-y-3">
					{LANGUAGES.map((lang) => {
						const active = lang.code === currentLang;
						return (
							<button
								key={lang.code}
								onClick={() => selectLanguage(lang.code)}
								className={cn(
									'flex w-full items-center justify-between rounded-2xl border border-white/90 bg-white/90 p-4 shadow-[0_8px_20px_rgba(60,83,154,0.12)] transition',
									'hover:bg-gray-50 active:scale-[0.99]',
									active && 'ring-2 ring-mainPurple/35'
								)}
							>
								<div className="flex items-center gap-3">
									<div className="relative h-5 w-7 overflow-hidden rounded">
										<Image
											src={lang.flag}
											alt={lang.label}
											fill
											className="object-cover"
										/>
									</div>
									<span className="text-sm font-semibold text-textGray">
										{lang.label}
									</span>
								</div>
								<PiCheckBold
									className={cn(
										'h-5 w-5',
										active ? 'text-mainPurple' : 'invisible'
									)}
								/>
							</button>
						);
					})}
				</div>
			</div>
		</div>
	);
}
