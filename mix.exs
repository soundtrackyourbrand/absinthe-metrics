defmodule AbsintheMetrics.Mixfile do
  use Mix.Project

  @source_url "https://github.com/soundtrackyourbrand/absinthe-metrics"
  @version "1.1.0"

  def project do
    [
      app: :absinthe_metrics,
      version: @version,
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      name: "absinthe_metrics"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:absinthe, "~> 1.5"},
      {:prometheus_ex, "~> 3.0", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "absinthe_metrics",
      description: "Pluggable metrics for Absinthe GraphQL.",
      licenses: ["MIT"],
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Fredrik Wärnsberg"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "master",
      formatters: ["html"]
    ]
  end
end
