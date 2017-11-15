defmodule KinesisElixir.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {KinesisElixir.StreamSupervisor, []},
      {KinesisElixir.EventParser, 5},
      {KinesisElixir.EventConsumer, 1000},
    ]

    opts = [strategy: :one_for_one, name: KinesisElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def link_up_the_things do
    GenStage.sync_subscribe(KinesisElixir.EventConsumer, to: KinesisElixir.EventParser)
    iterator_pids = for {_, pid, _, _} <- KinesisElixir.StreamSupervisor.kids, do: pid
    for p <- iterator_pids, do: GenStage.sync_subscribe(KinesisElixir.EventParser, to: p)
  end
end
