defmodule MobBezalel.Palette do
  @moduledoc """
  Every Bezalel color as an ARGB integer, ready for any Mob color prop.

  Values come from the Claude Design project "Bezalel Brand Foundation"
  (`Bezalel Brand.dc.html` for the named materials, `Bezalel Core Screens
  v2.dc.html` for the per-mode roles and the bar chrome).

  The theme modules (`MobBezalel.Dark` and friends) map the roles that have a
  `%Mob.Theme{}` slot. Use this module for what has no slot: the user's chat
  bubble, the leather or paper bars, the gold mark, and the dark overlays
  (toast, selection popover, sheet scrim).

      MobBezalel.Palette.roles(:dark).user_bubble
      MobBezalel.Palette.chrome(:dark, :leather).bar
      MobBezalel.Palette.brand().tekhelet

  Brand rules from the design: night mode carries no blue; scarlet and
  argaman are accents (highlights, cross-reference tags, the build-a-tool
  surface), never text grounds; leather (grain, stitching, gold foil) is for
  brand moments: icon, splash, the cover of a user-built tool, the bars.
  """

  @type mode :: :light | :dark | :night
  @type cover :: :leather | :paper
  @type argb :: non_neg_integer()

  @modes [:light, :dark, :night]
  @covers [:leather, :paper]

  # "Tabernacle materials · Exodus 26 & 31"
  @brand %{
    linen: 0xFFF3ECDD,
    parchment: 0xFFE5D7BA,
    gold: 0xFFC9A04A,
    bronze: 0xFF8A5A2B,
    ink: 0xFF1E1A16,
    tekhelet: 0xFF1C2A44,
    argaman: 0xFF4E2648,
    scarlet: 0xFF9E2B25,
    oxblood: 0xFF4A1F1A,
    umber: 0xFF3B2A1E
  }

  # The gold-foil gradient (135°) used on the mark and brand moments.
  @foil [0xFFF4DC98, 0xFFC9A04A, 0xFF8F6A25, 0xFFE3C277]

  @roles %{
    light: %{
      background: 0xFFF3ECDD,
      surface: 0xFFFBF7EE,
      ink: 0xFF1E1A16,
      muted: 0xFF6B5E4E,
      line: 0xFFDCCFB4,
      accent: 0xFF8A5A2B,
      on_accent: 0xFFF3ECDD,
      cta: 0xFF3B2A1E,
      on_cta: 0xFFF3ECDD,
      user_bubble: 0xFF3B2A1E,
      on_user_bubble: 0xFFF3ECDD,
      danger: 0xFF9E2B25
    },
    dark: %{
      background: 0xFF17110E,
      surface: 0xFF221A15,
      ink: 0xFFEDE3CF,
      muted: 0xFFA8977E,
      line: 0xFF362A21,
      accent: 0xFFD2AE5E,
      on_accent: 0xFF17110E,
      cta: 0xFFC9A04A,
      on_cta: 0xFF17110E,
      user_bubble: 0xFF4A1F1A,
      on_user_bubble: 0xFFF3E6CF,
      danger: 0xFFD0605A
    },
    night: %{
      background: 0xFF0C0A08,
      surface: 0xFF15110E,
      ink: 0xFFA9814F,
      muted: 0xFF7E6446,
      line: 0xFF2A2119,
      accent: 0xFFB07A3E,
      # The design puts on_cta (#C79A5E) on the accent: about 1.4:1, so a
      # selected segment's label vanished on device. The night ground reads
      # at about 5:1 and keeps the mode free of blue.
      on_accent: 0xFF0C0A08,
      cta: 0xFF3A2A1A,
      on_cta: 0xFFC79A5E,
      user_bubble: 0xFF1E1813,
      on_user_bubble: 0xFFA9814F,
      danger: 0xFFD0605A
    }
  }

  # Leather bars: grain-textured umber with a dashed gold stitch.
  # bar_line is gold at 50%, stitch is gold at 45%.
  @leather %{
    light: %{bar: 0xFF3B2A1E, on_bar: 0xFFEDE3CF},
    dark: %{bar: 0xFF2A1D15, on_bar: 0xFFEDE3CF},
    night: %{bar: 0xFF120D0A, on_bar: 0xFFA9814F}
  }
  @leather_bar_line 0x80C9A04A
  @leather_stitch 0x73C9A04A

  # Dark overlays: the same in every mode.
  @overlay %{
    popover: 0xFF0C0A08,
    on_popover: 0xFFEDE3CF,
    popover_action: 0xFFE3C277,
    popover_divider: 0xFF3A2E25,
    scrim: 0x800A0705,
    mark_gold: 0xFFE3C277,
    on_danger: 0xFFF3ECDD
  }

  @doc "The three color modes, in the order the design's Theme control lists them."
  @spec modes() :: [mode()]
  def modes, do: @modes

  @doc "The two bar treatments."
  @spec covers() :: [cover()]
  def covers, do: @covers

  @doc "The named brand materials."
  @spec brand() :: %{atom() => argb()}
  def brand, do: @brand

  @doc "The gold-foil gradient stops, light to dark to light."
  @spec foil() :: [argb()]
  def foil, do: @foil

  @doc """
  The color roles for one mode: `background`, `surface`, `ink`, `muted`,
  `line`, `accent`, `on_accent`, `cta`, `on_cta`, `user_bubble`,
  `on_user_bubble`, `danger`.
  """
  @spec roles(mode()) :: %{atom() => argb()}
  def roles(mode) when mode in @modes, do: Map.fetch!(@roles, mode)

  @doc """
  The top and bottom bar colors for a mode and cover: `bar`, `on_bar`,
  `bar_line` (outlines on the bar) and `stitch` (the dashed gold rule;
  `nil` for paper, which has none).
  """
  @spec chrome(mode(), cover()) :: %{
          bar: argb(),
          on_bar: argb(),
          bar_line: argb(),
          stitch: argb() | nil
        }
  def chrome(mode, :leather) when mode in @modes do
    @leather
    |> Map.fetch!(mode)
    |> Map.merge(%{bar_line: @leather_bar_line, stitch: @leather_stitch})
  end

  def chrome(mode, :paper) when mode in @modes do
    r = roles(mode)
    %{bar: r.background, on_bar: r.ink, bar_line: r.line, stitch: nil}
  end

  @doc """
  The overlay colors shared by every mode: `popover` / `on_popover` /
  `popover_action` / `popover_divider` (toast and text-selection popover),
  `scrim` (behind bottom sheets), `mark_gold` (the mark and monogram on
  leather), `on_danger` (text on a danger fill).
  """
  @spec overlay() :: %{atom() => argb()}
  def overlay, do: @overlay
end
