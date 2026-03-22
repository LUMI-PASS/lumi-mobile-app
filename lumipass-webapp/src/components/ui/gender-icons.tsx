import * as React from 'react';

type IconProps = {
	size?: number | string;
	className?: string;
	title?: string;
};

export function BoyIcon({
	size = 64,
	className,
	title = 'Boy',
	...rest
}: IconProps) {
	return (
		<img
			src="/icons/genders/boy.svg"
			alt={title}
			width={size}
			height={size}
			className={className}
			{...rest}
		/>
	);
}

export function GirlIcon({
	size = 64,
	className,
	title = 'Girl',
	...rest
}: IconProps) {
	return (
		<img
			src="/icons/genders/girl.svg"
			alt={title}
			width={size}
			height={size}
			className={className}
			{...rest}
		/>
	);
}

export function BothIcon({
	size = 64,
	className,
	title = 'Boy & Girl',
	...rest
}: IconProps) {
	return (
		<div className={className} {...rest}>
			<img
				src="/icons/genders/both.svg"
				alt="Girl"
				width={size}
				height={size}
				className="inline-block"
			/>
		</div>
	);
}
