defmodule Multiaddr do
  import Multiaddr.Varint
  import Multiaddr.Utils
  alias Multiaddr.Protocol, as: Prot
  alias Multiaddr.Codec

  defstruct [:bytes]

  def new_multiaddr(raw_bytes) when is_binary(raw_bytes) do
    if String.valid?(raw_bytes) do  # String input
      with {:ok, bytes} <- Codec.string_to_bytes(raw_bytes) do
        {:ok, %Multiaddr{bytes: bytes}}
      end
    else  # Raw binary input
      with {:ok, _} <- Codec.validate_bytes(raw_bytes) do
        {:ok, %Multiaddr{bytes: raw_bytes}}
      end
    end
  end

  def equal(%Multiaddr{} = maddr1, %Multiaddr{} = maddr2) do
    maddr1 == maddr2
  end

  def bytes(%Multiaddr{} = maddr) do
    maddr.bytes
  end

  def string(%Multiaddr{} = maddr) do

  end

  def protocols(%Multiaddr{} = maddr) do
    Codec.validate_bytes(maddr.bytes)
  end

  def encapsulate(%Multiaddr{} = maddr) do
  end

  def decapsulate(%Multiaddr{} = maddr) do
  end

  def value_for_protocol(%Multiaddr{} = maddr, code) when is_integer(code) do

  end
end
