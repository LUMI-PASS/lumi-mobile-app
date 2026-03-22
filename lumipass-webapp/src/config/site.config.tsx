import { Metadata } from "next";
import logo from "@public/logo.png";
import { OpenGraph } from "next/dist/lib/metadata/types/opengraph-types";

enum MODE {
  DARK = "dark",
  LIGHT = "light",
}

export const siteConfig = {
  title: "LumiPass",
  description: `LumiPass - Farzandingiz uchun eng yaxshi ta'lim platformasi.`,
  logo: logo,
  icon: logo,
  mode: MODE.LIGHT,
};

export const metaObject = (
  title?: string,
  openGraph?: OpenGraph,
  description: string = siteConfig.description
): Metadata => {
  return {
    title: title
      ? `${title} - LumiPass`
      : siteConfig.title,
    description,
    openGraph: openGraph ?? {
      title: title ? `${title} - LumiPass` : title,
      description,
      url: "https://app.lumipass.uz/",
      siteName: "LumiPass - Farzandingiz uchun eng yaxshi ta'lim platformasi",
      images: {
        url: "/logo.png",
        alt: "LumiPass Logo",
        width: 1200,
        height: 630,
      },
      locale: "en_US",
      type: "website",
    },
  };
};
