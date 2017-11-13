defmodule KinesisElixirTest do
  use ExUnit.Case
  doctest KinesisElixir

  test "greets the world" do
    assert KinesisElixir.hello() == :world
  end
end
