/* eslint-disable @typescript-eslint/no-empty-object-type */
"use client";

import { Provider } from "jotai";
import { siteConfig } from "@/config/site.config";
import { ThemeProvider as NextThemeProvider } from "next-themes";

export function ThemeProvider({ children }: React.PropsWithChildren<{}>) {
  return (
    <NextThemeProvider
      enableSystem={false}
      themes={["light", "dark"]}
      defaultTheme={String(siteConfig.mode)}
      forcedTheme="light"
    >
      {children}
    </NextThemeProvider>
  );
}

export function JotaiProvider({ children }: React.PropsWithChildren<{}>) {
  return <Provider>{children}</Provider>;
}
