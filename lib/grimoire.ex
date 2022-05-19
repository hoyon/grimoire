defmodule Grimoire do
  alias Grimoire.Context

  @spell_prefix Atom.to_string(Grimoire.Macros.spell_prefix())

  defmodule MissingParamException do
    defexception [:message]

    def exception(missing) do
      %__MODULE__{message: "Missing params! #{inspect(missing)}"}
    end
  end

  defmodule UnknownParamException do
    defexception [:message]

    def exception(unknown) do
      %__MODULE__{message: "Unknown params! #{inspect(unknown)}"}
    end
  end

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
        do_cast(spell_book, spell, params)
    end
  end

  defp do_cast(spell_book, spell, params) do
    params =
      params
      |> cast_params(spell)

    check_params(params, spell)

    %Context{spell_book: spell_book, spell: spell}
    |> run_hooks()
    |> run_handler(spell, params)
    |> Context.run_post_run_hooks()
  end

  defp run_handler(context, spell, params) do
    {m, f} = spell.handler

    try do
      result = apply(m, f, [params, context])

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

  @hooks [&Grimoire.Hooks.timer_hook/1, &Grimoire.Hooks.Audit.hook/1]

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
              cast_integer(val)

            :boolean ->
              cast_boolean(val)

            :select ->
              val
          end

        Map.put(acc, found.name, cast_val)
      else
        raise UnknownParamException, key
      end
    end)
  end

  defp cast_boolean("true"), do: true
  defp cast_boolean("false"), do: false

  defp cast_integer(val) when is_integer(val), do: val
  defp cast_integer(val) when is_binary(val), do: String.to_integer(val)

  defp check_params(params, spell) do
    present = MapSet.new(Map.keys(params))
    required = MapSet.new(spell.params |> Enum.filter(&param_required?/1) |> Enum.map(& &1.name))

    diff = MapSet.difference(required, present)

    unless MapSet.size(diff) == 0 do
      raise MissingParamException, MapSet.to_list(diff)
    end
  end

  defp param_required?(%{opts: opts}) do
    Keyword.get(opts, :required, true)
  end

  defp param_required?(_), do: true
end
