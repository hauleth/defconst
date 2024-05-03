# SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>
#
# SPDX-License-Identifier: MIT

defmodule Defconstant.MixProject do
  use Mix.Project

  def project do
    [
      app: :defconstant,
      description: "Helper macros for defining constant values in modules",
      version: "1.0.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      package: %{
        licenses: ~W[MIT],
        links: %{
          "GitHub" => "https://github.com/hauleth/defconst"
        }
      },
      deps: [
        {:ex_doc, ">= 0.0.0", only: [:dev]}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end
end
