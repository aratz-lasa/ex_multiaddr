defmodule ExMultiaddrTest do
  use ExUnit.Case
  doctest Multiaddr

  test "Create Multiaddr" do
    maddr_string = "/ip4/127.0.0.1/tcp/80"
    {:ok, maddr_1} = Multiaddr.new_multiaddr_from_string(maddr_string)
    {:ok, maddr_2} = Multiaddr.new_multiaddr_from_bytes(maddr_1.bytes)
    assert Multiaddr.equal(maddr_1, maddr_2)
  end

  test "Get Multiaddr Protocols" do
    maddr = create_multiaddr("/ip4/127.0.0.1/tcp/80")

    protocols = Multiaddr.protocols(maddr)
    assert length(protocols) == 2
    {:ok, prot_1} = Enum.fetch(protocols, 0)
    {:ok, prot_2} = Enum.fetch(protocols, 1)
    assert prot_1 == Multiaddr.Protocol.proto_ip4()
    assert prot_2 == Multiaddr.Protocol.proto_tcp()
  end

  test "Get protocol value" do
    maddr = create_multiaddr("/ip4/127.0.0.1/tcp/80")

    {:ok, ip4_value} = Multiaddr.value_for_protocol(maddr, Multiaddr.Protocol.proto_ip4().code)
    {:ok, tcp_value} = Multiaddr.value_for_protocol(maddr, Multiaddr.Protocol.proto_tcp().code)
    assert ip4_value == "127.0.0.1"
    assert tcp_value == "80"
  end

  test "Multiadrr to string" do
    maddr = create_multiaddr("/ip4/127.0.0.1/tcp/80")

    string = Multiaddr.string(maddr)
    assert string == "/ip4/127.0.0.1/tcp/80"
  end

  test "Encapsulate" do
    maddr_1 = create_multiaddr("/ip4/127.0.0.1")
    maddr_2 = create_multiaddr("/tcp/80")

    {:ok, maddr} = Multiaddr.encapsulate(maddr_1, maddr_2)
    assert maddr.bytes == create_multiaddr("/ip4/127.0.0.1/tcp/80").bytes
  end

  test "Decapsulate" do
    maddr_1 = create_multiaddr("/ip4/127.0.0.1/tcp/80")
    maddr_2 = create_multiaddr("/tcp/80")

    {:ok, maddr} = Multiaddr.decapsulate(maddr_1, maddr_2)
    assert maddr.bytes == create_multiaddr("/ip4/127.0.0.1").bytes
  end

  defp create_multiaddr(maddr_string) when is_binary(maddr_string) do
    with {:ok, maddr} <- Multiaddr.new_multiaddr_from_string(maddr_string) do
      maddr
    end
  end
end
