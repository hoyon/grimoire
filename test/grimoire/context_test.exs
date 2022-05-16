defmodule Grimoire.ContextTest do
  use ExUnit.Case, async: true
  alias Grimoire.Context

  describe "hook data" do
    test "can put and retrieve value" do
      context =
        %Context{}
        |> Context.put_hook_data(:my_key, 123)

      assert Context.get_hook_data(context, :my_key) == 123
    end

    test "returns nil if getting key which doesn't exist" do
      context = %Context{}
      assert Context.get_hook_data(context, :invalid) == nil
    end
  end

  describe "post run hooks" do
    def post_run_hook(pid, id) do
      send(pid, {:called, id})
    end

    test "can register and run hooks" do
      context =
        %Context{}
        |> Context.register_post_run_hook(fn _ -> post_run_hook(self(), 1) end)

      Context.run_post_run_hooks(context)

      assert_receive {:called, 1}
    end

    defmacro assert_next_receive(pattern, timeout \\ 100) do
      quote do
        receive do
          message ->
            assert unquote(pattern) = message
        after
          unquote(timeout) ->
            raise "timed out waiting for message"
        end
      end
    end

    test "hooks are run in the reverse order they are registered" do
      context =
        %Context{}
        |> Context.register_post_run_hook(fn _ -> post_run_hook(self(), 1) end)
        |> Context.register_post_run_hook(fn _ -> post_run_hook(self(), 2) end)
        |> Context.register_post_run_hook(fn _ -> post_run_hook(self(), 3) end)
        |> Context.register_post_run_hook(fn _ -> post_run_hook(self(), 4) end)

      Context.run_post_run_hooks(context)

      assert_next_receive({:called, 4})
      assert_next_receive({:called, 3})
      assert_next_receive({:called, 2})
      assert_next_receive({:called, 1})
    end

    def hook_1(context) do
      Context.put_hook_data(context, :key_1, 1)
    end

    def hook_2(context) do
      assert Context.get_hook_data(context, :key_1) == 1
      Context.put_hook_data(context, :key_2, 2)
    end

    test "hook context accumulates" do
      context =
        %Context{}
        |> Context.register_post_run_hook(&hook_2/1)
        |> Context.register_post_run_hook(&hook_1/1)

      context = Context.run_post_run_hooks(context)

      assert Context.get_hook_data(context, :key_1) == 1
      assert Context.get_hook_data(context, :key_2) == 2
    end
  end
end
