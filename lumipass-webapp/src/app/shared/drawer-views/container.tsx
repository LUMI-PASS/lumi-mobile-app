'use client';

import { useEffect, useRef, useState } from 'react';
import { usePathname } from '@/i18n/routing';
import { useDrawer } from '@/app/shared/drawer-views/use-drawer';
import cn from '@/utils/class-names';
import { AnimatePresence, motion } from 'framer-motion';

export default function GlobalDrawer() {
	const { drawer, closeDrawer } = useDrawer();
	const pathname = usePathname();
	const [isVisible, setIsVisible] = useState(false);

	// --- scroll lock state ---
	const scrollYRef = useRef<number>(0);
	const lockedRef = useRef(false);

	// --- sizing / drag state ---
	const [sheetHeight, setSheetHeight] = useState<number | null>(null);
	const [animateHeight, setAnimateHeight] = useState(false);

	const dragStartYRef = useRef(0);
	const dragStartHeightRef = useRef(0);
	const isDraggingRef = useRef(false);

	const lastMoveYRef = useRef(0);
	const lastMoveTRef = useRef(0);

	// The scrollable area inside the drawer
	const scrollAreaRef = useRef<HTMLDivElement>(null);

	// tuning
	const DEFAULT_VH = 0.7;
	const MIN_VH = 0.25;
	const MAX_VH = 0.97; // expand-to-top target
	const MID_VH = 0.6;
	const CLOSE_SNAP_VH = 0.33; // if released below this without velocity, close

	// velocity thresholds (px/ms); ~1500 px/s
	const V_CLOSE = 1.5;
	const V_EXPAND = -1.5;

	const parseHeightToPx = (h?: string | number | null) => {
		const vh = typeof window !== 'undefined' ? window.innerHeight : 0;
		if (h == null) return Math.round(vh * DEFAULT_VH);
		if (typeof h === 'number') return h;
		const v = h.trim().toLowerCase();
		if (v.endsWith('vh')) return Math.round((parseFloat(v) / 100) * vh);
		if (v.endsWith('px')) return Math.round(parseFloat(v));
		const n = Number(v);
		return Number.isFinite(n) ? Math.round(n) : Math.round(vh * DEFAULT_VH);
	};

	const clampHeight = (px: number) => {
		const vh = typeof window !== 'undefined' ? window.innerHeight : 0;
		const minH = Math.round(vh * MIN_VH);
		const maxH = Math.round(vh * MAX_VH);
		return Math.max(minH, Math.min(maxH, px));
	};

	const vhToPx = (vh: number) =>
		typeof window !== 'undefined' ? Math.round(window.innerHeight * vh) : 0;

	// ---------------- effects ----------------

	// Close drawer on route change
	useEffect(() => {
		if (drawer?.isOpen) closeDrawer();
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [pathname]);

	useEffect(() => {
		if (!drawer) return;
		if (drawer.isOpen) {
			setIsVisible(true);
			lockBody();
		}
		return () => {
			if (lockedRef.current) unlockBody();
		};
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [drawer?.isOpen]);

	// Safety net: if drawer state is cleared unexpectedly, always release scroll lock.
	useEffect(() => {
		if (!drawer && lockedRef.current) {
			unlockBody();
		}
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [drawer]);

	// Recompute height + keep within clamps on resize
	useEffect(() => {
		if (!drawer?.isOpen) {
			setSheetHeight(null);
			return;
		}
		const initial = clampHeight(parseHeightToPx(drawer.height ?? '75vh'));
		setSheetHeight(initial);
		const onResize = () => {
			setSheetHeight((h) => (h == null ? h : clampHeight(h)));
		};
		window.addEventListener('resize', onResize);
		return () => window.removeEventListener('resize', onResize);
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [drawer?.isOpen, drawer?.height]);

	// global cleanup for drag
	useEffect(() => {
		return () => {
			window.removeEventListener('pointermove', onHandlePointerMove);
			window.removeEventListener('pointerup', endDrag);
			window.removeEventListener('pointercancel', endDrag);
			document.body.style.cursor = '';
		};
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	// When open, block background scroll while allowing inner scroll
	useEffect(() => {
		if (!drawer?.isOpen) return;

		const allowInsideOnly = (e: Event) => {
			// If event target is NOT inside the drawer's scroll area, block it
			const scrollEl = scrollAreaRef.current;
			if (!scrollEl) {
				e.preventDefault();
				return;
			}
			const target = e.target as Node | null;
			if (!target || !scrollEl.contains(target)) {
				e.preventDefault();
			}
		};

		// Prevent background scroll on desktop wheel & touch screens
		document.addEventListener('wheel', allowInsideOnly, { passive: false });
		document.addEventListener('touchmove', allowInsideOnly, { passive: false });

		return () => {
			document.removeEventListener('wheel', allowInsideOnly as any);
			document.removeEventListener('touchmove', allowInsideOnly as any);
		};
	}, [drawer?.isOpen]);

	// ---------------- lock helpers ----------------

	const lockBody = () => {
		if (lockedRef.current) return;
		lockedRef.current = true;

		const { documentElement: html, body } = document;

		scrollYRef.current = window.scrollY || window.pageYOffset || 0;

		// Stop scroll chaining + rubber-banding on iOS
		html.style.overscrollBehavior = 'none';
		html.style.overflow = 'hidden';
		html.style.height = '100%';

		// Hard lock the page
		body.style.position = 'fixed';
		body.style.top = `-${scrollYRef.current}px`;
		body.style.left = '0';
		body.style.right = '0';
		body.style.width = '100%';
		body.style.height = '100%';
		body.style.overflow = 'hidden';
		(body.style as any).touchAction = 'none';

		// account for desktop scrollbar gap
		const scrollbarGap = window.innerWidth - html.clientWidth;
		if (scrollbarGap > 0) body.style.paddingRight = `${scrollbarGap}px`;
	};

	const unlockBody = () => {
		if (!lockedRef.current) return;
		lockedRef.current = false;

		const { documentElement: html, body } = document;

		body.style.position = '';
		body.style.top = '';
		body.style.left = '';
		body.style.right = '';
		body.style.width = '';
		body.style.height = '';
		body.style.overflow = '';
		(body.style as any).touchAction = '';

		html.style.overscrollBehavior = '';
		html.style.overflow = '';
		html.style.height = '';

		const y = scrollYRef.current || 0;
		window.scrollTo(0, y);
	};

	// ---------------- animation helpers ----------------

	const handleAnimationComplete = (definition: string) => {
		if (definition === 'exit') {
			setIsVisible(false);
			unlockBody();
		}
	};

	const snapTo = (targetPx: number) => {
		setAnimateHeight(true);
		setSheetHeight(clampHeight(targetPx));
	};

	// ---------------- drag handlers ----------------

	const onHandlePointerMove = (e: PointerEvent) => {
		if (!isDraggingRef.current) return;
		e.preventDefault();
		const now = performance.now();
		const y = e.clientY;

		const startY = dragStartYRef.current;
		const startH = dragStartHeightRef.current;
		const delta = startY - y;

		setAnimateHeight(false);
		setSheetHeight(clampHeight(startH + delta));

		lastMoveYRef.current = y;
		lastMoveTRef.current = now;
	};

	const endDrag = () => {
		if (!isDraggingRef.current) return;
		isDraggingRef.current = false;
		document.body.style.cursor = '';
		window.removeEventListener('pointermove', onHandlePointerMove);
		window.removeEventListener('pointerup', endDrag);
		window.removeEventListener('pointercancel', endDrag);

		const t = performance.now();
		const dt = Math.max(1, t - lastMoveTRef.current);
		const vy = (lastMoveYRef.current - dragStartYRef.current) / dt;

		const h = sheetHeight ?? parseHeightToPx(drawer?.height ?? '75vh');
		const midPx = vhToPx(MID_VH);
		const maxPx = vhToPx(MAX_VH);
		const closeSnapPx = vhToPx(CLOSE_SNAP_VH);

		if (vy > V_CLOSE || h < closeSnapPx) {
			closeDrawer();
			return;
		}

		if (vy < V_EXPAND) {
			snapTo(maxPx);
			return;
		}

		const toMax = Math.abs(h - maxPx) <= Math.abs(h - midPx);
		snapTo(toMax ? maxPx : midPx);
	};

	const onHandlePointerDown: React.PointerEventHandler<HTMLDivElement> = (
		e
	) => {
		if (drawer?.placement !== 'bottom') return;
		(e.currentTarget as HTMLDivElement).setPointerCapture(e.pointerId);
		e.preventDefault();
		e.stopPropagation();

		isDraggingRef.current = true;
		dragStartYRef.current = e.clientY;
		dragStartHeightRef.current =
			sheetHeight ?? parseHeightToPx(drawer?.height ?? '75vh');

		// seed last move for velocity
		lastMoveYRef.current = e.clientY;
		lastMoveTRef.current = performance.now();

		setAnimateHeight(false);
		document.body.style.cursor = 'ns-resize';

		window.addEventListener('pointermove', onHandlePointerMove, {
			passive: false,
		});
		window.addEventListener('pointerup', endDrag, { once: true });
		window.addEventListener('pointercancel', endDrag, { once: true });
	};

	// ---------------- guard (keep all hooks above) ----------------

	if (!drawer && !isVisible) return null;

	// container style (height animates via CSS transition)
	const getContainerStyle = (): React.CSSProperties => {
		const style: React.CSSProperties = {};
		const h =
			sheetHeight != null
				? `${sheetHeight}px`
				: drawer?.height != null
					? typeof drawer.height === 'string'
						? drawer.height
						: `${drawer.height}px`
					: undefined;

		if (h) style.height = h;
		// iOS momentum scroll + stop scroll chaining
		style.WebkitOverflowScrolling = 'touch';
		style.overscrollBehavior = 'contain';
		return style;
	};

	const getAnimationVariants = () => {
		switch (drawer?.placement) {
			case 'top':
				return {
					hidden: { y: '-100%' },
					visible: { y: '0%' },
					exit: { y: '-100%' },
				};
			case 'left':
				return {
					hidden: { x: '-100%' },
					visible: { x: '0%' },
					exit: { x: '-100%' },
				};
			case 'right':
				return {
					hidden: { x: '100%' },
					visible: { x: '0%' },
					exit: { x: '100%' },
				};
			case 'bottom':
			default:
				return {
					hidden: { y: '100%' },
					visible: { y: '0%' },
					exit: { y: '100%' },
				};
		}
	};

	const isOpenOrAnimating = !!drawer?.isOpen || isVisible;

	return (
		<AnimatePresence mode="wait">
			{isOpenOrAnimating && drawer && (
				<>
					{/* Overlay */}
					<motion.div
						key="overlay"
						initial={{ opacity: 0 }}
						animate={{ opacity: 0.45 }}
						exit={{ opacity: 0 }}
						transition={{ duration: 0.25 }}
						className="fixed inset-0 z-[9998] bg-[#23305f]/35 backdrop-blur-[2px]"
						onClick={closeDrawer}
						// extra safety (block background gestures on the overlay)
						onWheel={(e) => e.preventDefault()}
						onTouchMove={(e) => e.preventDefault()}
					/>

					{/* Drawer Container */}
					<motion.div
						key="drawer"
						initial="hidden"
						animate="visible"
						exit="exit"
						variants={getAnimationVariants()}
						transition={{
							type: 'spring',
							damping: 30,
							stiffness: 300,
							duration: 0.28,
						}}
						onAnimationComplete={handleAnimationComplete}
						style={getContainerStyle()}
						className={cn(
							'fixed z-[9999] overflow-hidden border border-white/90 bg-white/95 shadow-[0_-14px_30px_rgba(38,56,120,0.24)] backdrop-blur-xl',
							// height transition for snap/expand (disabled during drag)
							animateHeight ? 'transition-[height] duration-300 ease-out' : '',
							drawer.placement === 'bottom' &&
								'bottom-0 left-0 right-0 rounded-t-[30px]',
							drawer.placement === 'top' &&
								'left-0 right-0 top-0 rounded-b-[30px]',
							drawer.placement === 'left' && 'bottom-0 left-0 top-0',
							drawer.placement === 'right' && 'bottom-0 right-0 top-0',
							drawer.containerClassName
						)}
					>
						{drawer.placement === 'bottom' && (
							<div
								className="flex items-center py-2.5"
								style={{ cursor: 'grab', touchAction: 'none' }}
								aria-label="Drag handle"
								onPointerDown={onHandlePointerDown}
							>
								<div className="mx-auto h-1.5 w-14 rounded-full bg-gradient-to-r from-mainPurple/30 via-mainPurple/70 to-mainPurple/30" />
							</div>
						)}

						{/* Scrollable Content (only this area scrolls) */}
						<div
							ref={scrollAreaRef}
							className="h-full overflow-y-auto overscroll-none"
							style={{
								WebkitOverflowScrolling: 'touch',
								overscrollBehavior: 'none',
								touchAction: 'pan-y',
							}}
						>
							{drawer.view}
						</div>
					</motion.div>
				</>
			)}
		</AnimatePresence>
	);
}
