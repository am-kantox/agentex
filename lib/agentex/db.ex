defmodule Agentex.DB do
  @moduledoc false
  defmacro __using__(_opts \\ []) do
    quote do
      use Amnesia
      require Logger

      defdatabase Simple do
        deftable Kv, [:key, :value], type: :ordered_set, index: [:value] do
          @type t :: %Kv{key: String.t | Atom.t, value: any}
        end
      end

      Logger.info "★★★ Declared tables: #{inspect apply(Simple, :tables, [])}"
    end
  end
end
