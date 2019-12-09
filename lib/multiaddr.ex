defmodule Multiaddr do
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
    with {:ok, _} <- Codec.validate_bytes(bytes) do
      {:ok, %Multiaddr{bytes: bytes}}
    end
  end

  def equal(%Multiaddr{} = maddr1, %Multiaddr{} = maddr2) do
    maddr1 == maddr2
  end

  def bytes(%Multiaddr{bytes: maddr_bytes} = _maddr) do
    maddr_bytes
  end

  def string(%Multiaddr{bytes: maddr_bytes} = _maddr) do
    with {:ok, string} <- Codec.bytes_to_string(maddr_bytes) do
      string
    end
  end

  def protocols(%Multiaddr{bytes: maddr_bytes} = _maddr) do
    with {:ok, maddr_protocols} <- Codec.extract_protocols(maddr_bytes) do
      maddr_protocols
    end
  end

  def encapsulate(
        %Multiaddr{bytes: maddr_1_bytes} = _maddr_1,
        %Multiaddr{bytes: maddr_2_bytes} = _maddr_2
      ) do
    with {:ok, _} <- Codec.validate_bytes(maddr_1_bytes),
         {:ok, _} <- Codec.validate_bytes(maddr_2_bytes) do
      {:ok, %Multiaddr{bytes: maddr_1_bytes <> maddr_2_bytes}}
    end
  end

  def decapsulate(%Multiaddr{bytes: maddr_1_bytes} = _maddr_1, %Multiaddr{} = maddr_2) do
    protocol =
      maddr_2
      |> protocols()
      |> Enum.at(0)

    with {:ok, value} = value_for_protocol(maddr_2, protocol.name),
         {:ok, index, _value} <- Codec.find_protocol_by_value(maddr_1_bytes, protocol, value) do
      {:ok, %Multiaddr{bytes: split_binary(maddr_1_bytes, 0..(index - 1))}}
    end
  end

  def value_for_protocol(%Multiaddr{bytes: maddr_bytes} = _maddr, name) when is_binary(name) do
    with {:ok, protocol} <- Map.fetch(Prot.protocols_by_name(), name),
         {:ok, _index, value} <- Codec.find_protocol(maddr_bytes, protocol) do
      {:ok, value}
    else
      _ -> {:error, "Invalid protocol"}
    end
  end

  def value_for_protocol(%Multiaddr{} = maddr, code) when is_integer(code) do
    with {:ok, protocol} <- Map.fetch(Prot.protocols_by_code(), code),
         {:ok, _index, value} <- Codec.find_protocol(maddr.bytes, protocol) do
      {:ok, value}
    else
      _ -> {:error, "Invalid protocol"}
    end
  end
end
