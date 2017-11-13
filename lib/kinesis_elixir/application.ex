defmodule KinesisElixir.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {KinesisElixir.StreamSupervisor, []},
    ]

    opts = [strategy: :one_for_one, name: KinesisElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
