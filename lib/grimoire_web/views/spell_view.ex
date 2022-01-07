defmodule GrimoireWeb.SpellView do
  use GrimoireWeb, :view

  def required?(%{opts: opts}) do
    Keyword.get(opts, :optional, false) == false
  end

  def required?(_), do: true
end
