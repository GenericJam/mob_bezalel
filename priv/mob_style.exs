%{
  name: :mob_bezalel,
  mob_version: "~> 0.9",
  style_spec_version: 1,
  description:
    "Bezalel: linen, leather and gold. Dark (default), Light, Night and System themes " <>
      "with EB Garamond, Instrument Sans and Frank Ruhl Libre",
  # The boot default; Light, Night and System are one Mob.Theme.set/1 away
  # (see MobBezalel.all/0).
  theme: MobBezalel.Dark,
  # Bundled into the host's native build like plugin fonts (iOS .app +
  # UIAppFonts, Android res/font). Every file MobBezalel.fonts/0 references
  # must be listed here.
  assets: %{
    fonts: [
      "priv/fonts/EBGaramond-Regular.ttf",
      "priv/fonts/EBGaramond-Medium.ttf",
      "priv/fonts/EBGaramond-SemiBold.ttf",
      "priv/fonts/EBGaramond-Italic.ttf",
      "priv/fonts/InstrumentSans-Regular.ttf",
      "priv/fonts/InstrumentSans-Medium.ttf",
      "priv/fonts/InstrumentSans-SemiBold.ttf",
      "priv/fonts/FrankRuhlLibre-Regular.ttf",
      "priv/fonts/FrankRuhlLibre-Medium.ttf"
    ]
  }
}
