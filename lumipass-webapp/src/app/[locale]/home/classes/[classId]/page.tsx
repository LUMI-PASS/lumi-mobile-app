import { Metadata } from "next";
import { metaObject } from "@/config/site.config";
import ClassDetails from "@/app/shared/home/classes/class-details";

export const metadata: Metadata = {
  ...metaObject("Details"),
};

export default function ExplorePage() {
  return <ClassDetails />;
}