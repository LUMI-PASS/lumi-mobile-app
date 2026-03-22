'use client';
import { useEffect, useState } from 'react';
import ProfileHeader from '@/components/ui/page-header';
import { routes } from '@/config/routes';
import { Accordion } from 'rizzui';
import { PiCaretDownBold } from 'react-icons/pi';
import cn from '@/utils/class-names';
import { useTranslations } from 'next-intl';

// Only ids; messages live in JSON
const faqIds = ['1', '2', '3', '4', '5', '6', '7'] as const;

export default function Faqs() {
	const t = useTranslations('Profile.Faqs');
	const [isClient, setIsClient] = useState(false);

	useEffect(() => {
		setIsClient(true);
	}, []);

	// Show loading state during hydration
	if (!isClient) {
		return (
			<div className="flex min-h-screen flex-col bg-gray-50 pb-14">
				<ProfileHeader title="FAQs" href={routes.profile.base} />
				<div className="flex-1 px-6 py-8">
					<div className="space-y-4">
						{Array.from({ length: 7 }).map((_, index) => (
							<div
								key={index}
								className="h-16 animate-pulse rounded-r-2xl rounded-tl-2xl bg-gray-200"
							/>
						))}
					</div>
				</div>
			</div>
		);
	}

	return (
		<div className="flex min-h-screen flex-col bg-gray-50 pb-14">
			<ProfileHeader title={t('Title')} href={routes.profile.base} />
			<div className="flex-1 px-6 py-8">
				<div className="space-y-4">
					{faqIds.map((id) => {
						const q = t(`Items.${id}.Question`);
						const a = t(`Items.${id}.Answer`);

						return (
							<Accordion
								key={id}
								className="overflow-hidden rounded-r-2xl rounded-tl-2xl border border-gray-50"
							>
								<Accordion.Header>
									{({ open }: { open: boolean }) => (
										<div
											className={cn(
												'flex w-full cursor-pointer items-start justify-between rounded-r-2xl rounded-t-2xl px-4 py-5 transition-colors duration-200',
												open
													? 'bg-mainPurple text-white'
													: 'bg-white text-textGray'
											)}
										>
											<h4 className="flex-1 text-left text-sm font-semibold text-inherit">
												{q}
											</h4>
											<PiCaretDownBold
												className={cn(
													'ml-1 h-5 w-5 transition-transform',
													open && 'rotate-180'
												)}
											/>
										</div>
									)}
								</Accordion.Header>
								<Accordion.Body>
									<div className="rounded-b-2xl border-b bg-gradient-to-b from-transparent to-white border-lightGray/10 px-5 py-4 leading-relaxed text-gray-700">
										{a}
									</div>
								</Accordion.Body>
							</Accordion>
						);
					})}
				</div>
			</div>
		</div>
	);
}
