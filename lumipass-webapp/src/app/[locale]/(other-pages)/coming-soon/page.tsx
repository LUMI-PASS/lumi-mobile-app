import Image from 'next/image';
import { Title } from 'rizzui/typography';
import CountdownTimer from '@/app/[locale]/(other-pages)/coming-soon/countdown-timer';
import { PiPlusBold } from 'react-icons/pi';
import ComingSoonImg from '@public/coming-soon.png';
import ComingSoonTwoImg from '@public/coming-soon-2.png';

export default function ComingSoonPage() {
	return (
		<div className="relative flex grow flex-col-reverse items-center justify-center gap-y-4 px-6 lg:flex-row lg:pt-0 xl:px-10">
			<div className="z-10 mx-auto w-full  text-center lg:text-start">
				<Title
					as="h1"
					className="mb-3 text-xl font-bold text-textGray md:mb-5 md:text-3xl md:leading-snug xl:text-4xl xl:leading-normal 2xl:text-5xl 2xl:leading-normal"
				>
					Our website is developing. Keep{' '}
					<br className="hidden sm:inline-block" /> patience, we are coming soon
				</Title>
				<p className="mb-6 text-sm leading-loose text-gray-500 md:mb-8 xl:mb-10 xl:text-base xl:leading-loose">
          We have been spending long hours in order to launch our new web-app.

				</p>
				<div className="flex justify-center lg:justify-start">
					<CountdownTimer />
				</div>
			</div>

			<Image
				src={ComingSoonTwoImg}
				alt="coming soon"
				className="fixed start-0 top-0 hidden w-28 dark:invert 3xl:inline-block 3xl:w-32 rtl:rotate-90"
			/>
			<div className="end-10 top-1/2 lg:absolute lg:-translate-y-1/2 xl:end-[10%] 3xl:end-[15%]">
				<Image
					src={ComingSoonImg}
					alt="coming-soon"
					className="aspect-[531/721] max-w-[194px] md:max-w-[256px] lg:max-w-sm xl:max-w-[400px] 3xl:max-w-[531px]"
				/>
			</div>
		</div>
	);
}