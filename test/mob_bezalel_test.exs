defmodule MobBezalelTest do
  use ExUnit.Case, async: false

  alias MobBezalel.Palette

  @style_dir Path.expand("..", __DIR__)

  test "style manifest validates via the real mob_dev validator (default: Dark)" do
    assert {:ok, m} = MobDev.Style.load(@style_dir)
    assert {:ok, ^m} = MobDev.Style.validate(m)
    assert m.name == :mob_bezalel
    assert m.theme == MobBezalel.Dark
  end

  test "the manifest bundles exactly the font files the tokens reference, and they exist" do
    {:ok, m} = MobDev.Style.load(@style_dir)

    assert Enum.sort(m.assets.fonts) == MobBezalel.font_paths()

    for path <- m.assets.fonts do
      assert File.regular?(Path.join(@style_dir, path)), "missing #{path}"
    end
  end

  # iOS resolves `Font.custom(name:)` by PostScript name and silently falls
  # back to the system font on a mismatch, so the token must match the file.
  test "every font token's iOS name is the bundled file's PostScript name" do
    for {token, %{ios: ios}} <- MobBezalel.fonts() do
      file = Enum.find(MobBezalel.font_paths(), &(Path.basename(&1, ".ttf") == ios))
      assert file, "#{token}: no bundled file named #{ios}.ttf"
      assert postscript_name(Path.join(@style_dir, file)) == ios
    end
  end

  test "every theme builds and is settable through Mob.Theme.set/1" do
    before = Mob.Theme.current()
    on_exit(fn -> Mob.Theme.set(before) end)

    for mod <- MobBezalel.all() do
      assert %Mob.Theme{fonts: %{default: _}} = mod.theme()
      assert :ok = Mob.Theme.set(mod)
      assert Mob.Theme.current() == mod.theme()
    end
  end

  test "each mode keeps its identity: ground and call to action" do
    assert MobBezalel.Light.theme().background == 0xFFF3ECDD
    assert MobBezalel.Dark.theme().primary == 0xFFC9A04A
    assert MobBezalel.Night.theme().background == 0xFF0C0A08
  end

  test "night mode carries no blue: every role is warm (red above blue)" do
    for {role, argb} <- Palette.roles(:night) do
      assert channel(argb, 16) > channel(argb, 0), "#{role} #{Integer.to_string(argb, 16)}"
    end
  end

  test "paper bars take the mode's own ground; leather bars stay leather" do
    for mode <- Palette.modes() do
      paper = Palette.chrome(mode, :paper)
      assert paper.bar == Palette.roles(mode).background
      assert paper.stitch == nil
      refute Palette.chrome(mode, :leather).bar == paper.bar
    end
  end

  # The selected segment (Theme, Cover) and the primary button put on_* text
  # on a fill. 3:1 is the floor for interface chrome; night's design pairing
  # of on_cta on the accent measured 1.4:1 and was unreadable on device.
  test "labels on the accent and call-to-action fills reach 3:1 in every mode" do
    for mode <- Palette.modes(), {fill, ink} <- [accent: :on_accent, cta: :on_cta] do
      r = Palette.roles(mode)
      ratio = contrast(Map.fetch!(r, fill), Map.fetch!(r, ink))
      assert ratio >= 3.0, "#{mode} #{ink} on #{fill}: #{Float.round(ratio, 2)}:1"
    end
  end

  # A block's Markdown takes the active mode's colors (a theme change
  # re-renders it), and every role in it stays legible on its ground: the
  # block's (page ground for a summary, surface for an aside) or the code's.
  test "a block's Markdown follows the active mode and reads at 3:1 in it" do
    before = Mob.Theme.current()
    on_exit(fn -> Mob.Theme.set(before) end)

    for mode <- Palette.modes(), {kind, ground} <- [summary: :background, aside: :surface] do
      :ok = Mob.Theme.set(MobBezalel.theme_module(mode))
      r = Palette.roles(mode)
      s = MobBezalel.UI.markdown_style(kind)

      assert s.text_color == if(kind == :summary, do: r.ink, else: r.muted)

      pairs = [
        text: {s.text_color, Map.fetch!(r, ground)},
        link: {s.link_color, Map.fetch!(r, ground)},
        quote: {s.quote_color, Map.fetch!(r, ground)},
        code: {s.code_color, s.code_background}
      ]

      for {role, {fg, bg}} <- pairs do
        ratio = contrast(fg, bg)
        assert ratio >= 3.0, "#{mode} #{kind} #{role}: #{Float.round(ratio, 2)}:1"
      end
    end
  end

  test "a block's Markdown faces are the theme's, named per platform" do
    fonts = MobBezalel.fonts()
    s = MobBezalel.UI.markdown_style(:summary)

    for platform <- [:ios, :android] do
      faces = Map.fetch!(s, platform)
      assert faces.font_regular == fonts.default[platform]
      assert faces.font_bold == fonts.ui_semibold[platform]
      assert faces.font_heading == fonts.display[platform]
    end
  end

  test "an open block shows a node body in place of its text; a closed one hides it" do
    body = %{type: :text, props: %{text: "BODY"}, children: []}
    tap = {self(), :tap}

    assert body in nodes(MobBezalel.UI.block("SUMMARY", "First", body, true, tap, :summary))
    refute body in nodes(MobBezalel.UI.block("SUMMARY", "First", body, false, tap, :summary))

    texts = &for(%{type: :text, props: %{text: t}} <- nodes(&1), do: t)
    assert "rest" in texts.(MobBezalel.UI.block("THINKING", "First", "rest", true, tap))

    assert texts.(MobBezalel.UI.block("THINKING", "First", "", true, tap)) == [
             "THINKING",
             "First"
           ]
  end

  describe "materials pieces" do
    setup do
      before = Mob.Theme.current()
      :ok = Mob.Theme.set(MobBezalel.Dark)
      on_exit(fn -> Mob.Theme.set(before) end)
      %{tap: {self(), :tap}}
    end

    test "every icon name renders a non-empty Canvas" do
      for name <- MobBezalel.Icons.names() do
        assert %{type: :canvas, props: %{width: 20, draw: [_ | _]}} =
                 MobBezalel.Icons.icon(name, 20, :on_surface)
      end

      for name <- ~w(materials plus mic speaker image camera video audio file close play stop)a,
          do: assert(name in MobBezalel.Icons.names())
    end

    test "send strength follows send_enabled, else the blank check", %{tap: tap} do
      dimmed = send_bg(MobBezalel.UI.composer("", "Ask", tap, :send))
      assert dimmed != :primary
      assert send_bg(MobBezalel.UI.composer("hi", "Ask", tap, :send)) == :primary

      assert send_bg(MobBezalel.UI.composer("", "Ask", tap, :send, send_enabled: true)) ==
               :primary

      assert send_bg(MobBezalel.UI.composer("hi", "Ask", tap, :send, send_enabled: false)) ==
               dimmed
    end

    test "composer places leading, actions and above around the field", %{tap: tap} do
      plus = MobBezalel.UI.icon_button(:plus, :attach, id: "plus")
      mic = MobBezalel.UI.icon_button(:mic, :mic)
      chip = MobBezalel.UI.attachment_chip(:file, "a.pdf", :remove)

      plain = MobBezalel.UI.composer("", "Ask", tap, :send)
      assert %{type: :row} = plain

      tree =
        MobBezalel.UI.composer("", "Ask", tap, :send,
          leading: [plus],
          actions: [mic],
          above: [chip]
        )

      assert %{type: :column, children: [^chip, %{type: :row, children: row}]} = tree

      assert [^plus, %{type: :text_field}, ^mic, %{on_tap: :send} | _] =
               Enum.map(row, &tap_or_node/1)
    end

    test "icon_button: active takes the call-to-action fill, idle the surface" do
      idle = MobBezalel.UI.icon_button(:mic, :mic, id: "mic")
      assert %{background: :surface, border_color: :border, id: "mic", width: 44} = idle.props
      assert [%{type: :canvas, props: %{width: 20}}] = idle.children

      active = MobBezalel.UI.icon_button(:mic, :mic, active: true, size: 36)
      assert %{background: :primary, width: 36} = active.props
      refute Map.has_key?(active.props, :border_color)
      assert hd(active.children).props.draw |> hd() |> Map.get(:color) == :on_primary
    end

    test "attachment_chip: close tap only with on_remove; long names stay short" do
      taps = &for(%{props: %{on_tap: t}} <- nodes(&1), do: t)
      assert taps.(MobBezalel.UI.attachment_chip(:file, "a.pdf", :remove)) == [:remove]
      assert taps.(MobBezalel.UI.attachment_chip(:file, "a.pdf", nil)) == []

      long = String.duplicate("very long name ", 10) <> "notes.pdf"

      [label] =
        for %{type: :text, props: %{text: t}} <-
              nodes(MobBezalel.UI.attachment_chip(:file, long, nil)),
            do: t

      assert String.length(label) <= 24
      assert String.ends_with?(label, ".pdf")
    end

    test "menu_row taps as a whole and omits a nil note" do
      texts = &for(%{type: :text, props: %{text: t}} <- nodes(&1), do: t)
      row = MobBezalel.UI.menu_row(:camera, "Take photo", "Camera", :photo)
      assert row.props.on_tap == :photo
      assert texts.(row) == ["Take photo", "Camera"]
      assert texts.(MobBezalel.UI.menu_row(:camera, "Take photo", nil, :photo)) == ["Take photo"]
    end

    test "tab_bar keeps four tabs as designed and narrows for five" do
      tabs = for l <- ~w(Study Conversations Workshop Settings), do: {l, :study, :t}
      four = MobBezalel.UI.tab_bar(tabs, 0, :leather)
      assert four.props.padding_left == 18
      assert Enum.all?(labels(four), &(&1.text_size == 11 and &1.max_lines == 1))

      five =
        MobBezalel.UI.tab_bar(List.insert_at(tabs, 2, {"Materials", :materials, :t}), 0, :leather)

      assert five.props.padding_left < 18
      assert Enum.all?(labels(five), &(&1.text_size < 11 and &1.max_lines == 1))
    end
  end

  defp send_bg(tree) do
    [bg] = for %{props: %{on_tap: :send, background: bg}} <- nodes(tree), do: bg
    bg
  end

  defp tap_or_node(%{type: :box, props: %{on_tap: :send}}), do: %{on_tap: :send}
  defp tap_or_node(node), do: node

  defp labels(tree), do: for(%{type: :text, props: p} <- nodes(tree), do: p)

  defp nodes(%{children: children} = node), do: [node | Enum.flat_map(children, &nodes/1)]
  defp nodes(list) when is_list(list), do: Enum.flat_map(list, &nodes/1)
  defp nodes(_other), do: []

  defp channel(argb, shift), do: Bitwise.band(Bitwise.bsr(argb, shift), 0xFF)

  defp contrast(a, b) do
    [hi, lo] = Enum.sort([luminance(a), luminance(b)], :desc)
    (hi + 0.05) / (lo + 0.05)
  end

  defp luminance(argb) do
    [r, g, b] =
      for shift <- [16, 8, 0] do
        c = channel(argb, shift) / 255
        if c <= 0.03928, do: c / 12.92, else: :math.pow((c + 0.055) / 1.055, 2.4)
      end

    0.2126 * r + 0.7152 * g + 0.0722 * b
  end

  # Reads name ID 6 (PostScript name) from a TrueType file's `name` table.
  defp postscript_name(path) do
    <<_sfnt::32, num_tables::16, _::binary-size(6), rest::binary>> = bin = File.read!(path)

    name_offset =
      Enum.find_value(0..(num_tables - 1), fn i ->
        <<tag::binary-size(4), _sum::32, offset::32, _len::32>> = binary_part(rest, i * 16, 16)
        if tag == "name", do: offset
      end)

    <<_format::16, count::16, string_offset::16, records::binary>> =
      binary_part(bin, name_offset, byte_size(bin) - name_offset)

    Enum.find_value(0..(count - 1), fn i ->
      <<platform::16, _enc::16, _lang::16, name_id::16, len::16, off::16>> =
        binary_part(records, i * 12, 12)

      if name_id == 6 and platform == 3 do
        bin
        |> binary_part(name_offset + string_offset + off, len)
        |> :unicode.characters_to_binary({:utf16, :big})
      end
    end)
  end
end
