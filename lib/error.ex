defmodule Multiaddr.Error do
  @moduledoc false

  defexception [:reason]

  def exception(reason),
    do: %__MODULE__{reason: reason}

  def message(%__MODULE__{reason: reason}),
    do: format_error(reason)

  def format_error({:error, reason}), do: format_error(reason)

  def format_error({:invalid_bytes, bytes_offset}),
    do: "Corrupted Multiaddr. Wrong bytes in offset: #{bytes_offset}"

  def format_error({:invalid_string, value}),
    do: "Invalid Multiaddr. Wrong string : #{value}"

  def format_error({:invalid_order, value}),
    do: "Multiaddr with invalid ordered protocols: #{value}"

  def format_error({:invalid_protocol_name, value}),
    do: "Invalid protocol name for Multiaddr: #{value}"

  def format_error({:invalid_protocol_code, value}),
    do: "Invalid protocol code for Multiaddr: #{value}"

  def format_error(error), do: "Unknown error! #{error}"
end
