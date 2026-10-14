defmodule MobBezalel.MixProject do
  use Mix.Project

  @source_url "https://github.com/GenericJam/mob_bezalel"

  def project do
    [
      app: :mob_bezalel,
      version: "0.1.0",
      elixir: "~> 1.17",
      deps: deps(),
      aliases: aliases(),
      description:
        "Bezalel's look for Mob apps: linen, leather and gold themes (light, dark, night) " <>
          "with EB Garamond, Instrument Sans and Frank Ruhl Libre bundled",
      package: package(),
      docs: [
        main: "readme",
        extras: ["README.md"]
      ],
      source_url: @source_url
    ]
  end

  def application do
    [extra_applications: []]
  end

  defp aliases do
    # `mix setup` after cloning installs deps and activates the shared git
    # hooks (.githooks): format / Credo --strict / compile run on every push
    # and the full suite when mix.exs changes — the same gate CI enforces.
    [setup: ["deps.get", "cmd git config core.hooksPath .githooks"]]
  end

  defp deps do
    [
      # 0.9.18: MobBezalel.System follows the OS light/dark flip (MOB-479).
      {:mob, "~> 0.9.18"},
      # Test-only: the manifest test runs the real style validator, which
      # knows `assets.fonts` from 0.7.25 (MOB-476).
      {:mob_dev, "~> 0.7.25", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_slop, "~> 0.4.2", only: [:dev, :test], runtime: false},
      {:jump_credo_checks, "~> 0.1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT", "OFL-1.1"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib priv mix.exs README* LICENSE*)
    ]
  end
end
