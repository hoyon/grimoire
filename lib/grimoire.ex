defmodule Grimoire do
  alias Grimoire.Context

  @spell_prefix Atom.to_string(Grimoire.Macros.spell_prefix())

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

  defp do_cast(spell, params) do
    params =
      params
      |> cast_params(spell)

    %Context{}
    |> run_hooks()
    |> run_handler(spell, params)
    |> Context.run_post_run_hooks()
  end

  defp run_handler(context, spell, params) do
    {m, f} = spell.handler

    try do
      result = apply(m, f, [params])

      case result do
        :ok -> %{context | result: :ok, error: false}
        {:ok, value} -> %{context | result: value, error: false}
        {:error, message} -> %{context | result: nil, error: true, error_message: message}
      end
    rescue
      e ->
        %{
          context
          | result: nil,
            error: true,
            error_message: Exception.format(:error, e, __STACKTRACE__)
        }
    end
  end

  @hooks [&Grimoire.Hooks.timer_hook/1]

  defp run_hooks(context) do
    Enum.reduce(@hooks, context, & &1.(&2))
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

            :boolean ->
              cast_boolean(val)

            :select ->
              val
          end

        Map.put(acc, found.name, cast_val)
      else
        acc
      end
    end)
  end

  defp cast_boolean("true"), do: true
  defp cast_boolean("false"), do: false
end
