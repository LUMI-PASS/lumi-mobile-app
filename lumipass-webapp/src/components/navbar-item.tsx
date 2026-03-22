import React, { memo } from "react";
import { NAV_COLOR_ACTIVE, NAV_COLOR_INACTIVE } from "@/config/constants";
import { Button } from "rizzui/button";
import cn from "@/utils/class-names";

export interface NavbarItemProps {
  active?: boolean;
  children: React.ReactNode;
  className?: string;
  "aria-label"?: string;
}

// Using memo to prevent re-rendering when props don't change
export const NavbarItem = memo(function NavbarItem({
  active = false,
  children,
  className = "",
  ...props
}: NavbarItemProps) {
  return (
    <Button
      as="button"
      variant="text"
      type="button"
      className={cn(
        "group relative flex size-11 items-center justify-center rounded-2xl p-0 focus:outline-none transition-all duration-200",
        active ? "bg-mainPurple/15 shadow-[0_8px_16px_rgba(166,82,199,0.2)]" : "hover:bg-mainPurple/10",
        className
      )}
      style={{
        color: active ? NAV_COLOR_ACTIVE : NAV_COLOR_INACTIVE,
      }}
      {...props}
    >
      <span className={cn("transition-transform duration-200", active ? "scale-[1.06]" : "scale-100")}>
        {children}
      </span>
      <span
        className={cn(
          "absolute -bottom-1 h-1.5 w-1.5 rounded-full bg-mainPurple transition-opacity duration-200",
          active ? "opacity-100" : "opacity-0"
        )}
      />
    </Button>
  );
});
