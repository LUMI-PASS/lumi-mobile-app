import { Toaster } from 'react-hot-toast';
import { AuthProvider } from '@/contexts/auth-context';
import GlobalDrawer from '@/app/shared/drawer-views/container';
import { JotaiProvider, ThemeProvider } from '@/app/shared/theme-provider';
import { siteConfig } from '@/config/site.config';
import AuthGuard from '@/utils/auth-guard';
import cn from '@/utils/class-names';
import NextProgress from '@/components/next-progress';
import { NextIntlClientProvider } from 'next-intl';
import { getMessages } from 'next-intl/server';
import { Nunito, Quicksand, Balsamiq_Sans } from 'next/font/google';
import { Metadata, Viewport } from 'next';
import ClientLayout from '@/layouts/client-layout';
import { initializeLocation } from '@/utils/location-cache';

if (typeof window !== 'undefined') {
	initializeLocation();
}

// styles
import './style/global.css';
import 'swiper/css';
import 'swiper/css/navigation';
import { NavbarProvider } from '@/contexts/navbar-context';
import YandexMetircsClient from '@/services/yandex-metrics-client';

// Font setup
const inter = Quicksand({
	subsets: ['latin'],
	variable: '--font-inter',
	display: 'swap',
});

const lexend = Nunito({
	subsets: ['latin'],
	variable: '--font-lexend',
	display: 'swap',
});

const balsamiqSans = Balsamiq_Sans({
	subsets: ['latin'],
	weight: ['400', '700'],
	variable: '--font-balsamiq-sans',
	display: 'swap',
});

const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000';

export const metadata: Metadata = {
	title: siteConfig.title,
	description: siteConfig.description,
	metadataBase: new URL(siteUrl),
	icons: { icon: '/favicon.ico' },
};
export const viewport: Viewport = {
	width: 'device-width',
	initialScale: 1,
	viewportFit: 'cover',
	maximumScale: 1,
	userScalable: false,
	colorScheme: 'light',
};

export default async function RootLayout({
	children,
	params,
}: {
	children: React.ReactNode;
	params: Promise<{ locale: string }>;
}) {
	const isProd = process.env.NODE_ENV === 'production';
	const { locale } = await params;
	const messages = await getMessages();
	return (
		<html
			lang={locale}
			dir="ltr"
			suppressHydrationWarning
			className="scroll-container"
		>
			<body
				suppressHydrationWarning
				className={cn(
					inter.variable,
					lexend.variable,
					balsamiqSans.variable,
					'bg-grayBg font-lexend text-textGray'
				)}
			>
				<NextIntlClientProvider locale={locale} messages={messages}>
					<AuthProvider>
						{isProd && <YandexMetircsClient />}
						<ThemeProvider>
							<NextProgress />
							<JotaiProvider>
								<NavbarProvider>
									<AuthGuard>
										<ClientLayout>{children}</ClientLayout>
									</AuthGuard>
								</NavbarProvider>
								<Toaster />
								<GlobalDrawer />
							</JotaiProvider>
						</ThemeProvider>
					</AuthProvider>
				</NextIntlClientProvider>
			</body>
		</html>
	);
}
