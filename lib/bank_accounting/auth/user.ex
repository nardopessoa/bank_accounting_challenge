defmodule BankAccounting.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :password_encrypted, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password_encrypted])
    |> validate_required([:username, :password_encrypted])
    |> unique_constraint(:username)
  end
end
