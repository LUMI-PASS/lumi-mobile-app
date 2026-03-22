import { Metadata } from 'next';
import SignUpForm from './sign-up-form';
import AuthWrapper from '@/app/shared/auth-layout/auth-wrapper';
import { metaObject } from '@/config/site.config';
import { getTranslations } from 'next-intl/server';

export const metadata: Metadata = {
	...metaObject('Sign Up'),
};

export default async function SignUp() {
	const t = await getTranslations('Auth');
	return (
		<AuthWrapper
			title={
				<div className="font-balsamiqSans text-3xl font-bold leading-[1.1] text-textGray">
					{t('CreateAccountLine1')}
					<br />
					{t('CreateAccountLine2')}
				</div>
			}
			backgroundColor="bg-grayBg"
		>
			<SignUpForm />
		</AuthWrapper>
	);
}
