Mix.install([:benchee])

defmodule SUT do
  @key {__MODULE__, :try}
  def do_try do
    :persistent_term.get(@key)
  catch
    :error, :badarg ->
      value = 2137

      :persistent_term.put(@key, value)

      value
  end

  @key {__MODULE__, :default}
  def do_default do
    case :persistent_term.get(@key, :undefined) do
      :undefined ->

        value = 2137

        :persistent_term.put(@key, value)

        value

      value -> value
    end
  end
end

Benchee.run(%{
  "try" => &SUT.do_try/0,
  "default" => &SUT.do_default/0,
})
