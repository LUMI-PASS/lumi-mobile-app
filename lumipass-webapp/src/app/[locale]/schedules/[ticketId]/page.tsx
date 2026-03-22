import { Metadata } from 'next';
import { metaObject } from '@/config/site.config';
import TicketDetails from '@/app/shared/schedules/booking-details';

export const metadata: Metadata = {
	...metaObject('Ticket'),
};

export default function TicketDetailsPage() {
	return <TicketDetails />;
}
