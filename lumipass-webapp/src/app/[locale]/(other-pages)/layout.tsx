'use client';

import Image from 'next/image';
import { Button } from 'rizzui';
import cn from '@/utils/class-names';
import { Link, usePathname, useRouter } from '@/i18n/routing';
import { siteConfig } from '@/config/site.config';
import { routes } from '@/config/routes';

const ignoreBackButtonRoutes = [routes.accessDenied, routes.notFound];

export default function OtherPagesLayout({
	children,
}: {
	children: React.ReactNode;
}) {
	const { back } = useRouter();
	const pathName = usePathname();
	const notIn = !ignoreBackButtonRoutes.includes(pathName);
	return (
		<div className="flex min-h-screen flex-col overflow-auto bg-[#F8FAFC] dark:bg-gray-50">
			{/* sticky top header  */}
			<div className="sticky top-0 z-40 px-6 py-2 backdrop-blur-lg lg:backdrop-blur-none xl:px-10 xl:py-8">
				<div
					className={cn(
						'mx-auto flex items-center',
						notIn ? 'justify-between' : 'justify-center'
					)}
				>
					{notIn && (
						<Link href={'/'}>
							<Image
								src={siteConfig.logo}
								alt={siteConfig.title}
								className="h-16 w-32 dark:invert"
								priority
							/>
						</Link>
					)}
					{notIn && (
						<Button
							variant="outline"
							size="sm"
							className="md:h-10 md:px-4 md:text-base"
							onClick={() => back()}
						>
							Go back
						</Button>
					)}
				</div>
			</div>
			{children}
		</div>
	);
}
