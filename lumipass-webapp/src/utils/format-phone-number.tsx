export const UZ_PREFIX = '+998 ';
const LOCAL_DIGITS_MAX = 9; // after "998" → (xx) xxx xx xx

/** Backward-compatible display: +998 (93) 165 65 10 (partial allowed) */
export function formatPhoneForDisplay(phone: string): string {
	if (!phone) return UZ_PREFIX;

	const digits = phone.replace(/\D/g, '');
	const normalized = digits.startsWith('998') ? digits : `998${digits}`;
	const local = normalized.slice(3, 12); // max 9 local digits

	const a = local.slice(0, 2); // area
	const b = local.slice(2, 5); // first block
	const c = local.slice(5, 7); // second block
	const d = local.slice(7, 9); // third block

	let formatted = UZ_PREFIX;
	if (!a) return formatted;

	formatted += `(${a})`;
	if (b) formatted += ` ${b}`;
	if (c) formatted += ` ${c}`;
	if (d) formatted += ` ${d}`;
	return formatted;
}

/** For API/E.164: +998XXXXXXXXX */
export function toE164Uz(input: string): string {
	const digits = input.replace(/\D/g, '');
	if (digits.startsWith('998')) return `+${digits.slice(0, 12)}`;
	return `+998${digits.slice(0, LOCAL_DIGITS_MAX)}`;
}

/** True when all 9 local digits are present */
export function isCompleteUzPhone(input: string): boolean {
	const digits = input.replace(/\D/g, '');
	const local = digits.startsWith('998') ? digits.slice(3) : digits;
	return local.length === LOCAL_DIGITS_MAX;
}

/**
 * Masking with caret preservation for onChange.
 * @param raw current input value
 * @param caret current selectionStart
 * @returns { value, caret }
 */
export function maskUzPhoneInput(
	raw: string,
	caret: number
): { value: string; caret: number } {
	// collect digits + how many before caret
	const ds: { ch: string; i: number }[] = [];
	for (let i = 0; i < raw.length; i++)
		if (/\d/.test(raw[i])) ds.push({ ch: raw[i], i });
	const digitsBeforeCaret = ds.filter((d) => d.i < caret).length;

	const all = ds.map((d) => d.ch).join('');
	const isUz = all.startsWith('998');
	const localAll = (isUz ? all.slice(3) : all).slice(0, LOCAL_DIGITS_MAX);

	// how many LOCAL digits were before the caret
	const localBeforeCaret = Math.max(
		0,
		digitsBeforeCaret - (isUz ? Math.min(3, digitsBeforeCaret) : 0)
	);

	// rebuild formatted string and map caret to same local-digit index
	let value = UZ_PREFIX;
	let emitted = 0;
	let mappedCaret = UZ_PREFIX.length;

	const push = (ch: string) => {
		if (emitted === 0) value += '(';
		if (emitted === 2) value += ') ';
		if (emitted === 5 || emitted === 7) value += ' ';
		value += ch;
		emitted++;
		if (emitted === localBeforeCaret) mappedCaret = value.length;
	};

	for (let i = 0; i < localAll.length; i++) push(localAll[i]);
	if (localBeforeCaret >= emitted) mappedCaret = value.length;

	return { value, caret: mappedCaret };
}
