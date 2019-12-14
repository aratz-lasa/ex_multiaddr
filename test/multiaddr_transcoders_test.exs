defmodule MultiaddrTranscoderTest do
  use ExUnit.Case

  test "text" do
    text_string = "default"
    {:ok, text_bytes} = Multiaddr.Transcoder.text_string_to_bytes(text_string)
    assert {:ok, text_string} == Multiaddr.Transcoder.text_bytes_to_string(text_bytes)
    assert {:ok, text_string} = Multiaddr.Transcoder.text_validate_bytes(text_string)

    text_string_wrong = "default/"
    {:error, _} = Multiaddr.Transcoder.text_validate_bytes(text_string_wrong)
  end

  test "ip4" do
    ip4_string = "127.0.0.1"
    {:ok, ip4_bytes} = Multiaddr.Transcoder.ip4_string_to_bytes(ip4_string)
    assert {:ok, ip4_string} == Multiaddr.Transcoder.ip4_bytes_to_string(ip4_bytes)

    ip4_string_wrong = "127.0.0.1.0"
    {:error, _} = Multiaddr.Transcoder.ip4_string_to_bytes(ip4_string_wrong)
  end

  test "port" do
    port_string = "673"
    {:ok, port_bytes} = Multiaddr.Transcoder.port_string_to_bytes(port_string)
    assert {:ok, port_string} == Multiaddr.Transcoder.port_bytes_to_string(port_bytes)

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

  test "path" do
    path_string = "/home/multiaddr"
    {:ok, path_bytes} = Multiaddr.Transcoder.path_string_to_bytes(path_string)
    {:ok, path_string_trans} = Multiaddr.Transcoder.path_bytes_to_string(path_bytes)
    assert path_string == path_string_trans
  end

  test "p2p" do
    {:ok, multihash} = Multihash.encode(:sha1, :crypto.hash(:sha, "/multihash/address"))
    p2p_string = B58.encode58(multihash)
    {:ok, p2p_bytes} = Multiaddr.Transcoder.p2p_string_to_bytes(p2p_string)
    {:ok, p2p_string_trans} = Multiaddr.Transcoder.p2p_bytes_to_string(p2p_bytes)
    assert p2p_string == p2p_string_trans
  end
end
