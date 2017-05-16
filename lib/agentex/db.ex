defmodule Agentex.DB do
  @moduledoc false
  defmacro __using__(opts \\ []) do
    quote do
      use Amnesia
      require Logger

      env = unquote(opts[:config]) || :agentex
      database = Agentex.Namer.macroset!(env, :database, __MODULE__, unquote(opts[:database]) || Agentex.Simple)
      @bags apply(database, :tables, []) # Agentex.Namer.macroset!(env, :bags, __MODULE__, apply(database, :tables, []))

      Logger.info "★★★ Declared bags: #{inspect {database, @bags}}"
    end
  end
end
