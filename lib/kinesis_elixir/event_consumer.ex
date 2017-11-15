defmodule KinesisElixir.EventConsumer do
  use GenStage

  def start_link(wait_time) do
    IO.puts "started the event consumer"
    GenStage.start_link(__MODULE__, wait_time, name: __MODULE__)
  end

  def init(wait_time) do
    {:consumer, wait_time}
  end

  def handle_events(events, _from, wait_time) do
    IO.puts "got events in EventConsumer:"
    IO.inspect(events)

    Process.sleep(wait_time)

    {:noreply, [], wait_time}
  end
end
