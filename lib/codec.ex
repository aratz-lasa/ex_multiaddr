defmodule Multiaddr.Codec do
  import Multiaddr.Utils.Varint
  import Multiaddr.Utils
  alias Multiaddr.Protocol, as: Prot

  defp extract_protocols(bytes, protocols_list) when bytes == <<>> do
    {:ok, protocols_list}
  end

  defp extract_protocols(bytes, protocols_list) when is_binary(bytes) do
    case read_raw_protocol(bytes) do
      {:ok, {next_index, protocol, _raw_value}} ->
        extract_protocols(split_binary(bytes, next_index..-1), protocols_list ++ [protocol])

      error ->
        {:error, {"Invalid Multiaddr", error}}
    end
  end

  def extract_protocols(bytes) when is_binary(bytes) do
    extract_protocols(bytes, [])
  end

  def validate_bytes(bytes) when bytes == <<>> do
    {:ok, "Valid bytes"}
  end

  def validate_bytes(bytes) when is_binary(bytes) do
    case read_raw_protocol(bytes) do
      {:ok, {next_index, _protocol, _raw_value}} ->
        validate_bytes(split_binary(bytes, next_index..-1))

      error ->
        {:error, {"Invalid Multiaddr bytes", error}}
    end
  end

  def string_to_bytes(string) when is_binary(string) do
    string = String.trim_trailing(string, "/")
    split_string = String.split(string, "/")

    with {:ok, ""} <- Enum.fetch(split_string, 0) do
      string_to_bytes(Enum.slice(split_string, 1..-1), <<>>)
    end
  end

  defp string_to_bytes(string_split, bytes) when string_split == [] and is_binary(bytes) do
    {:ok, bytes}
  end

  defp string_to_bytes(string_split, bytes) when is_list(string_split) and is_binary(bytes) do
    with {:ok, protocol_name} <- Enum.fetch(string_split, 0),
         {:ok, protocol} <- Map.fetch(Prot.protocols_by_name(), protocol_name),
         string_split <- Enum.slice(string_split, 1..-1),
         {:ok, {next_index, protocol_bytes}} <- get_protocol_value(protocol, string_split) do
      bytes = bytes <> protocol.vcode <> protocol_bytes
      string_to_bytes(Enum.slice(string_split, next_index..-1), bytes)
    else
      error ->
        {:error, {"Invalid Multiaddr string", error}}
    end
  end

  def bytes_to_string(bytes) when is_binary(bytes) do
    bytes_to_string(bytes, "")
  end

  defp bytes_to_string(bytes, string) when bytes == <<>> and is_binary(string) do
    {:ok, string}
  end

  defp bytes_to_string(bytes, string) when is_binary(bytes) and is_binary(string) do
    case read_protocol(bytes) do
      {:ok, {next_index, protocol, value}} ->
        string =
          if protocol.size == 0 do
            string <> "/" <> protocol.name
          else
            string <> "/" <> protocol.name <> "/" <> value
          end

        bytes_to_string(split_binary(bytes, next_index..-1), string)

      error ->
        {:error, {"Invalid Multiaddr", error}}
    end
  end

  def find_protocol_by_value(bytes, %Prot{} = protocol, value)
      when is_binary(bytes) and is_binary(value) do
    with {:ok, index, protocol_value} <- find_protocol(bytes, protocol) do
      if value == protocol_value do
        {:ok, index, protocol_value}
      else
        with {:ok, {next_index, _code}} <- read_varint(bytes),
             bytes = split_binary(bytes, next_index..-1),
             {:ok, {_index, size}} <- size_for_protocol(protocol, bytes) do
          bytes
          |> split_binary((next_index + size)..0)
          |> find_protocol_by_value(protocol, value)
        end
      end
    else
      error ->
        {:error, {"Cannot find protocol", error}}
    end
  end

  def find_protocol(bytes, %Prot{} = protocol) when is_binary(bytes) do
    find_protocol(bytes, protocol.code, 0)
  end

  defp find_protocol(bytes, code, index)
       when is_binary(bytes) and is_integer(code) and is_integer(index) do
    with {:ok, {next_index, protocol, value}} <- read_protocol(bytes) do
      if protocol.code == code do
        {:ok, index, value}
      else
        find_protocol(split_binary(bytes, next_index..-1), code, index + next_index)
      end
    end
  end

  defp read_protocol(bytes) when is_binary(bytes) do
    with {:ok, {next_index, protocol, raw_value}} <- read_raw_protocol(bytes) do
      value =
        if protocol.size > 0 do
          {:ok, value} = protocol.transcoder.bytes_to_string.(raw_value)
          value
        else
          raw_value
        end

      {:ok, {next_index, protocol, value}}
    end
  end

  defp read_raw_protocol(bytes) when bytes == <<>> do
    {:error, "End of bytes"}
  end

  defp read_raw_protocol(bytes) when is_binary(bytes) do
    {:ok, {value_index, code}} = read_varint(bytes)
    bytes = split_binary(bytes, value_index..-1)

    with {:ok, protocol} <- Map.fetch(Prot.protocols_by_code(), code),
         {:ok, {next_index, size}} <- size_for_protocol(protocol, bytes),
         true <- byte_size(bytes) >= size,
         bytes = split_binary(bytes, next_index..-1),
         {:ok, protocol_bytes} = read_raw_protocol_value(protocol, bytes, size) do
      {:ok, {value_index + next_index + size, protocol, protocol_bytes}}
    else
      error ->
        {:error, {"Could not read protocol", error}}
    end
  end

  defp read_raw_protocol_value(_protocol, bytes, size) when is_binary(bytes) and size == 0 do
    {:ok, ""}
  end

  defp read_raw_protocol_value(protocol, bytes, size)
       when is_binary(bytes) and is_integer(size) and size > 0 and byte_size(bytes) >= size do
    protocol_bytes = split_binary(bytes, 0..(size - 1))

    case protocol.transcoder.validate_bytes.(protocol_bytes) do
      {:ok, _bytes} -> {:ok, protocol_bytes}
      error -> {:error, {"Error reading protocol value", error}}
    end
  end

  defp get_protocol_value(%Prot{size: size} = _protocol, string_split)
       when size == 0 and is_list(string_split) do
    {:ok, {0, ""}}
  end

  defp get_protocol_value(%Prot{size: size, path: is_path?} = protocol, string_split)
       when size == :prefixed_var_size do
    {next_index, value_string} =
      if is_path? do
        {length(string_split), Enum.join(string_split, "/")}
      else
        {1, Enum.at(string_split, 0)}
      end

    with {:ok, protocol_bytes} <- protocol.transcoder.string_to_bytes.(value_string) do
      protocol_bytes = Varint.LEB128.encode(byte_size(protocol_bytes)) <> protocol_bytes
      {:ok, {next_index, protocol_bytes}}
    end
  end

  defp get_protocol_value(%Prot{size: size} = protocol, string_split) when size > 0 do
    with {:ok, protocol_bytes} <- protocol.transcoder.string_to_bytes.(Enum.at(string_split, 0)) do
      {:ok, {1, protocol_bytes}}
    end
  end
end
