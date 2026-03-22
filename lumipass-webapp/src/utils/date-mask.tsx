// Format user input as DD.MM.YYYY
export function maskDateInput(value: string): string {
	// Remove all non-digits
	let digits = value.replace(/\D/g, '');

	// Limit to 8 digits (ddmmyyyy)
	if (digits.length > 8) digits = digits.slice(0, 8);

	// Add dots for formatting
	if (digits.length > 4) {
		return `${digits.slice(0, 2)}.${digits.slice(2, 4)}.${digits.slice(4)}`;
	} else if (digits.length > 2) {
		return `${digits.slice(0, 2)}.${digits.slice(2)}`;
	}
	return digits;
}

// Converts dd.mm.yyyy → yyyy-mm-dd
export function dateMaskToApi(value: string): string {
	const parts = value.split('.');
	if (parts.length === 3) {
		return `${parts[2]}-${parts[1]}-${parts[0]}`;
	}
	return '';
}

// Converts yyyy-mm-dd → dd.mm.yyyy
export function apiDateToMask(dateString: string): string {
	try {
		if (!dateString) return '';

		// For "YYYY-MM-DD" format
		const parts = dateString.split('-');
		if (parts.length === 3) {
			return `${parts[2]}.${parts[1]}.${parts[0]}`;
		}

		return dateString;
	} catch (error) {
		// console.error('Error converting API date to mask:', error);
		return dateString;
	}
}
