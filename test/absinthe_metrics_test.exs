defmodule AbsintheMetricsTest do
  use ExUnit.Case
  doctest AbsintheMetrics

  defmodule Backend do
    @behaviour AbsintheMetrics

    def field(_, _, _, _ \\ []), do: :ok
    def instrument(schema, object, field, {status, _}, _time), do: send(self(), {schema, object, field, status})
  end

  defmodule Instrumenter do
    use AbsintheMetrics, adapter: Backend
  end

  defmodule Types do
    use Absinthe.Schema.Notation
    @user %{email: "foo@bar.se"}
    @comments [%{body: "First"}, %{body: "Second"}]

    object :user do
      field :email, :string
    end

    object :comment do
      field :body, :string
      field :author, :user do
        resolve fn _, _ -> {:ok, @user} end
      end
    end

    object :post do
      field :title, :string
      field :author, :user do
        resolve fn _, _ -> {:ok, @user} end
      end
      field :comments, list_of(:comment) do
        resolve fn _, _ -> {:ok, @comments} end
      end
    end
  end

  defmodule Schema do
    use Absinthe.Schema
    @post %{title: "A post"}
    import_types Types

    def middleware(middlewares, field, object), do: Instrumenter.instrument(middlewares, field, object)

    query do
      field :post, :post do
        resolve fn _, _ -> {:ok, @post} end
      end
    end
  end

  setup_all do
    Instrumenter.install(Schema)
    :ok
  end

  test "instruments calls" do
    {:ok, _} = """
    {
      post {
        title,
        author {
          email
        },
        comments {
          body,
          author {
            email
          }
        }
      }
    }
    """
    |> Absinthe.run(Schema)

    assert_receive {"absinthe_metrics_test_schema", :query, :post, :ok}
    assert_receive {"absinthe_metrics_test_schema", :post, :author, :ok}
    assert_receive {"absinthe_metrics_test_schema", :post, :comments, :ok}
    assert_receive {"absinthe_metrics_test_schema", :comment, :author, :ok}
  end

end
