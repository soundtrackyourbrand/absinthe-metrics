# AbsintheMetrics

[![Build Status](https://travis-ci.org/soundtrackyourbrand/absinthe-metrics.svg?branch=master)](https://travis-ci.org/soundtrackyourbrand/absinthe-metrics)

AbsintheMetrics provides time (or counter) based metrics for your [Absinthe](https://github.com/absinthe-graphql/absinthe) resolvers to allow you to keep track of where your queries are spending their time.

Usage is fairly straight forward,

```elixir
defmodule MyApp.Instrumenter do
  use AbsintheMetrics,
    adapter: AbsintheMetrics.Backend.PrometheusHistogram,
    # See prometheus.ex for more examples
    arguments: [buckets: {:exponential, 250, 1.5, 7}]
end

defmodule MyApp.Schema do
  use Absinthe.Schema
  def middleware(middlewares, field, object) do
    MyApp.Instrumenter.instrument(middlewares, field, object)
  end
end

# in application.ex

defmodule MyApp do
  def start(_type, _args) do
    # initialize all available metrics in your schema
    MyApp.Instrumenter.install(MyApp.Schema)
    # ...
  end
end

```


How metrics are gathered depends on the backend, but for `PrometheusHistogram` the format is `#{object}_#{field}_duration_microseconds` or `query_field_duration_microseconds` for root queries.


### Adding backends
Adding additional backends is pretty straight forward, you just need to implement the `AbsintheMetrics` behaviour,

```elixir
defmodule LogBackend do
  @behaviour AbsintheMetrics
  require Logger

  # Called during application start to allow you to register
  # fields with your TSDB
  def field(object, field, _args \\ []) do
    Logger.info("install field #{object}_#{field}")
  end

  # Called every time a value is observed
  # status can be :ok or :error
  def instrument(object, field, {status, _result}, time) do
    metric = "#{object}_#{field}"
    case status do
      :error -> Logger.warn("#{metric} failed (took: #{inspect time})")
      :ok -> Logger.info("#{metric} took: #{inspect time}")
    end
  end
end
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `absinthe_metrics` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:absinthe_metrics, "~> 0.9.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/absinthe_metrics](https://hexdocs.pm/absinthe_metrics).

