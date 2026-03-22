import { differenceInYears } from "date-fns";

// Calculate age from date of birth
  export const calculateAge = (dob: string) => {
    try {
      const birthDate = new Date(dob);
      const today = new Date();
      return differenceInYears(today, birthDate);
    } catch (error) {
      return 0;
    }
  };