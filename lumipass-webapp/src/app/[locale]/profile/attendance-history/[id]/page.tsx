import { Metadata } from 'next';
import { metaObject } from '@/config/site.config';
import AttendanceDetails from '@/app/shared/profile/attendance-history/attendance-details';

export const metadata: Metadata = {
	...metaObject('Attendance Details'),
};

export default function AttendanceHistoryPage() {
	return <AttendanceDetails />;
}
