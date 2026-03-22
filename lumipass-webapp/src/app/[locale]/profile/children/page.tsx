import { Metadata } from "next";
import { metaObject } from "@/config/site.config";
import MyChildren from "@/app/shared/profile/children/children";

export const metadata: Metadata = {
  ...metaObject("My Children"),
};

export default function MyChildrenPage() {
  return <MyChildren/>;
}