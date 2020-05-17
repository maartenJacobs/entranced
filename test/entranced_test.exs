defmodule EntrancedTest do
  use ExUnit.Case
  doctest Entranced

  test "greets the world" do
    assert Entranced.hello() == :world
  end
end
