defmodule BankAccounting.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :bank_accounting,
    module: BankAccounting.Guardian,
    error_handler: BankAccounting.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
