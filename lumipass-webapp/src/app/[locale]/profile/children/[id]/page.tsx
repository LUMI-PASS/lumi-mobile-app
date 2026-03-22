import { Metadata } from 'next';
import { metaObject } from '@/config/site.config';
import EditChild from '@/app/shared/profile/children/edit-child/edit-child-content';

export async function generateMetadata(): Promise<Metadata> {
	return metaObject(`Edit Child`);
}

export default async function EditChildPage() {
	return <EditChild />;
}
