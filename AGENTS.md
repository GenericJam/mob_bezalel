# AGENTS.md: mob_bezalel

A Mob **style package** (not a plugin): Bezalel's palette, radii and font
tokens, plus the font files. Activated with `config :mob, :styles,
[:mob_bezalel]`; manifest is `priv/mob_style.exs`. Also read
`~/code/mob/MOB_STYLES.md`, `~/code/mob/MOB_FONTS.md` and
`~/code/mob_themes/AGENTS.md` (the sibling style package this one mirrors).

## Where the values come from

The Claude Design project "Bezalel Brand Foundation"
(`https://claude.ai/design/p/0eb39018-24f4-41b6-9643-8735d3de5a8e`), saved
locally at `~/code/bezalel/design/`:

- `Bezalel Brand.dc.html`: named materials (linen, parchment, gold, bronze,
  ink, tekhelet, argaman, scarlet, oxblood, umber), typeface roles, the
  night-mode and leather rules.
- `Bezalel Core Screens v2.dc.html`: the `THEMES` object (per-mode roles) and
  the bar chrome logic in `renderVals()`.

The project also carries an attached "Organic" design system under `_ds/`;
the Bezalel screens don't use it, and neither does this package.

When the design changes, update `MobBezalel.Palette` first; the theme modules
derive from it.

## Anatomy

- `lib/mob_bezalel.ex`: `theme/1` (role → `%Mob.Theme{}` slot mapping),
  `fonts/0`, `font_paths/0`, `all/0`.
- `lib/mob_bezalel/palette.ex`: every color as ARGB, including those with no
  theme slot.
- `lib/mob_bezalel/{dark,light,night,system}.ex`: the theme modules.
- `priv/fonts/`: static TTF instances cut from the Google Fonts variable
  fonts (`fontTools.varLib.instancer`), licenses in `priv/fonts/licenses/`.
  The EB Garamond italic's PostScript name was set to `EBGaramond-Italic`.

## Rules

1. Every font file a token references is listed in the manifest's
   `assets.fonts`, and the token's iOS name equals the file's PostScript name.
   The tests check both; a mismatch silently renders the system font on iOS.
2. Every theme sets the same tokens (they're interchangeable at
   `Mob.Theme.set/1`).
3. Night mode carries no blue (tested).

## Gate

```bash
mix format && mix credo --strict && mix compile --warnings-as-errors && mix test
```

`MOB_DEV_PATH=<checkout>` points the test-only mob_dev dep at a local checkout
(needed until a mob_dev release that validates `assets.fonts` in style
manifests is on Hex).

Don't bump `@version` without Kevin's go-ahead.
