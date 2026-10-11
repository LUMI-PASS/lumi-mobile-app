import 'package:flutter/material.dart';

abstract final class AppColors {
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF15141A);

  static const brandPurple = Color(0xFFA752C7);
  static const brandPink = Color(0xFFFC6F95);
  static const onBrand = Color(0xFFFFFFFF);

  static const link = Color(0xFF5735FF);

  /// The muted indigo of inline text actions ("Добавить фото").
  static const lightPurple = Color(0xFF6F5ED0);
  static const error = Color(0xFFFF4B55);

  static const green = Color(0xFF2CBE88);
  static const tagGreen = Color(0xFF7FB846);
  static const warning = Color(0xFFF6B53D);

  static const inkMuted = Color(0xFFA5A6BB);
  static const inkChip = Color(0xFFEFEEF5);
  static const greeting = Color(0xFF717386);

  /// Coupon accent — the discount tile and the usage bar. Theme-invariant: it
  /// always carries dark ink on top.
  static const lime = Color(0xFFAFF26E);

  /// Neutral status pill (white label on grey). Theme-invariant by design.
  static const chipGrey = Color(0xFF4B4B55);

  // Lumi Coin pack tones — each pack on the coin shelf is shown in its own
  // colour: a pale tint, the accent and a deep shade. Theme-invariant: the
  // tones are the packs' identity, and it is the stage and the panels under
  // them that follow the theme — see `AppColorScheme.coinStage` / `coinPanel`.
  /// The coin shelf's page colour in light — a near-white with the faintest
  /// lilac in it, so the pack's wash at the top edge has somewhere to fade to
  /// instead of stopping dead on flat white. Dark uses [ink].
  static const lightCoinStage = Color(0xFFFAF8FD);
  static const coinOrangeLight = Color(0xFFFFB38A);
  static const coinOrange = Color(0xFFFF7A3D);
  static const coinOrangeDeep = Color(0xFFD9480F);
  static const coinVioletLight = Color(0xFFFFB3C8);
  static const coinBlueLight = Color(0xFF9DB8FF);
  static const coinBlue = Color(0xFF5B8CFF);
  static const coinBlueDeep = Color(0xFF2F4BD8);
  static const coinGoldLight = Color(0xFFFFE680);
  static const coinGold = Color(0xFFFFCB1F);
  static const coinGoldDeep = Color(0xFFE59A00);
  static const coinMintLight = Color(0xFF9AF0CF);
  static const coinMint = Color(0xFF3ED6A4);
  static const coinMintDeep = Color(0xFF12946B);

  // Aurora — the shop's mesh-gradient page wash. A base plus four corner
  // glows leaning into the brand purple/pink.
  static const auroraBaseLight = Color(0xFFFBF9FD);
  static const auroraBaseDark = Color(0xFF15141A);
  static const auroraOrchidLight = Color(0xFFE9D3F5);
  static const auroraOrchidDark = Color(0xFF3B2150);
  static const auroraBlushLight = Color(0xFFFBD9E4);
  static const auroraBlushDark = Color(0xFF4A2138);
  static const auroraLilacLight = Color(0xFFDEDAFA);
  static const auroraLilacDark = Color(0xFF262150);
  static const auroraMauveLight = Color(0xFFF2DCF2);
  static const auroraMauveDark = Color(0xFF34204A);

  // light
  static const lightScaffold = Color(0xFFF9F9FA);
  static const lightCanvas = Color(0xFFEFEEF5);

  /// Fill of the coin-row container on the home feed.
  ///
  /// A pale brand lavender. The panel is ONE hue in both themes — this and
  /// [darkCoinBand] are the same violet at two depths — so the section reads
  /// as the same thing whichever theme it is opened in. It was a pale gold
  /// here over a purple there, which made it two different-looking sections.
  ///
  /// Purple rather than gold because only purple survives the trip to dark: a
  /// gold deep enough to carry white text is a brown. The coin's gold is left
  /// to the coins printed on the cards.
  ///
  /// It has no border, so it separates from [lightScaffold] by hue alone —
  /// the two are close in luminance. That is why green is held this far under
  /// blue: lift it and the block turns into an off-white rectangle.
  static const lightCoinBand = Color(0xFFE6DDFB);

  /// Fills of the home feed's other coloured shelves — see
  /// `AppColorScheme.trialBand` and `discountBand`. Pale for the same reason
  /// [lightCoinBand] is: the cards on them are white, and the band only has
  /// to say "this row is a different kind of thing".
  static const lightTrialBand = Color(0xFFE2EAFF);
  static const lightDiscountBand = Color(0xFFFFE1E9);
  static const lightControl = Color(0xFFF2F1F6);
  static const lightControlBorder = Color(0xFFE6E5EC);
  static const lightTextSecondary = Color(0xFF6E6D78);
  static const lightPlaceholder = Color(0xFFB9B8C2);
  static const lightBorder = Color(0xFFD5D7DA);
  static const lightDivider = Color(0xFFE5E7EA);

  // dark
  static const darkCanvas = Color(0xFF1D1C23);

  /// [lightCoinBand]'s dark counterpart: the same brand violet taken right
  /// down, so a white label reads on it and the dark cards lift off it.
  ///
  /// The two golds tried here first (`302713`, `453410`) both came out as a
  /// muddy brown on a device, which is what moved the whole panel to purple.
  static const darkCoinBand = Color(0xFF2C2244);
  static const darkTrialBand = Color(0xFF1B2545);
  static const darkDiscountBand = Color(0xFF3B1E2B);
  static const darkSurface = Color(0xFF202024);
  static const darkSurfaceRaised = Color(0xFF26252B);
  static const darkControl = Color(0xFF313039);
  static const darkControlBorder = Color(0xFF4C4C54);
  static const darkTextSecondary = Color(0xFFA5A6BB);
  static const darkPlaceholder = Color(0xFF4B4B55);
  static const darkBorder = Color(0xFF3D3D46);
  static const darkDivider = Color(0xFF2D2E33);
  static const textMuted = Color(0xFF85848C);
}
