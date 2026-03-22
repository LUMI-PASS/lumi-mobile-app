export const reasonToCommonKey = (raw?: string) => {
	const key = (raw || '').trim().toLowerCase();
	switch (key) {
		case 'child is young':
			return 'childIsYoung';
		case 'child is old':
			return 'childIsOld';
		case 'child gender mismatch':
			return 'childGenderMismatch';
		case 'child has no photo':
			return 'childHasNoPhoto';
		default:
			return 'unknownReason';
	}
};
