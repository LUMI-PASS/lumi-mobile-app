import { Metadata } from "next";
import { metaObject } from "@/config/site.config";
import MyAccountDetails from "@/app/shared/profile/account/my-account";

export const metadata: Metadata = {
  ...metaObject("Account"),
};

export default function AccountPage() {
  return <MyAccountDetails/>;
}