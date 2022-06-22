defmodule EstacionaAqui.Repo do
  use Ecto.Repo,
    otp_app: :estaciona_aqui,
    adapter: Ecto.Adapters.Postgres
end
