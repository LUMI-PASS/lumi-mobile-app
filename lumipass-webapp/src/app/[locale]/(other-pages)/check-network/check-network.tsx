import React from 'react';
import { Button } from 'rizzui';
import { Empty, SearchNotFoundIcon } from 'rizzui/empty';
import { useTranslations } from 'next-intl';

export default function CheckNetwork() {
	const t = useTranslations('CheckNetwok');
	return (
		<div className="flex h-screen flex-col">
			<div className="flex flex-1 flex-col items-center justify-center px-6">
				<Empty image={<SearchNotFoundIcon className="h-44 w-auto" />} />
				<h2 className="mb-2 font-balsamiqSans text-2xl font-bold text-center text-textGray">
					{t('Title')}
				</h2>
				<p className="mb-8 text-center text-gray-500 text-xs" >
					{t('Description')}
				</p>
				<Button
					onClick={() => window.location.reload()}
					variant="outline"
					className="w-full rounded-2xl border-mainPurple bg-white px-8 py-6 text-mainPurple"
				>
					{t('Retry')}
				</Button>
			</div>
		</div>
	);
}
