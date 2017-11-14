defmodule KinesisElixir.Publisher do

  @stream_name Application.fetch_env!(:kinesis_elixir, :stream_name)

  def send_once(count \\ 10) do
    for n <- 1..count do
      ExAws.Kinesis.put_record(@stream_name, Integer.to_string(:rand.uniform(4294967296), 32), Poison.encode!(build_record(n))) |> ExAws.request!
    end
  end

  defp build_record(number) do
    %{
      "number" => number,
      "someRandomData" => random_string()
    }
  end

  defp random_string do
    Integer.to_string(:rand.uniform(4294967296), 32) <>
    Integer.to_string(:rand.uniform(4294967296), 32) <>
    Integer.to_string(:rand.uniform(4294967296), 32) <>
    Integer.to_string(:rand.uniform(4294967296), 32)
  end
end
