defmodule MobBezalel.UI do
  @moduledoc """
  The design's recurring pieces as function composites: bars, cards, pill
  buttons, chips, the segmented pill control, kickers, the collapsible block
  and the user bubble. Each returns an ordinary Mob render tree, so call them
  inside `{...}` in a screen's `~MOB` template; taps go to the screen's
  `handle_info/2` as usual.

  Colors come from the active theme's tokens (`:primary`, `:surface`,
  `:border`, …) where a slot exists. The rest (bars, user bubble) depend on
  the color mode, which `MobBezalel.mode/0` reads off the active theme, and on
  the cover (`:leather` or `:paper`), which is the app's setting and so is
  passed in.
  """

  import Mob.Sigil

  alias MobBezalel.Palette

  @type tap :: {pid(), term()}

  @doc """
  The top bar: the Bezalel mark and the screen title in EB Garamond on the
  bar color. Mob's root already keeps content below the status bar on both
  platforms, so the bar starts there. `:trailing` places a node at the right;
  use `bar_button/3` so it takes the bar's colors.
  """
  @spec top_bar(String.t(), Palette.cover(), keyword()) :: map()
  def top_bar(title, cover, opts \\ []) do
    c = chrome(cover)
    # A child slot accepts a list; [] renders nothing (a size-0 Spacer would
    # flex on both platforms and halve the title's width).
    trailing = List.wrap(Keyword.get(opts, :trailing))
    # Gold foil on leather; the accent on paper (the design's markFill).
    mark_color = if cover == :leather, do: Palette.overlay().mark_gold, else: :secondary
    mark = MobBezalel.Icons.mark(26, mark_color, cutout: c.bar)

    ~MOB"""
    <Column background={c.bar} padding_left={18} padding_right={18} padding_top={6} padding_bottom={14} fill_width={true}>
      <Row gap={10} align={:center} fill_width={true}>
        {mark}
        <Text text={title} font={:display} text_size={23} text_color={c.on_bar} max_lines={1} weight={1} />
        {trailing}
      </Row>
    </Column>
    """
  end

  @doc """
  A small outline pill for the top bar (Workshop, Expand all): the bar's ink
  and outline, which stay legible on leather in every mode.
  """
  @spec bar_button(String.t(), tap(), Palette.cover()) :: map()
  def bar_button(label, tap, cover) do
    c = chrome(cover)

    ~MOB"""
    <Box border_color={c.bar_line} border_width={1} corner_radius={16} height={32} padding_left={12} padding_right={12} align="center" fill_width={false} on_tap={tap}>
      <Text text={label} font={:ui_medium} text_size={12} text_color={c.on_bar} max_lines={1} />
    </Box>
    """
  end

  @doc """
  The bottom-sheet look from the design, as `<Sheet>` props: page-ground
  background, 28 pt top corners, a warm scrim, and a 40×5 handle in the line
  color. Pass them through with the sheet's other props:

      style = UI.sheet_style()
      <Sheet background={style.background} corner_radius={style.corner_radius} scrim={style.scrim}
             drag_indicator_color={style.drag_indicator_color} ... >

  iOS draws its own system scrim (the `scrim` prop is Android-only).
  """
  @spec sheet_style() :: map()
  def sheet_style do
    %{
      background: :background,
      corner_radius: 28,
      scrim: Palette.overlay().scrim,
      drag_indicator_color: :border,
      drag_indicator_width: 40,
      drag_indicator_height: 5,
      drag_indicator_rail_height: 24
    }
  end

  @doc """
  The bottom tab bar. `tabs` is a list of `{label, icon, tap}` (`icon` one of
  `MobBezalel.Icons.names/0`); the one at `active_index` is full strength,
  the others at 55%.

  `inset` is the safe-area bottom (`assigns.safe_area.bottom`). Mob's iOS root
  lets content run under the home indicator, so the bar pads by it there and
  its color fills the indicator area; Android's root already stops above the
  navigation bar, so the inset isn't added again.
  """
  @spec tab_bar([{String.t(), atom(), tap()}], non_neg_integer(), Palette.cover(), number()) ::
          map()
  def tab_bar(tabs, active_index, cover, inset \\ 0) do
    c = chrome(cover)
    ios = %{padding_bottom: inset + 8}
    # Five tabs fit a 360 pt phone only with narrower ends and a smaller
    # label ("Conversations" is ~65 pt at 9.5); four keep the design's.
    {side, label_size} =
      if Enum.count_until(tabs, 5) > 4, do: {4, 9.5}, else: {18, 11}

    items =
      tabs
      |> Enum.with_index()
      |> Enum.map(fn {{label, icon, tap}, i} ->
        color = if i == active_index, do: c.on_bar, else: fade(c.on_bar, 0.55)
        glyph = MobBezalel.Icons.icon(icon, 24, color)

        # Each part centers itself: an iOS Column always aligns its children
        # leading, whatever its `align`.
        ~MOB"""
        <Column weight={1} gap={4} padding_top={8} padding_bottom={6} on_tap={tap}>
          <Box align="center" fill_width={true}>{glyph}</Box>
          <Text text={label} font={:ui_semibold} text_size={label_size} text_color={color} text_align="center" max_lines={1} fill_width={true} />
        </Column>
        """
      end)

    ~MOB"""
    <Row background={c.bar} padding_left={side} padding_right={side} padding_bottom={8} ios={ios} fill_width={true}>
      {items}
    </Row>
    """
  end

  @doc "A card: surface fill, hairline border, 18 pt corners."
  @spec card([map()] | map(), keyword()) :: map()
  def card(children, opts \\ []) do
    padding = Keyword.get(opts, :padding, 14)
    gap = Keyword.get(opts, :gap, 8)
    border = Keyword.get(opts, :border, :border)
    border_width = Keyword.get(opts, :border_width, 1)
    radius = Keyword.get(opts, :radius, :radius_md)

    ~MOB"""
    <Box background={:surface} border_color={border} border_width={border_width} corner_radius={radius} padding={padding} fill_width={true}>
      <Column gap={gap} fill_width={true}>
        {children |> List.wrap() |> List.flatten()}
      </Column>
    </Box>
    """
  end

  @doc "An uppercase tracked label (section headers, card kickers)."
  @spec kicker(String.t(), Mob.Theme.color_value()) :: map()
  def kicker(text, color \\ :muted) do
    label = String.upcase(text)

    ~MOB(<Text text={label} font={:ui_semibold} text_size={10.5} letter_spacing={1.3} text_color={color} />)
  end

  @doc """
  A pill button. Variants: `:primary` (call to action), `:outline`
  (hairline, transparent), `:danger`. Options: `:height` (default 46),
  `:fill` (stretch to the row's width; default `true`), `:weight`.
  """
  @spec pill_button(String.t(), tap(), :primary | :outline | :danger, keyword()) :: map()
  def pill_button(label, tap, variant \\ :primary, opts \\ []) do
    {bg, fg, font, border} =
      case variant do
        :primary -> {:primary, :on_primary, :ui_semibold, nil}
        :outline -> {nil, :on_background, :ui_medium, :border}
        :danger -> {:error, :on_error, :ui_semibold, nil}
      end

    height = Keyword.get(opts, :height, 46)
    size = Keyword.get(opts, :text_size, 14)

    # A Box, not a Row: only Box draws corner_radius and borders on both
    # platforms. align: "center" centers the label both ways in the fixed
    # height; fill: false hugs the label (padding gives the pill its ends).
    %{
      type: :box,
      props:
        reject_nil(%{
          background: bg,
          border_color: border,
          border_width: border && 1,
          corner_radius: height / 2,
          height: height,
          padding_left: 16,
          padding_right: 16,
          align: "center",
          fill_width: Keyword.get(opts, :fill, true),
          weight: Keyword.get(opts, :weight),
          on_tap: tap
        }),
      children: [
        ~MOB(<Text text={label} font={font} text_size={size} text_color={fg} max_lines={1} />)
      ]
    }
  end

  @doc "A small pill chip: hairline border on the page ground."
  @spec chip(String.t(), tap() | nil) :: map()
  def chip(label, tap \\ nil) do
    %{
      type: :box,
      props:
        reject_nil(%{
          background: :background,
          border_color: :border,
          border_width: 1,
          corner_radius: 16,
          padding_left: 12,
          padding_right: 12,
          padding_top: 8,
          padding_bottom: 8,
          fill_width: false,
          on_tap: tap
        }),
      children: [
        ~MOB(<Text text={label} font={:ui_medium} text_size={12.5} text_color={:on_background} />)
      ]
    }
  end

  @doc """
  The segmented pill control (Theme, Cover). `options` is a list of
  `{label, tap}`; the option at `selected_index` takes the accent fill.
  """
  @spec segmented([{String.t(), tap()}], non_neg_integer()) :: map()
  def segmented(options, selected_index) do
    segments =
      options
      |> Enum.with_index()
      |> Enum.map(fn {{label, tap}, i} ->
        {bg, fg} =
          if i == selected_index, do: {:secondary, :on_secondary}, else: {nil, :on_background}

        %{
          type: :box,
          props:
            reject_nil(%{
              background: bg,
              corner_radius: 18,
              height: 36,
              weight: 1,
              align: "center",
              on_tap: tap
            }),
          children: [
            ~MOB(<Text text={label} font={:ui_medium} text_size={13} text_color={fg} max_lines={1} />)
          ]
        }
      end)

    ~MOB"""
    <Box background={:background} border_color={:border} border_width={1} corner_radius={22} padding={4} fill_width={true}>
      <Row gap={4} fill_width={true}>
        {segments}
      </Row>
    </Box>
    """
  end

  @doc """
  A collapsible model-output block (THINKING, TOOL CALL, SUMMARY): a type
  tag, the first line, and when `open?` the rest (if there is any).
  `:summary` blocks sit on the page ground with an accent tag; the others on
  the surface, muted.

  `rest` is plain text, or a node to show in its place (a Markdown view
  styled by `markdown_style/1`), inset like the text.
  """
  @spec block(String.t(), String.t(), String.t() | map(), boolean(), tap(), :summary | :aside) ::
          map()
  def block(type, first, rest, open?, tap, kind \\ :aside) do
    {bg, ink, tag_color, size} =
      case kind do
        :summary -> {:background, :on_background, :secondary, 15.5}
        :aside -> {:surface, :muted, :muted, 14}
      end

    chevron =
      MobBezalel.Icons.icon(if(open?, do: :chevron_up, else: :chevron_down), 14, :muted,
        stroke: 2.75
      )

    body = if open?, do: block_body(rest, size, ink), else: []

    ~MOB"""
    <Box background={bg} border_color={:border} border_width={1} corner_radius={16} fill_width={true}>
      <Column fill_width={true}>
        <Row gap={10} align={:center} padding_left={12} padding_right={12} padding_top={12} padding_bottom={12} fill_width={true} on_tap={tap}>
          <Box border_color={tag_color} border_width={1} corner_radius={10} padding_left={8} padding_right={8} padding_top={3} padding_bottom={3} fill_width={false}>
            <Text text={type} font={:ui_semibold} text_size={9.5} letter_spacing={0.95} text_color={tag_color} />
          </Box>
          <Text text={first} text_size={size} text_color={ink} max_lines={1} weight={1} />
          {chevron}
        </Row>
        {body}
      </Column>
    </Box>
    """
  end

  defp block_body("", _size, _ink), do: []

  defp block_body(rest, size, ink) when is_binary(rest) do
    ~MOB(<Text text={rest} text_size={size} line_height={1.55} text_color={ink} padding_left={14} padding_right={14} padding_bottom={14} />)
  end

  defp block_body(%{} = node, _size, _ink) do
    ~MOB"""
    <Box padding_left={14} padding_right={14} padding_bottom={14} fill_width={true}>
      {node}
    </Box>
    """
  end

  @doc """
  The look of a block's Markdown body (`block/6`'s `kind`), as the props of
  a native Markdown view (mob_markdown's `MobMarkdown.view/3`): the block's
  size and ink, headings in EB Garamond, emphasis in Instrument Sans
  SemiBold, code in the system monospace on a ground of its own, links in
  the accent. Colors are the active theme's mode, so build it at render
  time; faces are in platform blocks, which the renderer resolves.
  """
  @spec markdown_style(:summary | :aside) :: map()
  def markdown_style(kind \\ :summary) do
    r = Palette.roles(MobBezalel.mode() || :dark)
    fonts = MobBezalel.fonts()

    # Code sits on a hairline-colored ground in a summary (on the page
    # ground); in an aside (on the surface) the page ground, since muted ink
    # on the hairline color is too faint at night.
    {ink, size, code_ground} =
      case kind do
        :summary -> {r.ink, 15.5, r.line}
        :aside -> {r.muted, 14, r.background}
      end

    faces = %{
      font_regular: fonts.default,
      font_bold: fonts.ui_semibold,
      font_heading: fonts.display
    }

    %{
      text_size: size,
      line_height: 1.55,
      text_color: ink,
      heading_color: ink,
      link_color: r.accent,
      code_color: ink,
      code_background: code_ground,
      quote_color: r.muted,
      rule_color: r.line,
      selection_color: r.accent,
      ios: Map.new(faces, fn {key, font} -> {key, font.ios} end),
      android: Map.new(faces, fn {key, font} -> {key, font.android} end)
    }
  end

  @doc """
  The user's chat bubble: right-aligned, at most ~80% of the width, hugging
  short text.
  """
  @spec user_bubble(String.t()) :: map()
  def user_bubble(text) do
    r = Palette.roles(MobBezalel.mode() || :dark)

    # A trailing-aligned Box rather than Row + Spacer: both platforms then
    # offer the bubble the full width, so it hugs short text and wraps long
    # text at the padding (a flexible Spacer made iOS split the row in half).
    ~MOB"""
    <Box align="top_trailing" padding_left={56} fill_width={true}>
      <Box background={r.user_bubble} corner_radius={18} padding_left={14} padding_right={14} padding_top={11} padding_bottom={11} fill_width={false}>
        <Text text={text} text_size={15} line_height={1.45} text_color={r.on_user_bubble} />
      </Box>
    </Box>
    """
  end

  @doc """
  The reply composer pinned above the tab bar: a two-line rounded field on
  the surface and a round send button in the call-to-action color. The send
  button dims to 40% while `value` is blank.

  `opts`: `stop:` a tap for a round stop button (an outlined circle with a
  square) before the send button, shown while a reply streams; sending
  then still works (the app adds the message to the reply in progress).

  `leading:` nodes before the field (an attach button), `actions:` nodes
  after it, before stop and send (a mic), both bottom-aligned with send.
  `above:` nodes shown above the field row (attachment chips, a status
  line). `send_enabled:` decides the send button's strength instead of the
  blank check, so a message of attachments alone can be sent.
  """
  @spec composer(String.t(), String.t(), tap(), tap(), keyword()) :: map()
  def composer(value, placeholder, on_change, on_send, opts \\ []) do
    enabled = Keyword.get_lazy(opts, :send_enabled, fn -> String.trim(value) != "" end)
    send_bg = if enabled, do: :primary, else: dim(:primary, 0.4)
    leading = Keyword.get(opts, :leading, [])
    actions = Keyword.get(opts, :actions, [])
    above = Keyword.get(opts, :above, [])
    # Android's Material TextField already pads its text by 16dp, and its
    # `lines` rows sit taller than iOS's; padding there would double up.
    android = %{padding: 0, underline: false}

    stop =
      case Keyword.get(opts, :stop) do
        nil ->
          []

        tap ->
          [
            ~MOB"""
            <Box id="composer-stop" width={44} height={44} corner_radius={22} border_color={:border} border_width={1.5} background={:surface} align="center" fill_width={false} on_tap={tap}>
              <Box width={14} height={14} corner_radius={3} background={:on_surface} fill_width={false} />
            </Box>
            """
          ]
      end

    row = ~MOB"""
    <Row gap={8} align={:end} padding_left={12} padding_right={12} padding_top={10} padding_bottom={12} background={:background} fill_width={true}>
      {leading}
      <TextField value={value} placeholder={placeholder} on_change={on_change} lines={2} corner_radius={20} background={:surface} border_color={:border} border_width={1} padding={12} text_size={15} weight={1} android={android} />
      {actions}
      {stop}
      <Box width={44} height={44} corner_radius={22} background={send_bg} align="center" fill_width={false} on_tap={on_send}>
        <Text text="↑" text_size={20} font={:ui_semibold} text_color={:on_primary} />
      </Box>
    </Row>
    """

    composer_above(row, above)
  end

  defp composer_above(row, []), do: row

  # The chips sit inside the composer's padding, above the field row.
  defp composer_above(row, above) do
    unpadded = %{padding_top: 0, padding_left: 0, padding_right: 0, padding_bottom: 0}
    row = %{row | props: Map.merge(row.props, unpadded)}

    ~MOB"""
    <Column gap={8} padding_left={12} padding_right={12} padding_top={10} padding_bottom={12} background={:background} fill_width={true}>
      {above}
      {row}
    </Column>
    """
  end

  @doc """
  A 44×44 round icon button: surface fill, hairline border, the icon
  (20 pt) centered. `active: true` takes the call-to-action fill (a mic
  that's listening). Options: `:id`, `:size` (default 44).
  """
  @spec icon_button(atom(), tap(), keyword()) :: map()
  def icon_button(icon_name, tap, opts \\ []) do
    size = Keyword.get(opts, :size, 44)

    {bg, fg, border} =
      if Keyword.get(opts, :active, false),
        do: {:primary, :on_primary, nil},
        else: {:surface, :on_surface, :border}

    %{
      type: :box,
      props:
        reject_nil(%{
          id: Keyword.get(opts, :id),
          width: size,
          height: size,
          corner_radius: size / 2,
          background: bg,
          border_color: border,
          border_width: border && 1.5,
          align: "center",
          fill_width: false,
          on_tap: tap
        }),
      children: [MobBezalel.Icons.icon(icon_name, 20, fg)]
    }
  end

  @doc """
  An attachment in the composer: a small pill with the kind's icon, the
  label (one line; a long one keeps its start and its extension around an
  ellipsis, so the pill stays short) and a close glyph whose 28 pt target
  sends `on_remove`. `on_remove` nil leaves the glyph off.
  """
  @spec attachment_chip(atom(), String.t(), tap() | nil) :: map()
  def attachment_chip(icon_name, label, on_remove) do
    glyph = MobBezalel.Icons.icon(icon_name, 14, :secondary)
    label = shorten(label, 24)

    close =
      case on_remove do
        nil ->
          []

        tap ->
          x = MobBezalel.Icons.icon(:close, 14, :muted)

          [
            ~MOB(<Box width={28} height={28} align="center" fill_width={false} on_tap={tap}>{x}</Box>)
          ]
      end

    ~MOB"""
    <Box background={:surface} border_color={:border} border_width={1} corner_radius={14} padding_left={10} padding_right={6} padding_top={6} padding_bottom={6} fill_width={false}>
      <Row gap={6} align={:center}>
        {glyph}
        <Text text={label} font={:ui_medium} text_size={13} text_color={:on_surface} max_lines={1} />
        {close}
      </Row>
    </Box>
    """
  end

  defp shorten(text, max) do
    if String.length(text) <= max,
      do: text,
      else: String.slice(text, 0, max - 9) <> "…" <> String.slice(text, -8, 8)
  end

  @doc """
  A full-width menu row (the attach menu): an icon in the accent, a title
  and an optional note under it; the whole row taps `tap`.
  """
  @spec menu_row(atom(), String.t(), String.t() | nil, tap()) :: map()
  def menu_row(icon_name, title, note, tap) do
    glyph = MobBezalel.Icons.icon(icon_name, 22, :secondary)

    note =
      if note, do: [~MOB(<Text text={note} text_size={12} text_color={:muted} />)], else: []

    ~MOB"""
    <Box background={:surface} border_color={:border} border_width={1.5} corner_radius={16} padding_left={14} padding_right={14} padding_top={10} padding_bottom={10} fill_width={true} on_tap={tap}>
      <Row gap={12} align={:center} fill_width={true}>
        <Box width={28} align="center" fill_width={false}>{glyph}</Box>
        <Column gap={2} weight={1}>
          <Text text={title} font={:ui_medium} text_size={15} text_color={:on_surface} />
          {note}
        </Column>
      </Row>
    </Box>
    """
  end

  @doc """
  A horizontal meter (token usage): an 8 pt rounded track on the page ground,
  filled to `fraction` (0.0–1.0) in `color`.
  """
  @spec meter(float(), Mob.Theme.color_value()) :: map()
  def meter(fraction, color) do
    filled = fraction |> max(0.001) |> min(1.0)
    rest = max(1.0 - filled, 0.001)

    ~MOB"""
    <Box height={8} corner_radius={4} background={:background} fill_width={true}>
      <Row height={8} fill_width={true}>
        <Box height={8} corner_radius={4} background={color} weight={filled} />
        <Spacer size={0} weight={rest} />
      </Row>
    </Box>
    """
  end

  @doc "The bar colors for the active mode and the given cover."
  @spec chrome(Palette.cover()) :: map()
  def chrome(cover), do: Palette.chrome(MobBezalel.mode() || :dark, cover)

  # Scales an ARGB color's alpha (used for inactive tabs on the bar).
  defp fade(argb, factor) do
    alpha = round(Bitwise.bsr(argb, 24) * factor)
    Bitwise.bor(Bitwise.bsl(alpha, 24), Bitwise.band(argb, 0xFFFFFF))
  end

  # A theme color token at reduced opacity (the disabled send button).
  defp dim(token, factor), do: fade(Map.fetch!(Mob.Theme.current(), token), factor)

  defp reject_nil(map), do: map |> Enum.reject(fn {_k, v} -> is_nil(v) end) |> Map.new()
end
