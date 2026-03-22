// format-datetime.ts
import { format, parse, parseISO } from 'date-fns';

type FormatType = 'date' | 'time';

/**
 * Formats a date/time or a range.
 * Auto-detects if passed value is time-only, date-only, or full ISO datetime.
 * @param start e.g. "2025-08-13T10:00:00" OR "10:00" OR "2025-08-13"
 * @param second Optional second date/time string for a range
 * @param type "date" or "time"
 */
export function formatDateTime(
	start: string,
	second?: string | FormatType,
	type?: FormatType
): string {
	try {
		// RANGE MODE: 3 arguments (start, end, type)
		if (second && type) {
			const end = second;
			return `${formatSingle(start, type)} - ${formatSingle(end, type)}`;
		}

		// SINGLE MODE: 2 arguments (value, type)
		if (typeof second === 'string') {
			return formatSingle(start, second as FormatType);
		}

		return '';
	} catch (error) {
		// console.error('Error formatting datetime:', error);
		return type === 'date' ? 'Invalid date' : 'Invalid time';
	}
}

/**
 * Formats a single value based on whether it's date or time.
 */
function formatSingle(value: string, type: FormatType): string {
  if (!value) return type === 'date' ? 'Invalid date' : 'Invalid time';

  let date: Date;

  // Detect time-only string "HH:mm"
  if (/^\d{2}:\d{2}$/.test(value)) {
    date = parse(value, 'HH:mm', new Date());
  }
  // Detect date-only string "YYYY-MM-DD"
  else if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    date = parseISO(value);
  }
  // Assume full ISO datetime
  else {
    date = parseISO(value);
  }

  if (isNaN(date.getTime()))
    return type === 'date' ? 'Invalid date' : 'Invalid time';

  if (type === 'date') {
    return format(date, 'd MMMM yyyy'); // e.g. "13 August 2025"
  } else {
    return format(date, 'HH:mm'); // e.g. "16:53"
  }
}
