defmodule KinesisElixir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kinesis_elixir,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {KinesisElixir.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_aws, "~> 2.0"},
      {:ex_aws_kinesis, "~> 2.0"},
      {:gen_stage, "~> 0.12"},
      {:poison, "~> 3.1"},
      {:hackney, "~> 1.10"}
    ]
  end
end
