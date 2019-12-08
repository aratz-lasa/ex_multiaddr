defmodule Multiaddr.Transcoder do
  import Multiaddr.Utils.Constants

  defstruct [:bytes_to_string, :string_to_bytes]

  # IP4
  def ip4_bytes_to_string(bytes) when is_binary(bytes) do
    try do
      string =  bytes
      |> :binary.bin_to_list()
      |> Enum.join(".")
      {:ok, string}
    rescue
      _ -> {:error, "Invalid IP4 string"}
    end
  end


  def ip4_string_to_bytes(string) when is_binary(string) do
    try do
      bytes = string
        |> String.split(".")
        |> Enum.map(fn x -> String.to_integer(x) end)
        |> :binary.list_to_bin()
      {:ok, bytes}
    rescue
      _ -> {:error, "Invalid IP4 bytes"}
    end
  end


  define(:ip4_transcoder, %__MODULE__{bytes_to_string: &ip4_bytes_to_string/1, string_to_bytes: &ip4_string_to_bytes/1})
end