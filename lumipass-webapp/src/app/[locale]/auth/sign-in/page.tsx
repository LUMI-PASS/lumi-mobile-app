import { Metadata } from 'next';
import PhoneEntryForm from './sign-in-form';
import AuthWrapper from '@/app/shared/auth-layout/auth-wrapper';
import { metaObject } from '@/config/site.config';
import { getTranslations } from 'next-intl/server';

export const metadata: Metadata = {
	...metaObject('Sign In'),
};

export default async function SignIn() {
	const t = await getTranslations('Auth');
	return (
		<AuthWrapper
			title={
				<div className="font-balsamiqSans font-bold text-3xl leading-[1.1] text-textGray">
					{t('LoginTo')} <br />
					{t('YourAccount')}
				</div>
			}
		>
			<PhoneEntryForm />
		</AuthWrapper>
	);
}
