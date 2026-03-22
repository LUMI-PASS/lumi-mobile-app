/**
 * Formats a price by dividing by 100, rounding, and adding currency symbol
 * @param price - The price value in smallest currency unit
 * @returns Formatted price string with so'm currency
 */
export function formatPrice(price: number): string {
  return `${Math.round(price / 100).toLocaleString()}`;
}