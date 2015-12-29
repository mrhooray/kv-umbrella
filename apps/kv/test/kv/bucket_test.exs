defmodule KV.BucketTest do
  use ExUnit.Case, async: true
  doctest KV.Bucket
  @key "meh"
  @value "hehe"

  setup do
    {:ok, bucket} = KV.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "get", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, @key) === nil
  end

  test "put", %{bucket: bucket} do
    assert KV.Bucket.put(bucket, @key, @value) === :ok
    assert KV.Bucket.get(bucket, @key) === @value
  end

  test "delete", %{bucket: bucket} do
    assert KV.Bucket.put(bucket, @key, @value) === :ok
    assert KV.Bucket.delete(bucket, @key) === @value
    assert KV.Bucket.get(bucket, @key) === nil
  end
end
