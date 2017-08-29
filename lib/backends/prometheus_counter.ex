defmodule AbsintheMetrics.Backend.PrometheusCounter do
  @behaviour AbsintheMetrics
  use Prometheus

  def field(object, field, _args \\ []), do: true = Counter.declare([name: to_metric(object, field),
                                                                     help: "Metrics for GraphQL resolver: #{to_metric(object, field)}",
                                                                     labels: [:status]])

  def instrument(object, field, {status, _}, _time), do: Counter.inc([name: to_metric(object, field), labels: [status]])

  defp to_metric(:query, field), do: "#{field}_total"
  defp to_metric(object, field), do: "#{object}_#{field}_total" |> String.to_atom()
end
