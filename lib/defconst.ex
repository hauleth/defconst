# SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>
#
# SPDX-License-Identifier: MIT

defmodule Defconst do
  @moduledoc """
  Helper functions for definig constant values in your modules.

  ## Usage

  ```elixir
  defmodule Foo do
    import #{inspect(__MODULE__)}

    defconst comptime do
      # This will be evaulated at compile time
      Enum.sum([
        0, 2, 3, 4, 5, 6, 8, 12, 30, 32, 33, 34, 35, 36, 38, 40, 42, 43, 44, 45,
        46, 48, 50, 52, 53, 54, 55, 56, 58, 60, 62, 63, 64, 65, 66, 68, 80, 82,
        83, 84, 85, 86, 88
      ])
    end

    defonce runtime do
      2 * 1068 + 1
    end
  end
  ```
  """
  @doc """
  Defines function that will be evaulated once, *in compile time*, and will
  return computation result.

  Defined function can only be 0-ary.
  """
  defmacro defconst({name, _, args}, do: body) when is_atom(args) or args == [] do
    quote bind_quoted: [name: name, result: body] do
      def unquote(name)() do
        unquote(result)
      end
    end
  end

  defmacro defconst({name, _, args}, _) when length(args) > 0 do
    raise CompileError,
      description:
        "`defconst` can define only 0-ary functions, tried to define #{name}/#{length(args)}-ary.",
      line: __CALLER__.line,
      file: __CALLER__.file
  end

  @doc """
  Defines function that will be evaulated once, *in runtime*, and will cache the result.

  Defined function can only be 0-ary.
  """
  defmacro defonce({name, _, args}, do: body) when is_atom(args) or args == [] do
    quote do
      def unquote(name)() do
        :persistent_term.get({__MODULE__, unquote(name)})
      catch
        :error, :badarg ->
          result = unquote(body)

          :persistent_term.put({__MODULE__, unquote(name)}, result)

          result
      end
    end
  end

  defmacro defonce({name, _, args}, _) when length(args) > 0 do
    raise CompileError,
      description:
        "`defonce` can define only 0-ary functions, tried to define #{name}/#{length(args)}-ary.",
      line: __CALLER__.line,
      file: __CALLER__.file
  end
end
