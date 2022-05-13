defmodule GrimoireWeb.SpellMacros do
  defmacro __using__(_) do
    quote do
      import GrimoireWeb.SpellMacros
    end
  end

  defmodule Spell do
    defstruct id: nil, name: nil, description: nil, params: [], handler: nil
  end

  @spell_prefix :__grimoire_spell_
  def spell_prefix, do: @spell_prefix

  def valid_type?(:integer), do: true
  def valid_type?(:string), do: true
  def valid_type?(:boolean), do: true
  def valid_type?(_), do: false

  defmacro spell(id, block) do
    exprs =
      case block do
        [do: {:__block__, _, exprs}] -> exprs
        [do: expr] -> [expr]
      end

    base_spell = %Spell{name: Atom.to_string(id), id: id}

    spell =
      Enum.reduce(exprs, base_spell, fn expr, acc ->
        case expr do
          {:name, _, [name]} ->
            Map.put(acc, :name, name)

          {:description, _, [desc]} ->
            Map.put(acc, :description, desc)

          {:param, _, [name, type]} ->
            unless valid_type?(type) do
              raise "invalid type #{type} found in spell '#{id}'"
            end

            Map.update!(acc, :params, fn ps -> ps ++ [%{name: name, type: type}] end)

          {:param, _, [name, type, opts]} ->
            unless valid_type?(type) do
              raise "invalid type #{type} found in spell '#{id}'"
            end

            Map.update!(acc, :params, fn ps -> ps ++ [%{name: name, type: type, opts: opts}] end)

          {:handler, _, [module, fun]} ->
            Map.put(acc, :handler, {Macro.expand(module, __CALLER__), fun})

          {field, _, args} ->
            raise "invalid field #{field}/#{length(args)} in spell '#{id}'"
        end
      end)

    unless spell.handler do
      raise "spell '#{id}' has no handler!"
    end

    escaped = Macro.escape(spell)

    fun_name = :"#{@spell_prefix}#{id}"

    quote do
      def unquote(fun_name)() do
        unquote(escaped)
      end
    end
  end
end
