defmodule Grimoire.Context do
  defstruct result: nil, error: false, error_message: nil, post_run_hooks: [], hook_data: %{}

  def put_hook_data(context, key, value) do
    %{context | hook_data: put_in(context.hook_data, [key], value)}
  end

  def get_hook_data(context, key) do
    context.hook_data[key]
  end

  def register_post_run_hook(context, hook_fn) do
    %{context | post_run_hooks: [hook_fn | context.post_run_hooks]}
  end

  def run_post_run_hooks(context) do
    Enum.reduce(context.post_run_hooks, context, & &1.(&2))
  end
end
