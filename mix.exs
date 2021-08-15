defmodule Campinas.MixProject do
  use Mix.Project

  def project() do
    [
      app: :campinas,
      version: "0.0.1",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      description: """
      Delimited continuations library using shift/reset and
      continuation-passing style
      """
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application() do
    [
      # extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:ex_doc, "~> 0.25.1", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      maintainers: ["Thales Macedo Garitezi"],
      licenses: ["GPL-3.0-or-later"],
      links: %{
        "GitHub" => "https://github.com/thalesmg/campinas"
      }
    ]
  end
end
