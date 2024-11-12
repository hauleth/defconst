# SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>
#
# SPDX-License-Identifier: MIT

defmodule DefconstantTest do
  use ExUnit.Case, async: true

  @subject Defconstant

  doctest @subject

  defp compile(body, opts \\ []) do
    name = opts[:module_name] || Module.concat(__MODULE__, "Test#{System.unique_integer([:positive])}")

    code =
      quote do
        defmodule unquote(name) do
          import unquote(@subject)

          unquote(body)
        end
      end

    Code.eval_quoted_with_env(code, [], __ENV__)

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

  describe "defconstp" do
    test "defines function with given name" do
      mod =
        compile(
          quote do
            defconstp foo do
              1234
            end

            def call, do: foo()
          end
        )

      refute function_exported?(mod, :foo, 0)
    end

    test "defined function is called during compilation" do
      _mod =
        compile(
          quote do
            defconstp foo do
              send(unquote(self()), :ping)
              :pong
            end

            def call, do: foo()
          end
        )

      assert_received :ping
    end

    test "defined function is not called at runtime" do
      mod =
        compile(
          quote do
            defconstp foo do
              send(unquote(self()), :ping)
              :pong
            end

            def call do
              foo()
            end
          end
        )

      assert_received :ping

      assert mod.call() == :pong

      refute_received :ping
    end

    test "returned value is always the same" do
      mod =
        compile(
          quote do
            defconstp foo do
              :rand.uniform()
            end

            def call do
              foo()
            end
          end
        )

      assert mod.call() == mod.call()
    end

    test "trying to define non 0-ary function raises" do
      assert_raise CompileError, fn ->
        compile(
          quote do
            defconstp foo(a, b) do
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

  describe "defoncep" do
    test "defines function with given name" do
      mod =
        compile(
          quote do
            defoncep foo do
              1234
            end

            def call, do: foo()
          end
        )

      refute function_exported?(mod, :foo, 0)
    end

    test "defined function is called only once" do
      mod =
        compile(
          quote do
            defonce foo do
              send(unquote(self()), :ping)
              :pong
            end

            def call, do: foo()
          end
        )

      refute_received :ping

      assert mod.call() == :pong

      assert_received :ping

      assert mod.call() == :pong

      refute_received :ping
    end

    test "returned value is always the same" do
      mod =
        compile(
          quote do
            defoncep foo() do
              :rand.uniform()
            end

            def call, do: foo()
          end
        )

      assert mod.call() == mod.call()
    end

    test "trying to define non 0-ary function raises" do
      assert_raise CompileError, fn ->
        compile(
          quote do
            defoncep foo(a, b) do
              2137
            end
          end
        )
      end
    end

    test "when replacing module then function is reevaluated" do
      mod_name = __MODULE__.TestRecompilation1
      mod =
        compile(
          quote do
            defonce foo do
              send(unquote(self()), {:ping, 1})
              {:pong, 1}
            end

            def call, do: foo()
          end,
          module_name: mod_name
        )

      assert mod.call() == {:pong, 1}

      assert_received {:ping, 1}

      mod =
        compile(
          quote do
            defonce foo do
              send(unquote(self()), {:ping, 2})
              {:pong, 2}
            end

            def call, do: foo()
          end,
          module_name: mod_name
        )

      assert mod.call() == {:pong, 2}

      assert_received {:ping, 2}
    end

    test "when defonce body stays the same, do not reevaluate" do
      mod_name = __MODULE__.TestRecompilation2
      mod =
        compile(
          quote do
            defonce foo do
              send(unquote(self()), :ping)
              :pong
            end

            def call, do: {foo(), 1}
          end,
          module_name: mod_name
        )

      assert mod.call() == {:pong, 1}

      assert_received :ping

      mod =
        compile(
          quote do
            defonce foo do
              send(unquote(self()), :ping)
              :pong
            end

            def call, do: {foo(), 2}
          end,
          module_name: mod_name
        )

      assert mod.call() == {:pong, 2}

      refute_received :ping
    end
  end
end
