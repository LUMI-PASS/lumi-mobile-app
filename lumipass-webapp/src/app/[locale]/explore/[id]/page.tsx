import { Metadata } from "next";
import { metaObject } from "@/config/site.config";
import BranchDetails from "@/app/shared/explore/branch-details";

export const metadata: Metadata = {
  ...metaObject("Branch Details"),
};

export default function ExplorePage() {
  return (
    <BranchDetails/>
  );
}