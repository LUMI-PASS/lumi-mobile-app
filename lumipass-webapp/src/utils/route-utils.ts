import { routes } from "@/config/routes";
const publicAuthRoutes = [
  routes.auth.signIn,
  routes.auth.signUp,
  routes.auth.otp,
  '/access-denied'
];

export const isAuthRoute = (pathname: string | null): boolean => {
  if (!pathname) return false;
  return publicAuthRoutes.some(route => pathname.includes(route));
};
