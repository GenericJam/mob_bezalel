defmodule MobBezalel.Dark do
  @moduledoc """
  Bezalel dark: the leather study Bible. Warm near-black ground, gold call
  to action, oxblood user bubble. The package default.

      use Mob.App, theme: MobBezalel.Dark
      Mob.Theme.set(MobBezalel.Dark)

  Token mapping and font tokens: see `MobBezalel`.
  """

  @doc "Returns the Bezalel dark theme."
  @spec theme() :: Mob.Theme.t()
  def theme, do: MobBezalel.theme(:dark)
end
