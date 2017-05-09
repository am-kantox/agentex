defmodule Agentex.DB do
  @moduledoc false
  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts, module: __MODULE__] do
      Module.register_attribute __MODULE__, :database, accumulate: false
      Module.put_attribute __MODULE__, :database, opts[:database] || AgentexDB

      Module.register_attribute __MODULE__, :table, accumulate: true
      Module.put_attribute __MODULE__, :table, opts[:table] || [Kv]

      database = Module.get_attribute(__MODULE__, :database)
      tables = Agentex.Namer.tables(Module.get_attribute(__MODULE__, :table))
      deftables = Enum.map(tables, fn table_name ->
        quote do
          deftable unquote(table_name), [:key, :value], type: :ordered_set, index: [:value] do
          end
        end
      end)

      quote do
        defdatabase unquote(database) do
          unquote(deftables)
        end
      end
    end
  end
end
