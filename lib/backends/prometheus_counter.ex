if Code.ensure_loaded?(Prometheus) do
  defmodule AbsintheMetrics.Backend.PrometheusCounter do
    @behaviour AbsintheMetrics
    use Prometheus

    def field(schema, object, field, _args \\ []), do: true = Counter.declare([name: to_metric(schema, object, field),
                                                                       help: "Metrics for GraphQL resolver: #{to_metric(schema, object, field)}",
                                                                       labels: [:status]])

    def instrument(schema, object, field, {status, _}, _time), do: Counter.inc([name: to_metric(schema, object, field), labels: [status]])

    defp to_metric(schema, :query, field), do: "#{schema}_#{field}_total"
    defp to_metric(schema, object, field), do: "#{schema}_#{object}_#{field}_total" |> String.to_atom()
  end
end
