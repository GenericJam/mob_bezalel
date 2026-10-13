defmodule MobBezalel do
  @moduledoc """
  Bezalel's look for Mob apps: "the warmth of a leather study Bible, the
  exactness of a handheld tool." One style package, four themes:

    * `MobBezalel.Dark`: leather-dark, gold call to action (the default)
    * `MobBezalel.Light`: linen ground, umber call to action
    * `MobBezalel.Night`: low glare, no blue, text capped near 6:1
    * `MobBezalel.System`: Light or Dark, following the phone

  ## Activation

      # mix.exs
      {:mob_bezalel, "~> 0.1"}

      # mob.exs
      config :mob, :styles, [:mob_bezalel]
      config :mob, :default_style, :mob_bezalel

  Boot applies `MobBezalel.Dark`. Switch at runtime:

      Mob.Theme.set(MobBezalel.Night)

  `MobBezalel.System` follows the phone's light/dark setting; its moduledoc
  shows how a screen keeps it live across an OS appearance change.

  ## Tokens

  | `%Mob.Theme{}` slot | Bezalel role |
  |---|---|
  | `primary` / `on_primary` | call to action (`cta` / `on_cta`) |
  | `secondary` / `on_secondary` | accent (`accent` / `on_accent`): bronze, gold or amber by mode |
  | `background` / `on_background` | ground / ink |
  | `surface` / `surface_raised` / `on_surface` | card surface (the design has no raised tier) / ink |
  | `muted` | captions, kickers, inactive tabs |
  | `border` | hairlines and card outlines |
  | `error` / `on_error` | danger / light text on it |

  Radii: `radius_sm` 12 (tool tiles), `radius_md` 18 (cards, rows),
  `radius_lg` 28 (bottom sheets), `radius_pill` for buttons and chips.

  Fonts (`font:` prop tokens; text without one gets `:default`):

  | Token | Face | Use |
  |---|---|---|
  | `:default` | Instrument Sans Regular | interface text |
  | `:ui_medium` | Instrument Sans Medium | buttons, row titles |
  | `:ui_semibold` | Instrument Sans SemiBold | kickers, primary buttons, tab labels |
  | `:display` | EB Garamond Medium | screen titles, card titles |
  | `:scripture` | EB Garamond Regular | scripture and long-form serif |
  | `:scripture_semibold` | EB Garamond SemiBold | emphasis in scripture |
  | `:scripture_italic` | EB Garamond Italic | transliteration, epigraphs |
  | `:hebrew` | Frank Ruhl Libre Regular | Hebrew with niqqud, right to left |
  | `:hebrew_medium` | Frank Ruhl Libre Medium | the headword in a word study |

  Instrument Sans is never used for scripture. Colors without a theme slot
  (user bubble, bars, overlays, brand materials) are in `MobBezalel.Palette`.
  """

  alias MobBezalel.Palette

  @fonts_dir "priv/fonts"

  @font_files %{
    default: {"InstrumentSans-Regular", "InstrumentSans-Regular.ttf"},
    ui_medium: {"InstrumentSans-Medium", "InstrumentSans-Medium.ttf"},
    ui_semibold: {"InstrumentSans-SemiBold", "InstrumentSans-SemiBold.ttf"},
    display: {"EBGaramond-Medium", "EBGaramond-Medium.ttf"},
    scripture: {"EBGaramond-Regular", "EBGaramond-Regular.ttf"},
    scripture_semibold: {"EBGaramond-SemiBold", "EBGaramond-SemiBold.ttf"},
    scripture_italic: {"EBGaramond-Italic", "EBGaramond-Italic.ttf"},
    hebrew: {"FrankRuhlLibre-Regular", "FrankRuhlLibre-Regular.ttf"},
    hebrew_medium: {"FrankRuhlLibre-Medium", "FrankRuhlLibre-Medium.ttf"}
  }

  @doc "All themes in the package."
  @spec all() :: [module()]
  def all, do: [MobBezalel.Dark, MobBezalel.Light, MobBezalel.Night, MobBezalel.System]

  @doc "The theme module for a color mode."
  @spec theme_module(Palette.mode()) :: module()
  def theme_module(:light), do: MobBezalel.Light
  def theme_module(:dark), do: MobBezalel.Dark
  def theme_module(:night), do: MobBezalel.Night

  @doc """
  The color mode of the active theme (`:light`, `:dark` or `:night`), or
  `nil` when the active theme isn't a Bezalel one. `MobBezalel.UI` uses it to
  pick the colors that have no theme slot.
  """
  @spec mode() :: Palette.mode() | nil
  def mode do
    bg = Mob.Theme.current().background
    Enum.find(Palette.modes(), &(Palette.roles(&1).background == bg))
  end

  @doc """
  The font token map shared by every theme. Each value comes from
  `Mob.Theme.font/2`: the iOS PostScript name plus the Android resource name
  derived from the bundled file.
  """
  @spec fonts() :: %{atom() => Mob.Theme.font_spec()}
  def fonts do
    Map.new(@font_files, fn {token, {postscript, file}} ->
      {token, Mob.Theme.font(postscript, from_file: Path.join(@fonts_dir, file))}
    end)
  end

  @doc "The package-relative path of every font file the tokens reference."
  @spec font_paths() :: [Path.t()]
  def font_paths do
    @font_files
    |> Map.values()
    |> Enum.map(fn {_postscript, file} -> Path.join(@fonts_dir, file) end)
    |> Enum.sort()
  end

  @doc "Builds the `%Mob.Theme{}` for a color mode."
  @spec theme(Palette.mode()) :: Mob.Theme.t()
  def theme(mode) do
    r = Palette.roles(mode)

    Mob.Theme.build(
      primary: r.cta,
      on_primary: r.on_cta,
      secondary: r.accent,
      on_secondary: r.on_accent,
      background: r.background,
      on_background: r.ink,
      surface: r.surface,
      surface_raised: r.surface,
      on_surface: r.ink,
      muted: r.muted,
      error: r.danger,
      on_error: Palette.overlay().on_danger,
      border: r.line,
      radius_sm: 12,
      radius_md: 18,
      radius_lg: 28,
      fonts: fonts()
    )
  end
end
