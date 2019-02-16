defmodule BankAccountingWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias BankAccounting.Auth
  import BankAccounting.Guardian, only: [encode_and_sign: 3]

  @default_user_attrs %{
    password: "@password",
    password_confirmation: "@password",
    username: "some username"
  }

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias BankAccountingWeb.Router.Helpers, as: Routes
      import BankAccountingWeb.ConnCase

      # The default endpoint for testing
      @endpoint BankAccountingWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(BankAccounting.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(BankAccounting.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def create_and_sign_in_user(attrs \\ @default_user_attrs) do
    {:ok, user} = Auth.create_user(attrs)
    {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

    {user, token}
  end
end
