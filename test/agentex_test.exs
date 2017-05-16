defmodule AgentexTest do
  use ExUnit.Case
  doctest Agentex

  use Agentex.DB

  setup do
    Amnesia.stop
    Amnesia.Schema.destroy

    Amnesia.start
    apply(@database, :create!, [])
  end
end
