# SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>
#
# SPDX-License-Identifier: MIT

defmodule DefconstTest do
  use ExUnit.Case, async: true

  @subject Defconst

  doctest @subject

  defp compile(body) do
    name = Module.concat(__MODULE__, "Test#{System.unique_integer([:positive])}")

    code =
      quote do
        defmodule unquote(name) do
          import unquote(@subject)

          unquote(body)
        end
      end

    Code.eval_quoted(code, [], __ENV__)

    name
  end

  describe "defconst" do
    test "defines function with given name" do
      mod =
        compile(
          quote do
            defconst foo do
              1234
            end
          end
        )

      assert function_exported?(mod, :foo, 0)
    end

    test "defined function is called during compilation" do
      _mod =
        compile(
          quote do
            defconst foo do
              send(unquote(self()), :ping)
              :pong
            end
          end
        )

      assert_received :ping
    end

    test "defined function is not called at runtime" do
      mod =
        compile(
          quote do
            defconst foo do
              send(unquote(self()), :ping)
              :pong
            end
          end
        )

      assert_received :ping

      assert mod.foo() == :pong

      refute_received :ping
    end

    test "returned value is always the same" do
      mod =
        compile(
          quote do
            defconst foo do
              :rand.uniform()
            end
          end
        )

      assert mod.foo() == mod.foo()
    end

    test "trying to define non 0-ary function raises" do
      assert_raise CompileError, fn ->
        compile(
          quote do
            defconst foo(a, b) do
              2137
            end
          end
        )
      end
    end
  end

  describe "defonce" do
    test "defines function with given name" do
      mod =
        compile(
          quote do
            defonce foo do
              1234
            end
          end
        )

      assert function_exported?(mod, :foo, 0)
    end

    test "defined function is called only once" do
      mod =
        compile(
          quote do
            defonce foo do
              send(unquote(self()), :ping)
              :pong
            end
          end
        )

      refute_received :ping

      assert mod.foo() == :pong

      assert_received :ping

      assert mod.foo() == :pong

      refute_received :ping
    end

    test "returned value is always the same" do
      mod =
        compile(
          quote do
            defonce foo() do
              :rand.uniform()
            end
          end
        )

      assert mod.foo() == mod.foo()
    end

    test "trying to define non 0-ary function raises" do
      assert_raise CompileError, fn ->
        compile(
          quote do
            defonce foo(a, b) do
              2137
            end
          end
        )
      end
    end
  end
end
