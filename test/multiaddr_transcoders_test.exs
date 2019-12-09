defmodule MultiaddrTranscoderTest do
  use ExUnit.Case
  doctest Multiaddr.Transcoder

  test "ip4" do
    ip4_string = "127.0.0.1"
    {:ok, ip4_bytes} = Multiaddr.Transcoder.ip4_string_to_bytes(ip4_string)
    {:ok, ip4_string_trans} = Multiaddr.Transcoder.ip4_bytes_to_string(ip4_bytes)
    assert ip4_string == ip4_string_trans

    ip4_string_wrong = "127.0.0.1.0"
    {:error, _} = Multiaddr.Transcoder.ip4_string_to_bytes(ip4_string_wrong)
  end

  test "port" do
    port_string = "673"
    {:ok, port_bytes} = Multiaddr.Transcoder.port_string_to_bytes(port_string)
    {:ok, port_string_trans} = Multiaddr.Transcoder.port_bytes_to_string(port_bytes)
    assert port_string == port_string_trans

    port_string_wrong = "10000000"
    {:error, _} = Multiaddr.Transcoder.port_string_to_bytes(port_string_wrong)
  end

  test "ip6" do
    ip6_string = "1:0:0:0:0:0:0:1"
    {:ok, ip6_bytes} = Multiaddr.Transcoder.ip6_string_to_bytes(ip6_string)
    {:ok, ip6_string_trans} = Multiaddr.Transcoder.ip6_bytes_to_string(ip6_bytes)
    assert ip6_string == ip6_string_trans

    ip6_string_wrong = "1::1::1"
    {:error, _} = Multiaddr.Transcoder.ip6_string_to_bytes(ip6_string_wrong)
  end
end
