
export function formatDistanceKm(distance?: number | null): string | null {
	if (distance == null || Number.isNaN(distance as number)) return null;
  if (distance <= 0) return 'nearby';
  
  const km = distance / 1000;
	return `${Math.round(km).toFixed(0)} km`;
}
