import { Metadata } from "next";
import { metaObject } from "@/config/site.config";
import ExplorePageContent from '@/app/shared/explore/explore-page';

export const metadata: Metadata = {
  ...metaObject("Explore"),
};

export default function ExplorePage() {
  return <ExplorePageContent />;
}