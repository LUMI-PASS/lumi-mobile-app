import { Metadata } from "next";
import { metaObject } from "@/config/site.config";
import HomeView from "@/app/shared/home/home-page";

export const metadata: Metadata = {
  ...metaObject("Home"),
};

export default function HomePage() {
  return <HomeView />;
}