defmodule AbsintheMetricsTest do
  use ExUnit.Case
  doctest AbsintheMetrics

  defmodule Backend do
    @behaviour AbsintheMetrics

    def field(object, field, args \\ []) do
      send(self(), {:install, object, field})
    end

    def instrument(object, field, {status, _}, _time) do
      send(self(), {object, field, status})
    end
  end

  defmodule Instrumenter do
    use AbsintheMetrics, adapter: Backend
  end

  defmodule Types do
    use Absinthe.Schema.Notation
    @user %{email: "foo@bar.se"}
    @comments [%{body: "First"}, %{body: "Second"}]

    object :user do
      field(:email, :string)
    end

    object :comment do
      field(:body, :string)

      field :author, :user do
        resolve(fn _, _ -> {:ok, @user} end)
      end
    end

    object :post do
      field(:title, :string)

      field :author, :user do
        resolve(fn _, _ -> {:ok, @user} end)
      end

      field :comments, list_of(:comment) do
        resolve(fn _, _ -> {:ok, @comments} end)
      end
    end
  end

  defmodule Schema do
    use Absinthe.Schema
    @post %{title: "A post"}
    import_types(Types)

    def middleware(middlewares, field, object),
      do: Instrumenter.instrument(middlewares, field, object)

    query do
      field :post, :post do
        resolve(fn _, _ -> {:ok, @post} end)
      end
    end
  end

  test "instruments calls" do
    Instrumenter.install(Schema)

    {:ok, _} =
      """
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

    assert_receive {:install, :query, :post}
    assert_receive {:install, :post, :author}
    assert_receive {:install, :post, :comments}
    assert_receive {:install, :comment, :author}

    assert_receive {:query, :post, :ok}
    assert_receive {:post, :author, :ok}
    assert_receive {:post, :comments, :ok}
    assert_receive {:comment, :author, :ok}
  end
end
