'use client';

import { Text, Button } from 'rizzui';
import { useAuth } from '@/contexts/auth-context';
import {
  PiSealCheckFill,
  PiTranslateDuotone,
  PiUserCircleFill,
} from 'react-icons/pi';
import { routes } from '@/config/routes';
import { useRouter } from '@/i18n/routing';
import { useTranslations } from 'next-intl';
import { useDrawer } from '@/app/shared/drawer-views/use-drawer';
import LanguageDrawerView from '@/app/shared/views/language-drawer-view';
import { useEffect, useState } from 'react';
import cn from '@/utils/class-names';

export default function Header() {
  const { isAuthenticated } = useAuth();
  const router = useRouter();
  const { openDrawer } = useDrawer();
  const t = useTranslations('Header');
  const [user, setUser] = useState<{ first_name: string }>({ first_name: '' });
  
  useEffect(() => {
    const userData = localStorage.getItem('user');
    if (userData) {
      try {
        const parsedUser = JSON.parse(userData);
        setUser(parsedUser);
      } catch {
        // console.error('Error parsing user data from localStorage:', error);
      }
    }
  }, []);

  const openLanguageDrawer = () => {
    openDrawer({
      view: <LanguageDrawerView />,
      placement: 'bottom',
      height: '40vh',
    });
  };

  return (
    <div className="w-full px-4 pb-2 pt-3">
      <div className="app-surface-soft flex items-center justify-between gap-3 px-3 py-2.5">
        <button
          type="button"
          className="flex min-w-0 items-center gap-2 rounded-2xl"
          onClick={() => router.push(routes.profile.base)}
        >
          <div className="relative grid size-11 place-content-center rounded-2xl bg-gradient-to-br from-mainPurple/20 to-mainPink/20 text-mainPurple">
            <PiUserCircleFill className="size-8" />
            {isAuthenticated && (
              <PiSealCheckFill className="absolute -right-0.5 -top-0.5 size-4 rounded-full bg-white text-mainPurple" />
            )}
          </div>
          <div className="flex min-w-0 flex-col items-start">
            <Text className="text-[11px] font-bold uppercase tracking-[0.08em] text-lightGray">
              {t('Hello')}
            </Text>
            <Text
              className={cn(
                'max-w-[140px] truncate text-left font-balsamiqSans text-lg leading-none text-textGray',
                !user.first_name && 'opacity-60'
              )}
            >
              {user.first_name || '...'}
            </Text>
          </div>
        </button>

        <div className="flex items-center justify-end gap-2">
          <Button
            variant="text"
            size="md"
            className="grid size-10 cursor-pointer place-content-center overflow-clip rounded-2xl bg-mainPink/15 p-0 text-mainPink transition-transform active:scale-95"
            onClick={openLanguageDrawer}
          >
            <PiTranslateDuotone className="size-5 text-inherit" />
          </Button>
        </div>
      </div>
    </div>
  );
}
