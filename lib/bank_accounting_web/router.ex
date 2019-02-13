defmodule BankAccountingWeb.Router do
  use BankAccountingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BankAccountingWeb do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
  end
end
