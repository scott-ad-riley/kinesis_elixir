defmodule KinesisElixir.EventParser do
  use GenStage

  # Client API

  def start_link(state) do
    IO.puts "started the event parser"
    GenStage.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:producer_consumer, state}
  end

  # Server Callbacks

  def handle_events(events, _from, state) do
    {:noreply, parse_events(events, []), state}
  end

  defp parse_events([], parsed_events), do: parsed_events

  defp parse_events([event | unparsed_events], parsed_events) do
    new_parsed_events = [parse_event(event) | parsed_events]
    parse_events(unparsed_events, new_parsed_events)
  end

  defp parse_event(%{"Data" => encoded_data} = event) do
    %{ event | "Data" => Base.decode64!(encoded_data) |> Poison.decode! }
  end
end
