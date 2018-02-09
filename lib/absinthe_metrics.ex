defmodule AbsintheMetrics do
  alias Absinthe.Resolution
  @behaviour Absinthe.Middleware

  @callback instrument(schema :: String.t, object :: atom, field :: atom, result :: any, time :: non_neg_integer) :: any
  @callback field(schema :: String.t, object :: String.t, field :: String.t, args :: []) :: any

  defmacro __using__(opts) do
    adapter = Keyword.get(opts, :adapter, AbsintheMetrics.Backend.Echo)
    arguments = Keyword.get(opts, :arguments, [])
    wrapped_arguments = case arguments do
      [] -> []
      arguments -> [arguments]
    end

    quote do
      def instrument([], _field, _obj), do: []

      def instrument(middleware, %{__reference__: %{module: Absinthe.Type.BuiltIns.Introspection}}, _obj), do: middleware

      def instrument(middleware, field, _obj)  do
        [{{AbsintheMetrics, :call}, {unquote(adapter), unquote(arguments)}} | middleware]
      end

      def install(schema) do
        instrumented? = fn %{middleware: middleware} = field ->
          middleware
          |> Enum.any?(fn
            {{AbsintheMetrics, :call}, _} -> true
            _ -> false
          end)
        end

        for %{fields: fields} = object <- Absinthe.Schema.types(schema),
            {k, %Absinthe.Type.Field{name: name, identifier: id} = field} <- fields,
            instrumented?.(field) do
          apply(unquote(adapter), :field, ["", object.identifier, field.identifier] ++ unquote(wrapped_arguments))
        end
      end
    end
  end

  def call(%Resolution{state: :unresolved} = res, {adapter, _}) do
    schema = String.replace(Macro.underscore(res.schema), "/", "_")
    now = :erlang.monotonic_time()
    %{res | middleware: res.middleware ++ [{{AbsintheMetrics, :after_resolve}, start_at: now, adapter: adapter, field: res.definition.schema_node.identifier, object: res.parent_type.identifier, schema: schema}]}
  end

  def after_resolve(%Resolution{state: :resolved} = res, [start_at: start_at, adapter: adapter, field: field, object: object, schema: schema]) do
    end_at = :erlang.monotonic_time()
    diff =  end_at - start_at
    result = case res.errors do
      [] -> {:ok, res.value}
      errors -> {:error, errors}
    end
    adapter.instrument(schema, object, field, result, diff)

    res
  end
end
