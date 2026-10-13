defmodule MobBezalel.System do
  @moduledoc """
  Follows the phone: `MobBezalel.Dark` when the OS is in dark mode,
  `MobBezalel.Light` otherwise (the design's "System" theme option).

  `Mob.Theme.set/1` snapshots the theme. To follow an OS appearance change
  while a screen is showing, have the screen subscribe and re-set it; the
  repaint after `handle_info/2` picks up the new palette:

      def mount(_params, _session, socket) do
        Mob.Device.subscribe(:appearance)
        Mob.Theme.set(MobBezalel.System)
        ...
      end

      def handle_info({:mob_device, :color_scheme_changed, _}, socket) do
        if following_system?(socket), do: Mob.Theme.set(MobBezalel.System)
        {:noreply, socket}
      end

  Also register it with mob's watcher
  (`Mob.Theme.AdaptiveWatcher.register_adaptive(MobBezalel.System)`) so screens
  that don't subscribe pick the change up on their next render; with mob
  ≤ 0.9.17 the watcher never re-resolves (fixed in MOB-479).

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
