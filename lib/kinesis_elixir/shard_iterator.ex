defmodule KinesisElixir.ShardIterator do
  use GenServer

  @stream_name Application.fetch_env!(:kinesis_elixir, :stream_name)
  # Client API

  def start(%{"ShardId" => shard_id}) do
    GenServer.start_link(__MODULE__, shard_id, name: name(shard_id))
  end

  def name(shard_id) do
    {:global, shard_id}
  end

  def init(shard_id) do
    {:ok, get_iterator(shard_id)}
  end

  def get_iterator(shard_id) do
    ExAws.Kinesis.get_shard_iterator(@stream_name, shard_id, :latest)
    |> ExAws.request!
    |> match_iterator
  end

  def match_iterator(%{"ShardIterator" => iterator}), do: iterator

  # Server Callbacks

  def handle_call(:get_state, _from, iterator) do
    {:reply, iterator, iterator}
  end

  def handle_call(:get_records, _from, iterator) do
    %{"Records" => records, "NextShardIterator" => next_iterator} = get_records(iterator)
    {:reply, records, next_iterator}
  end

  def get_records(iterator) do
    ExAws.Kinesis.get_records(iterator) |> ExAws.request!
  end
end
