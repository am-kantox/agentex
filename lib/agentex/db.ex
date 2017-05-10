defmodule Agentex.DB do
  @moduledoc false
  defmacro __using__(opts \\ []) do
    quote do
      Module.register_attribute __MODULE__, :database, accumulate: false
      Module.put_attribute __MODULE__, :database, unquote(opts[:database]) || AgentexDB

      Module.register_attribute __MODULE__, :table, accumulate: true
      Module.put_attribute __MODULE__, :table, unquote(opts[:table]) || [Kv]

      database = Module.get_attribute(__MODULE__, :database)
      tables = Agentex.Namer.tables(Module.get_attribute(__MODULE__, :table))
      deftables = Enum.map(tables, fn table_name ->
        quote do
          deftable unquote(table_name), [:key, :value], type: :ordered_set, index: [:value] do
          end
        end
      end)

      defdatabase unquote(Module.get_attribute(__MODULE__, :database)) do
        unquote(quote do
          Enum.map(unquote(tables), fn table_name ->
            quote do
              deftable unquote(table_name), [:key, :value], type: :ordered_set, index: [:value] do
              end
            end
          end)
        end)
      end
    end
  end
end
