defmodule MobBezalel.System do
  @moduledoc """
  Follows the phone: `MobBezalel.Dark` when the OS is in dark mode,
  `MobBezalel.Light` otherwise (the design's "System" theme option).

  `Mob.Theme.set/1` snapshots the theme, so to re-resolve when the OS
  appearance changes, register this module with mob's watcher once:

      Mob.Theme.AdaptiveWatcher.register_adaptive(MobBezalel.System)
      Mob.Theme.set(MobBezalel.System)

  The design notes "Night turns on after sunset"; that needs the time and
  place, so it's the app's call: `Mob.Theme.set(MobBezalel.Night)`.
  """

  @doc "Returns the Bezalel dark or light theme for the current OS appearance."
  @spec theme() :: Mob.Theme.t()
  def theme do
    case Mob.Theme.color_scheme() do
      :dark -> MobBezalel.theme(:dark)
      _ -> MobBezalel.theme(:light)
    end
  end
end
