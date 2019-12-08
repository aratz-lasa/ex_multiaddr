defmodule Multiaddr do
  import Multiaddr.Varint
  import Multiaddr.Utils
  alias Multiaddr.Protocol, as: Prot
  alias Multiaddr.Codec

  defstruct [:bytes]

  def new_multiaddr_from_string(string) when is_binary(string) do
    with {:ok, bytes} <- Codec.string_to_bytes(string) do
      {:ok, %Multiaddr{bytes: bytes}}
    end
  end

  def new_multiaddr_from_bytes(bytes) when is_binary(bytes) do
    with {:ok, _protocols} <- Codec.validate_bytes(bytes) do
      {:ok, %Multiaddr{bytes: bytes}}
    end
  end

  def equal(%Multiaddr{} = maddr1, %Multiaddr{} = maddr2) do
    maddr1 == maddr2
  end

  def bytes(%Multiaddr{} = maddr) do
    maddr.bytes
  end

  def string(%Multiaddr{} = maddr) do
    with {:ok, string} <- Codec.bytes_to_string(maddr.bytes) do
      string
    end
  end

  def protocols(%Multiaddr{} = maddr) do
    with {:ok, maddr_protocols} <- Codec.extract_protocols(maddr.bytes) do
      maddr_protocols
    end
  end

  def encapsulate(%Multiaddr{} = maddr) do
  end

  def decapsulate(%Multiaddr{} = maddr) do
  end

  def value_for_protocol(%Multiaddr{} = maddr, protocol) when is_binary(protocol) do
    with {:ok, code} <- Map.fetch(Prot.protocols_by_name(), protocol) do
      value_for_protocol(maddr, code)
    else
      _ -> {:error, "Invalid protocol"}
    end
  end

  def value_for_protocol(%Multiaddr{} = maddr, code) when is_integer(code) do
    Codec.find_protocol_value(maddr.bytes, code)
  end
end
