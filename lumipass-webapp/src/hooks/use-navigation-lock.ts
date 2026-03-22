'use client';

import { useEffect } from 'react';

export function useNavigationLock(locked: boolean) {
	useEffect(() => {
		if (!locked) return;

		try {
			history.pushState({ __lock: Date.now() }, '', location.href);
		} catch {}

		const onPopState = () => {
			history.go(1);
		};

		const onBeforeUnload = (e: BeforeUnloadEvent) => {
			e.preventDefault();
			e.returnValue = '';
		};

		window.addEventListener('popstate', onPopState);
		window.addEventListener('beforeunload', onBeforeUnload);
		return () => {
			window.removeEventListener('popstate', onPopState);
			window.removeEventListener('beforeunload', onBeforeUnload);
		};
	}, [locked]);
}
