'use client';

import { Input, Text } from 'rizzui';
import cn from '@/utils/class-names';
import React, { useState, useEffect } from 'react';
import RangeSlider from '@/components/ui/range-slider';

interface RangeProps {
	title: string;
	min: number;
	max: number;
	initialMin: number;
	initialMax: number;
	onChange?: (value: [number, number]) => void;
}

export default function RangeCard(props: RangeProps) {
	const { title, min, max, initialMin, initialMax, onChange } = props;

	const [state, setState] = useState({
		min: initialMin,
		max: initialMax,
	});

	// Update when props change
	useEffect(() => {
		setState({
			min: initialMin,
			max: initialMax,
		});
	}, [initialMin, initialMax]);

	function handleRangeChange(value: any) {
		const newState = {
			min: value[0],
			max: value[1],
		};
		setState(newState);

		if (onChange) {
			onChange([newState.min, newState.max]);
		}
	}


	return (
		<div className="rounded-[10px] border border-gray-100 px-3 py-5 sm:p-5">
			<RangeSlider
				range
				min={min}
				max={max}
				value={[state.min, state.max]}
				onChange={(value: any) => handleRangeChange(value)}
				className={cn('[&>.rc-slider-step]:hidden')}
			/>
			<div className="mt-4 flex justify-between">
				<div className="flex items-center">
					<span className="mr-1 font-medium text-yellow-600 text-lg">{state.min}</span>
					<img src="/icons/coin.svg" alt="Lumi Coin" className="h-7 w-7" />
				</div>
				<div className="flex items-center ">
					<span className="mr-1 font-medium text-yellow-600 text-lg">{state.max}</span>
					<img src="/icons/coin.svg" alt="Lumi Coin" className="h-7 w-7" />
				</div>
			</div>
		</div>
	);
}
