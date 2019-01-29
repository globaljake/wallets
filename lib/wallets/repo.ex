defmodule Wallets.Repo do
  use Ecto.Repo,
    otp_app: :wallets,
    adapter: Ecto.Adapters.Postgres
end
