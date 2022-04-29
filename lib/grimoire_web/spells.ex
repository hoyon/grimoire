defmodule GrimoireWeb.Spells do
  @spell_prefix Atom.to_string(GrimoireWeb.SpellMacros.spell_prefix())

  def all(spell_book) do
    spell_book.__info__(:functions)
    |> Enum.filter(fn {fun, arity} ->
      String.starts_with?("#{fun}", @spell_prefix) and arity == 0
    end)
    |> Enum.map(fn {fun, 0} ->
      apply(spell_book, fun, [])
    end)
  end

  def get(spell_book, spell_id) do
    Enum.find(all(spell_book), fn x -> "#{x.id}" == "#{spell_id}" end)
  end

  def cast(spell_book, spell_id, params) do
    case get(spell_book, spell_id) do
      nil ->
        {:error, "invalid spell"}

      spell ->
        do_cast(spell, params)
    end
  end

  def cast!(spell_book, spell_id, params) do
    case get(spell_book, spell_id) do
      nil ->
        raise "invalid spell!"

      spell ->
        case do_cast(spell, params) do
          %{status: :error, error_message: msg} ->
            raise "Cast failed: #{msg}"
          %{status: :ok, result: result} ->
            result
        end
    end
  end

  defp do_cast(spell, params) do
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
      found = Enum.find(spell.params, fn p -> "#{p.name}" == "#{key}" end)

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
