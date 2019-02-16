defmodule BankAccountingWeb.Router do
  use BankAccountingWeb, :router
  alias BankAccounting.Guardian

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug Guardian.AuthPipeline
  end

  scope "/api/v1", BankAccountingWeb do
    pipe_through :api

    post "/sign_up", UserController, :create
    post "/sign_in", UserController, :login
  end

  scope "/api/v1", BankAccountingWeb do
    pipe_through [:api, :authenticated]

    get "/myself", UserController, :show
    resources "/accounts", AccountController, except: [:new, :edit]
  end
end
