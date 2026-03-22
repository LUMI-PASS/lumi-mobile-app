import { Metadata } from 'next';
import { metaObject } from '@/config/site.config';
import WalletView from '@/app/shared/wallet/wallet';

export const metadata: Metadata = {
	...metaObject('Wallet'),
};

export default function WalletPage() {
	return <WalletView />;
}
