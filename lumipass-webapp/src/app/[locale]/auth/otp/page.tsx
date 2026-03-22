import AuthWrapper from "@/app/shared/auth-layout/auth-wrapper";
import OtpVerificationForm from "./otp-verification-form";

export default function OtpPage() {
  return (
    <AuthWrapper
      title={''}
      backgroundColor="bg-mainPurple"
    >
      <OtpVerificationForm />
    </AuthWrapper>
  );
}