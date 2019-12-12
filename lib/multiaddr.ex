defmodule Multiaddr do
  import Multiaddr.Utils
  alias Multiaddr.Protocol, as: Prot
  alias Multiaddr.Codec
  alias Multiaddr.Error

  defstruct [:bytes]

  def new_multiaddr_from_string(string) when is_binary(string) do
    case Codec.string_to_bytes(string) do
      {:ok, bytes} -> {:ok, %Multiaddr{bytes: bytes}}
      error -> error
    end
  end

  def new_multiaddr_from_bytes(bytes) when is_binary(bytes) do
    case Codec.validate_bytes(bytes) do
      {:ok, _bytes} -> {:ok, %Multiaddr{bytes: bytes}}
      error -> error
    end
  end

  def equal(%Multiaddr{} = maddr1, %Multiaddr{} = maddr2) do
    maddr1 == maddr2
  end

  def bytes(%Multiaddr{bytes: maddr_bytes} = _maddr) do
    maddr_bytes
  end

  def string(%Multiaddr{bytes: maddr_bytes} = _maddr) do
    case Codec.bytes_to_string(maddr_bytes) do
      {:ok, string} -> string
      {:error, reason} -> raise Multiaddr.Error, reason: reason
    end
  end

  def protocols(%Multiaddr{bytes: maddr_bytes} = _maddr) do
    case Codec.list_protocols(maddr_bytes) do
      {:ok, maddr_protocols} -> maddr_protocols
      {:error, reason} -> raise Multiaddr.Error, reason: reason
    end
  end

  def encapsulate(
        %Multiaddr{bytes: maddr_1_bytes} = maddr_1,
        %Multiaddr{bytes: maddr_2_bytes} = _maddr_2
      ) do
    with false <- contains_path_protocol?(maddr_1),
         {:ok, _bytes} <- Codec.validate_bytes(maddr_1_bytes),
         {:ok, _bytes} <- Codec.validate_bytes(maddr_2_bytes) do
      {:ok, %Multiaddr{bytes: maddr_1_bytes <> maddr_2_bytes}}
    else
      true -> {:error, {:invalid_order, "Path must be last protocol"}}
      {:error, reason} -> raise Multiaddr.Error, reason: reason
    end
  end

  defp contains_path_protocol?(%Multiaddr{} = maddr) do
    maddr
    |> protocols()
    |> Enum.any?(fn p -> p.path end)
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
      :error -> {:error, {:invalid_protocol_name, name}}
      error -> error
    end
  end

  def value_for_protocol(%Multiaddr{} = maddr, code) when is_integer(code) do
    with {:ok, protocol} <- Map.fetch(Prot.protocols_by_code(), code),
         {:ok, _index, value} <- Codec.find_protocol(maddr.bytes, protocol) do
      {:ok, value}
    else
      :error -> {:error, {:invalid_protocol_code, code}}
      error -> error
    end
  end

  def format_error(error), do: Error.format_error(error)
end
