export function formatDuration(min?: number) {
	if (!min || min <= 0) return '—';
	const h = Math.floor(min / 60);
	const m = min % 60;
	if (h && m) return `${h}h ${m}m`;
	if (h) return `${h}h`;
	return `${m}m`;
}
