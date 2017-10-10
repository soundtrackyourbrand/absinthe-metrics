if Code.ensure_loaded?(Prometheus) do
  defmodule AbsintheMetrics.Backend.PrometheusHistogram do
    @behaviour AbsintheMetrics
    @query_metric_name :graphql_query_duration_milliseconds
    @field_metric_name :graphql_fields_duration_milliseconds
    use Prometheus

    def field(:query, _field, buckets: buckets) do
      _ = Histogram.declare([name: @query_metric_name,
                             labels: [:query, :status],
                             buckets: buckets,
                             help: "Resolution time for GraphQL queries"])
    end

    def field(object, field, buckets: buckets) do
      _ = Histogram.declare([name: @field_metric_name,
                             labels: [:object, :field, :status],
                             buckets: buckets,
                             help: "Metrics for GraphQL field resolvers"])
    end

    def instrument(:query, field, {status, _}, time) do
      Histogram.observe([name: @query_metric_name, labels: [field, status]], time)
    end

    def instrument(object, field, {status, _}, time) do
      Histogram.observe([name: @field_metric_name, labels: [object, field, status]], time)
    end
  end
end
