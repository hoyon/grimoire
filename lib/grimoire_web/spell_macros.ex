defmodule GrimoireWeb.SpellMacros do
  defmacro __using__(_) do
    quote do
      import GrimoireWeb.SpellMacros
    end
  end

  defmodule Spell do
    defstruct id: nil, name: nil, description: nil, params: [], action: nil
  end

  @spell_prefix :__grimoire_spell_

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
          {:description, _, [desc]} ->
            Map.put(acc, :description, desc)

          {:param, _, [name, type]} ->
            Map.update!(acc, :params, fn ps -> ps ++ [%{name: name, type: type}] end)

          {:param, _, [name, type, opts]} ->
            Map.update!(acc, :params, fn ps -> ps ++ [%{name: name, type: type, opts: opts}] end)

          {:action, _, [module, fun]} ->
            Map.put(acc, :action, {Macro.expand(module, __CALLER__), fun})
        end
      end)

    escaped = Macro.escape(spell)

    fun_name = :"#{@spell_prefix}#{id}"

    quote do
      def unquote(fun_name)() do
        unquote(escaped)
      end
    end
  end
end
