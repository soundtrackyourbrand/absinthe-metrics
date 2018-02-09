defmodule AbsintheMetrics.Backend.Echo do
  @behaviour AbsintheMetrics
  require Logger

  def instrument(schema, object, field, {status, _result}, time) do
    metric = "#{schema}_#{object}_#{field}"
    case status do
      :error -> Logger.warn("#{metric} failed (took: #{inspect time})")
      :ok -> Logger.info("#{metric} took: #{inspect time}")
    end
  end

  def field(schema, object, field, _args \\ []) do
    Logger.info("install field #{schema}_#{object}_#{field}")
  end
end
