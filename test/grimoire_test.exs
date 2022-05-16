defmodule GrimoireTest do
  use ExUnit.Case, async: true

  @spell_book GrimoireWeb.SpellBook

  describe "greet" do
    test "it works!" do
      context = Grimoire.cast(@spell_book, :greet, %{name: "bob"})
      refute context.error
    end
  end

  describe "fail" do
    test "it doesn't works!" do
      context = Grimoire.cast(@spell_book, :fail, %{message: "aaa"})
      assert context.error
    end
  end
end
