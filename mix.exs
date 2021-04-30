defmodule AccessNotation.MixProject do
  use Mix.Project

  def project do
    [
      app: :access_notation,
      version: "0.1.0",
      elixir: "~> 1.11",
      erlc_paths: ["src", "gen"],
      compilers: [:gleam | Mix.compilers()],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gleam_stdlib, "~> 0.14.0"},
      {:mix_gleam, "~> 0.1.0"}
    ]
  end
end
