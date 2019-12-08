defmodule Multiaddr.Codec do
  import Multiaddr.Varint
  import Multiaddr.Utils
  alias Multiaddr.Protocol, as: Prot

  defp validate_bytes(bytes, protocols_list) when bytes == "" do
    {:ok, protocols_list}
  end


  defp validate_bytes(bytes, protocols_list) when is_binary(bytes) do
    {:ok, {i, code}} = read_varint(bytes)
    bytes = split_binary(bytes, i..-1)

    with {:ok, protocol} <- Map.fetch(Prot.protocols_by_code, code),
         true <- byte_size(bytes) >= protocol.size do
      validate_bytes(split_binary(bytes, protocol.size..-1), [protocols_list, protocol])
    else
      _ ->
        {:error, "Invalid Multiaddr"}
    end
  end


  def validate_bytes(bytes) when is_binary(bytes) do
    validate_bytes(bytes, [])
  end


  def string_to_bytes(string) when is_binary(string) do
    string = String.trim_trailing(string, "/")
    split_string = String.split(string, "/")
    with {:ok, ""} <- Enum.fetch(split_string, 0) do
      string_to_bytes(Enum.slice(split_string, 1..-1))
    end
  end


  defp string_to_bytes(string_split, bytes) when string_split == [] and is_binary(bytes) do
    {:ok, bytes}
  end


  defp string_to_bytes(string_split, bytes) when is_list(string_split) and is_binary(bytes) do
    with {:ok, protocol_name} <- Enum.fetch(string_split, 0),
         {:ok, protocol} <- Map.fetch(Prot.protocols_by_name, protocol_name),
         {:ok, protocol_bytes} <- protocol.transcoder.string_to_bytes(Enum.at(string_split, 0)) do
      bytes = bytes <> protocol.vcode
      string_to_bytes(Enum.slice(string_split, 2..-1), bytes)
    else
      _ ->
        {:error, "Invalid Multiaddr string"}
    end
  end

end
