defmodule Multiaddr.Utils.Constants do
  defmacro define(name, value) do
    quote do
      def unquote(name)() do
        unquote(value)
      end
    end
  end
end
