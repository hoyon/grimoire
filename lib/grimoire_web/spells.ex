defmodule GrimoireWeb.Spells do
  def all do
    [
      %{
        name: "hello",
        params: [],
        fn: fn _ -> IO.inspect("Hello world!!!") end,
      },
      %{
        name: "echo",
        params: [
          %{name: :message, type: :string}
        ],
        fn: fn params -> IO.inspect(params.message, label: :echo) end,
      }
    ]
  end

  def get(spell_name) do
    Enum.find(all(), fn x -> x.name == spell_name end)
  end

  def perform(spell_name, params) do
    case get(spell_name) do
      nil ->
        :error

      spell ->
        do_perform(spell, params)
    end
  end

  defp do_perform(spell, params) do
    spell.fn.(atomise(params))
  end

  defp atomise(params) do
    Enum.reduce(params, %{}, fn {key, val}, acc ->
      Map.put(acc, String.to_existing_atom(key), val)
    end)
  end
end
