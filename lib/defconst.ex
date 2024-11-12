# SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>
#
# SPDX-License-Identifier: MIT

defmodule Defconstant do
  @moduledoc """
  Helper functions for defining constant values in your modules.

  ## Usage

  ```elixir
  defmodule Foo do
    import #{inspect(__MODULE__)}

    defconst comptime do
      # This will be evaluated at compile time
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

  defguardp is_empty_args(value) when is_atom(value) or value == []

  @doc """
  Defines function that will be evaluated once, *in compile time*, and will
  return computation result.

  Defined function can only be 0-ary.

  Example:

      defmodule MyConstants do
        import Defconstant
        defconst the_answer, do: 42

        def my_func do
          the_answer() * 2 # returns 84
        end
      end
  """
  defmacro defconst(call, opts), do: do_defconst(:def, call, __CALLER__, opts)

  @doc """
  Defines private function that will be evaluated in compile time.

  For details see `defconst/2`.
  """
  defmacro defconstp(call, opts), do: do_defconst(:defp, call, __CALLER__, opts)

  defp do_defconst(type, {name, _, args}, _ctx, do: body) when is_empty_args(args) do
    fbody =
      quote unquote: false do
        unquote(result)
      end

    quote do
      result = unquote(body)

      unquote(type)(unquote(name)(), do: unquote(fbody))
    end
  end

  defp do_defconst(type, {name, _, args}, %Macro.Env{} = ctx, _) when length(args) > 0 do
    raise CompileError,
      description:
        "`defconst#{if type == :defp, do: "p", else: ""}` can define only 0-ary functions, tried to define #{name}/#{length(args)}-ary.",
      line: ctx.line,
      file: ctx.file
  end

  @doc """
  Defines function that will be evaluated once, *in runtime*, and will cache the result.

  Defined function can only be 0-ary.
  """
  defmacro defonce(call, opts), do: do_defonce(:def, call, __CALLER__, opts)

  @doc """
  Defines private function that will be evaluated once, *in runtime*, and will cache the result.

  For details see `defonce/2`.
  """
  defmacro defoncep(call, opts), do: do_defonce(:defp, call, __CALLER__, opts)

  @max_hash 4_294_967_295

  defp do_defonce(type, {name, _, args}, _ctx, do: body) when is_atom(args) or args == [] do
    body_hash = :erlang.phash2(body, @max_hash)

    quote do
      unquote(type)(unquote(name)()) do
        case :persistent_term.get({__MODULE__, unquote(name)}, :__no_val__) do
          {unquote(body_hash), value} ->
            value

          _ ->
            result = unquote(body)

            :persistent_term.put({__MODULE__, unquote(name)}, {unquote(body_hash), result})

            result
        end
      end
    end
  end

  defp do_defonce(type, {name, _, args}, ctx, _) when length(args) > 0 do
    raise CompileError,
      description:
        "`defonce#{if type == :defp, do: "p", else: ""}` can define only 0-ary functions, tried to define #{name}/#{length(args)}-ary.",
      line: ctx.line,
      file: ctx.file
  end
end
