# SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>
#
# SPDX-License-Identifier: MIT

defmodule SUT do
  def do_name do
    key = {__MODULE__, :try}

    try do
      :persistent_term.get(key)
    catch
      :error, :badarg ->
        value = 2137

        :persistent_term.put(key, value)

        value
    end
  end

  def do_hash do
    key = {__MODULE__.module_info(:md5), :try}

    try do
      :persistent_term.get(key)
    catch
      :error, :badarg ->
        value = 2137

        :persistent_term.put(key, value)

        value
    end
  end
end

Benchee.run(%{
  "name" => &SUT.do_name/0,
  "hash" => &SUT.do_hash/0
})
