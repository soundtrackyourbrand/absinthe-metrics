# AbsintheMetrics

[![Build Status](https://travis-ci.org/soundtrackyourbrand/absinthe-metrics.svg?branch=master)](https://travis-ci.org/soundtrackyourbrand/absinthe-metrics)
[![Module Version](https://img.shields.io/hexpm/v/absinthe_metrics.svg)](https://hex.pm/packages/absinthe_metrics)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/absinthe_metrics/)
[![Total Download](https://img.shields.io/hexpm/dt/absinthe_metrics.svg)](https://hex.pm/packages/absinthe_metrics)
[![License](https://img.shields.io/hexpm/l/absinthe_metrics.svg)](https://github.com/soundtrackyourbrand/absinthe-metrics/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/soundtrackyourbrand/absinthe-metrics.svg)](https://github.com/soundtrackyourbrand/absinthe-metrics/commits/master)

AbsintheMetrics provides time (or counter) based metrics for your [Absinthe](https://github.com/absinthe-graphql/absinthe) resolvers to allow you to keep track of where your queries are spending their time.

Usage is fairly straight forward:

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

The package can be installed by adding `:absinthe_metrics` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:absinthe_metrics, "~> 0.9.0"}
  ]
end
```

## Copyright and License

Copyright (c) 2017 Soundtrack Your Brand

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the [LICENSE.md](./LICENSE.md) file for more details.
