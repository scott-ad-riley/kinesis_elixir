defmodule KinesisElixir.StreamSupervisor do
  use Supervisor

  @stream_name Application.fetch_env!(:kinesis_elixir, :stream_name)

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    child_specs = get_iterators() |> map_to_child_specs()
    Supervisor.init(child_specs, strategy: :one_for_one)
  end

  def get_iterators() do
    get_stream()
    |> extract_shards()
  end

  def map_to_child_specs(shards) do
    shards
    |> Enum.reduce([],
        fn shard, acc_list ->
          [{shard, iterator_process_name(acc_list)} | acc_list]
        end
      )
    |> Enum.map(
      fn {shard, unique_name} ->
        Supervisor.child_spec(
          KinesisElixir.ShardIterator,
          start: {KinesisElixir.ShardIterator, :start, [shard]},
          id: unique_name,
        )
      end
    )
  end

  def iterator_process_name(list) do
    String.to_atom("iterator_" <> Integer.to_string(length(list)))
  end

  def kids do
    Supervisor.which_children(__MODULE__)
  end

  def get_all_records do
    for {_, iterator_pid, _, _} <- kids() do
      GenServer.call(iterator_pid, :get_records)
    end
  end

  def get_stream() do
    ExAws.Kinesis.describe_stream(@stream_name) |> ExAws.request!
  end

  def extract_shards(%{"StreamDescription" => %{ "Shards" => shards}}) do
    shards
  end
end
