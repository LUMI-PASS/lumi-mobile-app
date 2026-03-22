'use client';

import React from 'react';
import cn from '@/utils/class-names';

interface CloseDrawerButtonProps {
  onClick: () => void;
  className?: string;
}

export default function CloseDrawerButton({
  onClick,
  className,
}: CloseDrawerButtonProps) {
  return (
    <button 
      onClick={onClick} 
      className={cn(
        "absolute bottom-0 right-0 top-0 grid size-9 place-content-center rounded-xl bg-mainPurple/10 text-mainPurple transition active:scale-95",
        className
      )}
      type="button"
      aria-label="Close drawer"
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="currentColor"
        stroke="currentColor"
        strokeWidth="0.7"
        className="h-4 w-4"
      >
        <path
          fillRule="evenodd"
          d="M5.47 5.47a.75.75 0 0 1 1.06 0L12 10.94l5.47-5.47a.75.75 0 1 1 1.06 1.06L13.06 12l5.47 5.47a.75.75 0 1 1-1.06 1.06L12 13.06l-5.47 5.47a.75.75 0 0 1-1.06-1.06L10.94 12 5.47 6.53a.75.75 0 0 1 0-1.06Z"
          clipRule="evenodd"
        />
      </svg>
    </button>
  );
}
