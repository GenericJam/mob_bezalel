defmodule MobBezalel.Icons do
  @moduledoc """
  The design's icons as `<Canvas>` nodes: the Lucide glyphs it uses (stroke
  2.25, round caps) and the Bezalel mark (2a, plumb bob + flame). Each takes a
  size in points and a color (theme token or ARGB).

      MobBezalel.Icons.icon(:study, 24, :on_background)
      MobBezalel.Icons.mark(26, MobBezalel.Palette.overlay().mark_gold, cutout: bar_color)

  Lucide arcs and the mark's curves are sampled into polylines (Canvas paths
  are point lists); at icon sizes the difference doesn't show.
  """

  import Mob.Canvas, only: [line: 5, path: 2, circle: 4]

  @names [
    :study,
    :conversations,
    :workshop,
    :settings,
    :send,
    :more,
    :chevron_down,
    :chevron_up,
    :hammer
  ]

  @doc "The icon names `icon/3` knows."
  @spec names() :: [atom()]
  def names, do: @names

  @doc "A Lucide icon from the design, `size` points square, stroked in `color`."
  @spec icon(atom(), number(), term(), keyword()) :: map()
  def icon(name, size, color, opts \\ []) when name in @names do
    width = Keyword.get(opts, :stroke, 2.25)
    ops = ops(name, %{color: color, width: width, cap: :round, join: :round})
    canvas(size, ops)
  end

  @doc """
  The Bezalel mark: plumb line, collar and bob in `color`, the flame and slit
  cut out in `:cutout` (the color behind the mark).
  """
  @spec mark(number(), term(), keyword()) :: map()
  def mark(size, color, opts) do
    cutout = Keyword.fetch!(opts, :cutout)
    k = 24 / 100

    scale = fn points -> Enum.map(points, fn {x, y} -> {x * k, y * k} end) end

    ops = [
      path(scale.([{49.2, 0}, {50.8, 0}, {50.8, 21}, {49.2, 21}]),
        color: color,
        fill: true,
        closed: true
      ),
      path(scale.([{44, 21}, {56, 21}, {56, 28}, {44, 28}]),
        color: color,
        fill: true,
        closed: true
      ),
      path(scale.(bob()), color: color, fill: true, closed: true),
      path(scale.(flame()), color: cutout, fill: true, closed: true),
      path(scale.([{49.1, 61}, {50.9, 61}, {50.9, 87}, {49.1, 87}]),
        color: cutout,
        fill: true,
        closed: true
      )
    ]

    canvas(size, ops)
  end

  # Ops are written in Lucide's 24-unit square and scaled to `size`: a
  # canvas's coordinates are in the units of its own width/height.
  defp canvas(size, ops) do
    %{
      type: :canvas,
      props: %{width: size, height: size, draw: Enum.map(ops, &scale_to(&1, size))},
      children: []
    }
  end

  defp scale_to(op, size) do
    s = size / 24

    op
    |> scale_points(s)
    |> Map.update(:width, nil, &(&1 && &1 * s))
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp scale_points(%{op: :path, points: points} = op, s),
    do: %{op | points: Enum.map(points, fn [x, y] -> [x * s, y * s] end)}

  defp scale_points(%{op: :line} = op, s),
    do: %{op | x1: op.x1 * s, y1: op.y1 * s, x2: op.x2 * s, y2: op.y2 * s}

  defp scale_points(%{op: :circle} = op, s), do: %{op | x: op.x * s, y: op.y * s, r: op.r * s}

  defp ops(:study, st) do
    # message-square: rounded rect 3,3 → 21,17 with a tail to 3,21.
    [
      path(
        [{5, 3}, {19, 3}] ++
          arc(19, 5, 2, -90, 0) ++
          [{21, 15}] ++
          arc(19, 15, 2, 0, 90) ++ [{7, 17}, {3, 21}, {3, 5}] ++ arc(5, 5, 2, 180, 270),
        Keyword.new(Map.put(st, :closed, true))
      )
    ]
  end

  defp ops(:conversations, st) do
    # library: three spines and a leaning book.
    [{16, 6, 20, 20}, {12, 6, 12, 20}, {8, 8, 8, 20}, {4, 4, 4, 20}]
    |> Enum.map(fn {x1, y1, x2, y2} -> line(x1, y1, x2, y2, Keyword.new(st)) end)
  end

  defp ops(:settings, st) do
    # sliders-horizontal.
    [
      {21, 4, 14, 4},
      {10, 4, 3, 4},
      {21, 12, 12, 12},
      {8, 12, 3, 12},
      {21, 20, 16, 20},
      {12, 20, 3, 20},
      {14, 2, 14, 6},
      {8, 10, 8, 14},
      {16, 18, 16, 22}
    ]
    |> Enum.map(fn {x1, y1, x2, y2} -> line(x1, y1, x2, y2, Keyword.new(st)) end)
  end

  defp ops(:send, st) do
    [line(12, 19, 12, 5, Keyword.new(st)), path([{5, 12}, {12, 5}, {19, 12}], Keyword.new(st))]
  end

  defp ops(:more, st) do
    for x <- [5, 12, 19], do: circle(x, 12, 1.8, color: st.color, fill: true)
  end

  defp ops(:chevron_down, st), do: [path([{6, 9}, {12, 15}, {18, 9}], Keyword.new(st))]
  defp ops(:chevron_up, st), do: [path([{6, 15}, {12, 9}, {18, 15}], Keyword.new(st))]

  defp ops(name, st) when name in [:workshop, :hammer] do
    # hammer: the handle runs down-left from the head; the head is the
    # claw-and-face block at the top right.
    handle = [{15, 12}, {6.5, 20.5}] ++ arc(5, 19, 2.12, 45, 225) ++ [{12, 9}]

    head = [
      {12, 9},
      {12, 8.4},
      {9.92, 3.78},
      {9, 2.96},
      {12.07, 2.96},
      {16.01, 4.6},
      {18.73, 7.34},
      {18.73, 8.2},
      {19.66, 10.45},
      {20.91, 11.7},
      {18.73, 13.87},
      {16.47, 11.96},
      {14, 11.96}
    ]

    [
      path(handle, Keyword.new(st)),
      path(head, Keyword.new(st)),
      line(17.64, 15, 22, 10.64, Keyword.new(st))
    ]
  end

  # Points along a circular arc (degrees, 0 = +x, clockwise on screen).
  defp arc(cx, cy, r, from, to, steps \\ 6) do
    for i <- 0..steps do
      a = (from + (to - from) * i / steps) * :math.pi() / 180
      {cx + r * :math.cos(a), cy + r * :math.sin(a)}
    end
  end

  # The mark's outline (design path `M50 92L31 51C29 41 35 33 44 30L56 30C65 33 71 41 69 51Z`).
  defp bob do
    [{50, 92}, {31, 51}] ++
      cubic({31, 51}, {29, 41}, {35, 33}, {44, 30}) ++
      [{56, 30}] ++ cubic({56, 30}, {65, 33}, {71, 41}, {69, 51})
  end

  # The flame cut-out (`M50 38C54 44 56.5 47.5 56.5 51.5C56.5 55.5 53.5 58 50 58C46.5 58 43.5 55.5 43.5 51.5C43.5 47.5 46 44 50 38Z`).
  defp flame do
    cubic({50, 38}, {54, 44}, {56.5, 47.5}, {56.5, 51.5}) ++
      cubic({56.5, 51.5}, {56.5, 55.5}, {53.5, 58}, {50, 58}) ++
      cubic({50, 58}, {46.5, 58}, {43.5, 55.5}, {43.5, 51.5}) ++
      cubic({43.5, 51.5}, {43.5, 47.5}, {46, 44}, {50, 38})
  end

  defp cubic({x0, y0}, {x1, y1}, {x2, y2}, {x3, y3}, steps \\ 10) do
    for i <- 1..steps do
      t = i / steps
      u = 1 - t

      {u * u * u * x0 + 3 * u * u * t * x1 + 3 * u * t * t * x2 + t * t * t * x3,
       u * u * u * y0 + 3 * u * u * t * y1 + 3 * u * t * t * y2 + t * t * t * y3}
    end
  end
end
