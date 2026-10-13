defmodule MobBezalel.Night do
  @moduledoc """
  Bezalel night: low glare for reading in the dark. Warm black ground,
  amber ink capped near 6:1 contrast, no blue anywhere.

      use Mob.App, theme: MobBezalel.Night
      Mob.Theme.set(MobBezalel.Night)

  Token mapping and font tokens: see `MobBezalel`.
  """

  @doc "Returns the Bezalel night theme."
  @spec theme() :: Mob.Theme.t()
  def theme, do: MobBezalel.theme(:night)
end
