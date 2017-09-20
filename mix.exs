defmodule AbsintheMetrics.Mixfile do
  use Mix.Project

  def project do
    [
      app: :absinthe_metrics,
      version: "0.5.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "absinthe_metrics",
      source_url: "https://github.com/soundtrackyourbrand/absinthe-metrics"
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
      {:absinthe, "~> 1.3"},
      {:prometheus_ex, "~> 1.4", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp description do
    "Pluggable metrics for Absinthe GraphQL."
  end

  defp package do
    [
      name: "absinthe_metrics",
      licenses: ["MIT"],
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Fredrik Wärnsberg"],
      links: %{"GitHub" => "https://github.com/soundtrackyourbrand/absinthe-metrics"}
    ]
  end
end
