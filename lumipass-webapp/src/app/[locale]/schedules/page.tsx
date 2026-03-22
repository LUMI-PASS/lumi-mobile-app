import { Metadata } from "next";
import { metaObject } from "@/config/site.config";
import SchedulesPageContent from "@/app/shared/schedules/schedules-page";

export const metadata: Metadata = {
  ...metaObject("Schedules"),
};

export default function SchedulesPage() {
  return <SchedulesPageContent />;
}