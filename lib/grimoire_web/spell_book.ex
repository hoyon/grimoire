defmodule GrimoireWeb.SpellBook do
  use GrimoireWeb.SpellMacros

  spell :greet do
    description "Output greeting to console"
    action __MODULE__, :greet
  end

  spell :echo do
    param :message, :string
    action __MODULE__, :echo
  end

  spell :add do
    description "Add two numbers"
    param :a, :integer
    param :b, :integer
    action __MODULE__, :add
  end

  spell :sleep do
    action __MODULE__, :sleep
  end

  spell :fail do
    param :message, :string
    action __MODULE__, :fail
  end

  spell :raise do
    action __MODULE__, :raise_error
  end

  spell :optional do
    param :something, :string, optional: true
    action __MODULE__, :optional
  end

  spell :dupe do
    param :a, :string
    action __MODULE__, :fail
  end

  def greet(_) do
    IO.inspect("hello world")
    :ok
  end

  def echo(%{message: m}) do
    {:ok, m}
  end

  def add(%{a: a, b: b}) do
    {:ok, a + b}
  end

  def sleep(_) do
    Process.sleep(1000)
  end

  def fail(%{message: message}) do
    {:error, "Oh no! #{message}"}
  end

  def raise_error(_) do
    raise "oh dear"
  end

  def optional(params) do
    case params do
      %{something: ""} ->
        IO.inspect("got nothing")

      %{something: s} ->
        IO.inspect(s, label: :something)
    end

    {:ok, nil}
  end
end
