defmodule KV.Registry do
  use GenServer

  @doc"""
  Start the registry
  """
  def start_link(table, events, buckets, opts \\ []) do
    GenServer.start_link(__MODULE__, {table, events, buckets}, opts)
  end

  @doc"""
  Get bucket pid by name
  """
  def lookup(table, name) do
    case :ets.lookup(table, name) do
      [{^name, bucket}] -> {:ok, bucket}
      [] -> :error
    end
  end

  @doc """
  Ensure bucket by name
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  def init({ets, events, buckets}) do
    refs = :ets.foldl(fn {name, bucket}, acc ->
      Map.put(acc, Process.monitor(bucket), name)
    end, Map.new, ets)
    {:ok, %{names: ets, refs: refs, events: events, buckets: buckets}}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_call({:create, name}, _from, state) do
    case lookup(state.names, name) do
      {:ok, bucket} ->
        {:reply, bucket, state}
      :error ->
        {:ok, bucket} = KV.Bucket.Supervisor.start_bucket(state.buckets)
        ref = Process.monitor(bucket)
        refs = Map.put(state.refs, ref, name)
        :ets.insert(state.names, {name, bucket})
        GenEvent.sync_notify(state.events, {:create, name, bucket})
        {:reply, bucket, %{state | refs: refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    {name, refs} = Map.pop(state.refs, ref)
    :ets.delete(state.names, name)
    GenEvent.sync_notify(state.events, {:exit, name, pid})
    {:noreply, %{state | refs: refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
