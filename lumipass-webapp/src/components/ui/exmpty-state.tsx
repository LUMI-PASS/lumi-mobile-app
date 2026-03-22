import { PiMagnifyingGlass } from 'react-icons/pi';
interface EmptyStateProps {
  message: string;
  icon?: string;
  className?: string;
}

export default function EmptyState({ 
  message, 
  className = "" 
}: EmptyStateProps) {
  return (
    <div className={`app-surface-soft flex flex-col items-center justify-center p-8 text-center ${className}`}>
      <div className="mb-4 grid h-14 w-14 place-content-center rounded-2xl bg-mainPurple/10">
        <PiMagnifyingGlass className="h-7 w-7 text-mainPurple" />
      </div>
      <p className="max-w-[260px] text-sm font-medium text-gray-600">{message}</p>
    </div>
  );
}
