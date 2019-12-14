defmodule Multiaddr.Utils.Varint do
  @moduledoc false

  def read_varint(b) when is_binary(b) do
    list_b = :binary.bin_to_list(b)
    split_index = Enum.find_index(list_b, fn x -> x < 128 end)

    number =
      Enum.take(list_b, split_index + 1)
      |> :binary.list_to_bin()
      |> Varint.LEB128.decode()

    {:ok, {split_index + 1, number}}
  end

  def code_to_varint(code) when is_integer(code) do
    Varint.LEB128.encode(code)
  end
end
