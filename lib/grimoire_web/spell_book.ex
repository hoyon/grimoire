defmodule GrimoireWeb.SpellBook do
  use GrimoireWeb.SpellMacros

  spell :console do
    description "Output message to console"
    handler __MODULE__, :console
  end

  spell :greet do
    param :name, :string
    handler __MODULE__, :greet
  end

  spell :echo do
    param :message, :string
    handler __MODULE__, :echo
  end

  spell :add do
    description "Add two numbers"
    param :a, :integer
    param :b, :integer
    handler __MODULE__, :add
  end

  spell :sleep do
    handler __MODULE__, :sleep
  end

  spell :fail do
    param :message, :string
    handler __MODULE__, :fail
  end

  spell :raise do
    handler __MODULE__, :raise_error
  end

  spell :optional_param do
    param :something, :string, required: false
    handler __MODULE__, :optional
  end

  spell :complete do
    name "Complete Example"

    description """
    Some super long description

    With some stuff:
    - sdf
    - asdf
    """

    param :string_param, :string, description: "A string"
    param :integer_param, :integer, description: "A number"
    param :launch_rockets?, :boolean, description: "Rockets!!!"
    handler __MODULE__, :with_bool
  end

  def console(_) do
    IO.inspect("hello from grimoire")
    :ok
  end

  def greet(%{name: name}) do
    {:ok, "Hello #{name}!"}
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

  def with_bool(%{launch_rockets?: launch_rockets?}) do
    if launch_rockets? do
      {:ok, "Rockets have been launched!"}
    else
      {:ok, "Not launching rockets"}
    end
  end
end
