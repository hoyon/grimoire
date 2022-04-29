defmodule GrimoireWeb.SpellBookTest do
  use ExUnit.Case, async: true

  @spell_book GrimoireWeb.SpellBook

  describe "greet" do
    test "it works!" do
      GrimoireWeb.Spells.cast!(@spell_book, :greet, %{})
    end
  end

  describe "fail" do
    test "it doesn't works!" do
      assert_raise RuntimeError, fn ->
        GrimoireWeb.Spells.cast!(@spell_book, :fail, %{message: "aaa"})
      end
    end
  end
end
