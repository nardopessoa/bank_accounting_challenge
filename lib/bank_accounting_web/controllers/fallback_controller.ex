defmodule BankAccountingWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BankAccountingWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankAccountingWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(BankAccountingWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, error}) when error in [:unauthorized, :invalid_password] do
    conn
    |> put_status(error)
    |> json(%{error: "Login error"})
  end
end
