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
end
