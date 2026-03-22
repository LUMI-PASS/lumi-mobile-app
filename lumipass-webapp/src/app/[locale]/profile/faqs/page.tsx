import { Metadata } from "next";
import { metaObject } from "@/config/site.config";
import Faqs from "@/app/shared/profile/faqs/faqs";

export const metadata: Metadata = {
  ...metaObject("Faqs"),
};

export default function FAQsPage() {
  return <Faqs/>;
}