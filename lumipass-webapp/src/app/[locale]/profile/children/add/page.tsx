import { Metadata } from 'next';
import { metaObject } from '@/config/site.config';
import AddChild from '@/app/shared/profile/children/add-child/add-child-content';

export const metadata: Metadata = {
	...metaObject('Add Child'),
};

export default function AddChildPage() {
	return <AddChild />;
}
