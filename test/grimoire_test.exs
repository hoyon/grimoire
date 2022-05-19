defmodule GrimoireTest do
  use Grimoire.DataCase, async: true

  defmodule SpellImpls do
    def basic(_), do: :ok

    def basic_fail(_), do: {:error, "fail"}

    def with_params(%{a: a}) do
      assert a == 1

      {:ok, "success!"}
    end

    def raise_error(_), do: raise "oh noes!"
  end

  defmodule TestSpellBook do
    use Grimoire.Macros

    spell :basic do
      handler SpellImpls, :basic
    end

    spell :basic_fail do
      handler SpellImpls, :basic_fail
    end

    spell :with_params do
      param :a, :integer
      handler SpellImpls, :with_params
    end

    spell :raise_error do
      handler SpellImpls, :raise_error
    end
  end

  @spell_book TestSpellBook

  describe "cast" do
    test "works with trivial spell" do
      context = Grimoire.cast(@spell_book, :basic, %{})
      refute context.error
      assert context.result == :ok
    end

    test "handles error results" do
      context = Grimoire.cast(@spell_book, :basic_fail, %{})
      assert context.error
      assert context.error_message == "fail"
    end

    test "integer params accept string" do
      context = Grimoire.cast(@spell_book, :with_params, %{a: "1"})
      refute context.error
      assert context.result == "success!"
    end

    test "integer params accept integer" do
      context = Grimoire.cast(@spell_book, :with_params, %{a: 1})
      refute context.error
      assert context.result == "success!"
    end

    test "with missing params" do
      assert_raise Grimoire.MissingParamException, ~r"[:a]", fn ->
        Grimoire.cast(@spell_book, :with_params, %{})
      end
    end

    test "with unknown params" do
      assert_raise Grimoire.UnknownParamException, ~r"[:some_field]", fn ->
        Grimoire.cast(@spell_book, :with_params, %{a: 123, some_field: "abc"})
      end
    end

    test "with exception" do
      context = Grimoire.cast(@spell_book, :raise_error, %{})
      assert context.error
      assert context.error_message =~ "oh noes!"
    end

    test "with optional params"
  end
end
