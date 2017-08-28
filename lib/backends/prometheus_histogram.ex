defmodule AbsintheMetrics.Backend.PrometheusHistogram do
  @behaviour AbsintheMetrics
  use Prometheus

  def field(object, field, buckets: buckets) do
    true = Histogram.declare([name: to_metric(object, field),
                              labels: [:status],
                              buckets: buckets,
                              help: "Metrics for GraphQL resolver: #{to_metric(object, field)}"])
  end

  def instrument(object, field, {status, _}, time), do: Histogram.observe([name: to_metric(object, field), labels: [status]], time)

  defp to_metric(:query, field), do: field
  defp to_metric(object, field), do: "#{object}_#{field}" |> String.to_atom()
end
