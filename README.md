<!--
SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>

SPDX-License-Identifier: MIT
-->

# defconstant

Helper macros for defining constants in Elixir code

## Installation

```elixir
def deps do
  [
    {:defconstant, "~> 1.0.0"}
  ]
end
```

Optionally add `:defconstant` to your `.formatter.exs` to have `defconst`
formatted without parens:

```
[
  import_deps: [
    :defconstant,
    ...
  ],
  ...
]
```

## Usage

This library provides 2 macros:

- `defconst` - provided body will be evaluated *at compile* time
- `defonce` - provided body will be evaluated *at runtime*, but only once. After
  that it will be cached and served from cache.

Both helper macros allows defining only 0-ary functions (functions that take no
arguments).

For details see the full docs on [hexdocs.pm](https://hexdocs.pm/defconstant/Defconstant.html)

### Example usage

``` elixir
defmodule Demo.MyConst do
  import Defconstant

  defconst the_answer do
    42
  end

  # NOTE: For real code you'd use `:math.pi` instead
  defconst pi do
    3.14159
  end

  defonce calculated_at do
    NaiveDateTime.utc_now()
  end

  def run_calulations(circumference) do
    circle_radius = circumference / 2 * pi()
    "radius is #{circle_radius} and was first calculated at #{inspect calculated_at()}"
  end
end
```

And the constants can be used from another module (e.g. `Demo.MyConst.the_answer()` will return `42`)

## Why

Elixir and Erlang/OTP don't have true constants. They do have module attributes,
which are often used like constants, but module attributes can be modified so
they aren't truly constants. For example:

``` elixir
defmodule ModuleAttributeDemo do
  @pi 3.14159
  def pi, do: @pi

  @pi 33
  def radius(circumference), do: circumference / 2 * @pi
end
```

Calling `ModuleAttributeDemo.radius(5)` will use `33` as the value for `@pi`
instead of `3.14159`. With `defconst` this can be avoided because you will
receive a warning when re-defining a constant.

## License

MIT
