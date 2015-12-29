defmodule KV.Bucket do
  @doc """
  Start a new bucket
  """
  def start_link do
    Agent.start_link(fn -> Map.new end)
  end

  @doc """
  Get value from given key
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  put value for given key
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  delete given key
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
