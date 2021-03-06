defmodule KinesisElixir.ShardIterator do
  use GenStage

  @stream_name Application.fetch_env!(:kinesis_elixir, :stream_name)
  # Client API

  def start(%{"ShardId" => shard_id}) do
    GenStage.start_link(__MODULE__, shard_id, name: name(shard_id))
  end

  defp name(shard_id) do
    {:global, shard_id}
  end

  def init(shard_id) do
    {:producer, {shard_id, get_iterator(shard_id), 0}}
  end

  defp get_iterator(shard_id) do
    ExAws.Kinesis.get_shard_iterator(@stream_name, shard_id, :latest)
    |> ExAws.request!
    |> match_iterator
  end

  defp match_iterator(%{"ShardIterator" => iterator}), do: iterator

  # Server Callbacks

  def handle_demand(demand, {shard_id, iterator, 0}) do
    IO.puts "Demand received #{demand} with no buffered_demand"

    {records, next_iterator, new_total_demand} = fetch_new_records(iterator, demand, shard_id)

    {:noreply, records, {shard_id, next_iterator, new_total_demand}}
  end

  def handle_demand(demand, {shard_id, iterator, buffered_demand}) do
    IO.puts "Demand received #{demand} with some buffered_demand"
    {:noreply, [], {shard_id, iterator, demand + buffered_demand}}
  end

  def handle_cast(:check_for_new_records, {_shard_id, _iterator, 0} = state), do: {:noreply, [], state}

  def handle_cast(:check_for_new_records, {shard_id, iterator, buffered_demand}) do
    Process.sleep(200) # Kinesis throws a ProvisionedThroughputExceededException if we request more than 5 times a second per shard

    {records, next_iterator, new_total_demand} = fetch_new_records(iterator, buffered_demand, shard_id)

    {:noreply, records, {shard_id, next_iterator, new_total_demand}}
  end

  defp fetch_new_records(iterator, requested, shard_id) do
    {records, next_iterator} = get_records(iterator, requested, shard_id)
    record_count = Enum.count(records)

    if record_count < requested, do: GenStage.cast(self(), :check_for_new_records)
    {records, next_iterator, requested - record_count}
  end

  defp get_records(iterator, count, shard_id) do
    ExAws.Kinesis.get_records(iterator, limit: count) |> ExAws.request |> extract_info(shard_id)
  end

  defp extract_info({:ok, %{"Records" => records, "NextShardIterator" => next_iterator}}, _shard_id) do
    {records, next_iterator}
  end

  defp extract_info({:error, {:http_error, 400, %{"__type" => "ExpiredIteratorException"}}}, shard_id) do
    {[], get_iterator(shard_id)}
  end
end
