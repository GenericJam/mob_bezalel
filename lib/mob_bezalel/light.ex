defmodule MobBezalel.Light do
  @moduledoc """
  Bezalel light: linen ground, umber call to action, bronze accent.

      use Mob.App, theme: MobBezalel.Light
      Mob.Theme.set(MobBezalel.Light)

  Token mapping and font tokens: see `MobBezalel`.
  """

  @doc "Returns the Bezalel light theme."
  @spec theme() :: Mob.Theme.t()
  def theme, do: MobBezalel.theme(:light)
end
