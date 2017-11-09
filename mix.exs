defmodule Agentex.Mixfile do
  use Mix.Project

  @application :agentex

  def project do
    [
      app: @application,
      version: "0.2.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [applications: [:logger, :amnesia], mod: {Agentex, []}]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_stage, "~> 0.11"},

      {:poolboy, "~> 1.5"},
      {:json, "~> 1.0"},
      {:amnesia, "~> 0.2"},

      {:credo, "~> 0.8", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.11", only: :dev},
      {:mock, "~> 0.2", only: :test},
      {:test_cluster_task, "~> 0.3", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    Distributed `Agent` implementation, providing multi-node agents on top of Mnesia.
    """
  end

  defp package do
    [
     name: @application,
     files: ~w|lib mix.exs README.md|,
     maintainers: ["Aleksei Matiushkin"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/am-kantox/#{@application}",
              "Docs" => "https://hexdocs.pm/#{@application}"}]
  end
end
