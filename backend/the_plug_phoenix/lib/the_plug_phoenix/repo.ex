defmodule ThePlugPhoenix.Repo do
  use Ecto.Repo,
    otp_app: :the_plug_phoenix,
    adapter: Ecto.Adapters.Postgres
end
