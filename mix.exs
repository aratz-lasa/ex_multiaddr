defmodule ExMultiaddr.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_multiaddr,
      version: "0.1.0",
      elixir: "~> 1.9",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "ex_multiaddr",
      source_url: "https://github.com/aratz-lasa/ex_multiaddr"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:varint],
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "An Elixir implementation of Multiaddr"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "ex_multiaddr",
      # These are the default files included in the package
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/aratz-lasa/ex_multiaddr"}
    ]
  end

  defp deps do
    [
      {:varint, "~> 1.0.0"},
      {:ex_multihash, "~> 2.0"},
      {:basefiftyeight, "~> 0.1.0"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
