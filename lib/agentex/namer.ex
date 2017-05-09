defmodule Agentex.Namer do
  @moduledoc false
  defmacro __using__(opts) do
    quote bind_quoted: [prefix: opts[:module]] do
      @module_prefix prefix

      @spec fqname(Atom.t, (String.t | Atom.t | List.t | nil)) :: Atom.t
      def fqname(module \\ @module_prefix || __MODULE__, suffix)
      def fqname(module, nil), do: module
      def fqname(module, suffix) when is_atom(suffix),
        do: fqname(module, suffix |> Atom.to_string() |> String.trim_leading("Elixir."))
      def fqname(module, suffix) when is_list(suffix),
        do: fqname(module, suffix[:name])
      def fqname(module, suffix) when is_binary(suffix) do
        to_trim = module
                  |> Atom.to_string
                  |> String.trim_leading("Elixir.")
                  |> Kernel.<>(".")
        modules = suffix
                  |> String.trim_leading(to_trim)
                  |> String.split(".")
                  |> Enum.map(&String.capitalize/1)
        Module.concat([module | modules])
      end
    end
  end

  ##############################################################################

  def tables(default) do
    :agentex
    |> Application.get_env(:tables, default)
    |> Enum.map(&Agentex.Namer.table/1)
  end

  def table([term]), do: table(term)
  def table(term) when is_atom(term) do
    term
    |> Atom.to_string
    |> table
  end
  def table(term) when is_binary(term) do
    term
    |> String.trim_leading("Elixir.")
    |> String.split("_")
    |> Enum.map(&Regex.replace(~r/(\A|_+)./,
                  &1, fn m ->
                        m |> String.last() |> String.upcase()
                      end))
    |> Module.concat()
  end
end
