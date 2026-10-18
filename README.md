# mob_bezalel

Bezalel's look for [Mob](https://hexdocs.pm/mob) apps: linen, leather and
gold. A Mob **style package** with four themes and the three typefaces the
design calls for, bundled.

| Theme | Ground | Call to action | Notes |
|---|---|---|---|
| `MobBezalel.Dark` (default) | `#17110E` | gold `#C9A04A` | oxblood user bubble |
| `MobBezalel.Light` | linen `#F3ECDD` | umber `#3B2A1E` | bronze accent |
| `MobBezalel.Night` | `#0C0A08` | `#3A2A1A` | no blue, low glare |
| `MobBezalel.System` | Light or Dark | | follows the phone |

Typefaces (SIL Open Font License 1.1, licenses in `priv/fonts/licenses/`):
EB Garamond for scripture and titles, Instrument Sans for interface text,
Frank Ruhl Libre for Hebrew.

## Install

```elixir
# mix.exs
{:mob_bezalel, "~> 0.1"}
```

```elixir
# mob.exs
config :mob, :styles, [:mob_bezalel]
config :mob, :default_style, :mob_bezalel
```

The fonts in `priv/mob_style.exs` → `assets.fonts` are copied into the iOS
app bundle (`UIAppFonts`) and Android `res/font/` by `mix mob.deploy
--native` and `mix mob.release`. That needs mob_dev 0.7.25 or later.

## Use

```elixir
Mob.Theme.set(MobBezalel.Night)

# Light or dark, following the phone (see MobBezalel.System for live updates)
Mob.Theme.set(MobBezalel.System)
```

Semantic tokens (`:primary`, `:surface`, `:muted`, `:border`, …) and font
tokens (`font: :display`, `font: :scripture`, `font: :hebrew`, …) are
documented in `MobBezalel`. Colors with no theme slot (user bubble, leather or
paper bars, toast and sheet overlays, the named brand materials) come from
`MobBezalel.Palette`:

```elixir
MobBezalel.Palette.chrome(:dark, :leather).bar   # 0xFF2A1D15
MobBezalel.Palette.roles(:dark).user_bubble      # 0xFF4A1F1A
MobBezalel.Palette.brand().tekhelet              # 0xFF1C2A44
```

## UI composites and icons

`MobBezalel.UI` builds the design's recurring pieces as ordinary Mob render
trees: `top_bar/3`, `bar_button/3`, `tab_bar/4` (more than four tabs
narrow its ends and labels, so five fit a 360 pt phone at the default font
scale), `card/2`, `kicker/2`,
`pill_button/4`, `chip/2`, `segmented/2`, `block/6`, `markdown_style/1`,
`user_bubble/1`, `meter/2`, and:

- `composer/5`: the reply field and send button. Options: `stop:` (a stop
  button while a reply streams), `leading:` and `actions:` (nodes before and
  after the field, e.g. an attach button and a mic), `above:` (nodes stacked
  above the field row, e.g. attachment chips in a horizontal `<Scroll>`),
  `send_enabled:` (overrides the blank-text check that dims send).
- `icon_button/3`: a round 44 pt icon button; `active: true` takes the
  call-to-action fill.
- `attachment_chip/3`: a pill with a kind icon, a short label and a close
  glyph that sends `on_remove` (none when it's `nil`).
- `menu_row/4`: a full-width row with an icon, a title and an optional note.

`MobBezalel.Icons.icon/3` draws the design's Lucide glyphs as `<Canvas>`
nodes; `Icons.names/0` lists them: `:study`, `:conversations`, `:workshop`,
`:settings`, `:send`, `:more`, `:chevron_down`, `:chevron_up`, `:hammer`,
`:materials` (gem), `:plus`, `:mic`, `:speaker` (volume-2), `:image`,
`:camera`, `:video`, `:audio` (audio-lines), `:file` (file-text), `:close`
(x), `:play`, `:stop` (square).

## Source

Tokens are taken from the Claude Design project "Bezalel Brand Foundation"
(`Bezalel Brand.dc.html`, `Bezalel Core Screens v2.dc.html`).
