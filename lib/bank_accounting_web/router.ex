defmodule BankAccountingWeb.Router do
  use BankAccountingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", BankAccountingWeb do
    pipe_through :api

    post "/sign_up", UserController, :create
    post "/sign_in", UserController, :login
  end
end
