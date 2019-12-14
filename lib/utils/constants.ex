defmodule Multiaddr.Utils.Constants do
  @moduledoc false

  defmacro define(name, value) do
    quote do
      def unquote(name)() do
        unquote(value)
      end
    end
  end
end
