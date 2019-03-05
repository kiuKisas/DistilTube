defmodule DistilTubeTest do
  use ExUnit.Case
  doctest DistilTube

  test "greets the world" do
    assert DistilTube.hello() == :world
  end
end
