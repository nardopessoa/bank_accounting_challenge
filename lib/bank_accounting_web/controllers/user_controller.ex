defmodule BankAccountingWeb.UserController do
  use BankAccountingWeb, :controller

  alias BankAccounting.Auth
  alias BankAccounting.Auth.User
  alias BankAccounting.Guardian

  action_fallback BankAccountingWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Auth.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("access_token.json", access_token: token)
    end
  end

  def show(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "show.json", user: user)
  end

  def login(conn, %{"username" => username, "password" => password}) do
    case Auth.token_sign_in(username, password) do
      {:ok, token, _claims} -> render(conn, "access_token.json", access_token: token)
      error -> error
    end
  end
end
