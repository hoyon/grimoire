defmodule GrimoireWeb.Spells do
  @spell_list GrimoireWeb.SpellBook
  @spell_prefix Atom.to_string(GrimoireWeb.SpellMacros.spell_prefix())

  def all do
    @spell_list.__info__(:functions)
    |> Enum.filter(fn {fun, arity} ->
      String.starts_with?("#{fun}", @spell_prefix) and arity == 0
    end)
    |> Enum.map(fn {fun, 0} ->
      apply(@spell_list, fun, [])
    end)
  end

  def get(spell_id) do
    Enum.find(all(), fn x -> Atom.to_string(x.id) == spell_id end)
  end

  def perform(spell_id, params) do
    case get(spell_id) do
      nil ->
        {:error, "invalid spell"}

      spell ->
        do_perform(spell, params)
    end
  end

  defp do_perform(spell, params) do
    {m, f} = spell.action

    params =
      params
      |> cast_params(spell)

    {time, output} = :timer.tc(m, f, [params])

    res =
      case output do
        :ok -> %{status: :ok, result: nil}
        {:ok, val} -> %{status: :ok, result: val}
        {:error, msg} -> %{status: :error, error_message: msg}
    end

    res
    |> Map.put(:duration_ms, time / 1000)
  end

  defp cast_params(params, spell) do
    Enum.reduce(params, %{}, fn {key, val}, acc ->
      found = Enum.find(spell.params, fn p -> Atom.to_string(p.name) == key end)

      if found do
        cast_val =
          case found.type do
            :string ->
              val

            :integer ->
              String.to_integer(val)
          end

        Map.put(acc, found.name, cast_val)
      else
        acc
      end
    end)
  end
end
