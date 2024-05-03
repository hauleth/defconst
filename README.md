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
    {:defconstant, "~> 0.1.0"}
  ]
end
```

## Usage

This library provides 2 macros:

- `defconst` - provided body will be evaluated *at compile* time
- `defonce` - provided body will be evaluated *at runtime*, but only once. After
  that it will be cached and served from cache.

Both helper macros allows defining only 0-ary functions (functions that take no
arguments).

## License

MIT
