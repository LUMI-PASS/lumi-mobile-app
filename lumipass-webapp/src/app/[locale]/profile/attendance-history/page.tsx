import { Metadata } from "next";
import { metaObject } from "@/config/site.config";
import AttendanceHistory from "@/app/shared/profile/attendance-history/attendance";

export const metadata: Metadata = {
  ...metaObject("Attendance"),
};

export default function AttendanceHistoryPage() {
  return <AttendanceHistory/>;
}