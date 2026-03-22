import type { NextConfig } from "next";
import createNextIntlPlugin from "next-intl/plugin";

const withNextIntl = createNextIntlPlugin();

const nextConfig: NextConfig = {
  images: {
    unoptimized: true,
    remotePatterns: [
      {
        protocol: "https",
        hostname: "devapp.lumipass.uz",
        pathname: "/api/v1/assets/files/**",
      },
      {
        protocol: "https",
        hostname: "dev-api.lumipass.uz",
        pathname: "/api/v1/assets/files/**",
      },
      {
        protocol: "https",
        hostname: "app.lumipass.uz",
        pathname: "/api/v1/assets/files/**",
      },
    ],
  },
  reactStrictMode: true,
};

export default withNextIntl(nextConfig);
