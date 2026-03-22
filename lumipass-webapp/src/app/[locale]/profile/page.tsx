import { Metadata } from "next";
import { metaObject } from "@/config/site.config";
import Profile from "@/app/shared/profile/profile";

export const metadata: Metadata = {
  ...metaObject("Profile"),
};

export default function ProfilePage() {
  return <Profile/>;
}