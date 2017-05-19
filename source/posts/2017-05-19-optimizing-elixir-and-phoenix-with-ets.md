---
layout: post
title: "Optimizing Your Elixir and Phoenix projects with ETS"
social: true
author: Chris McCord
twitter: "chris_mccord"
github: chrismccord
summary: "Learn how to optimize your elixir applications with a fast in-memory store"
published: true
tags: engineering, elixir, phoenix, ets
---

Many Elixir programmers have probably heard references to "ets" or
"ETS" in talks, or may have seen calls to the Erlang `:ets` module in
code, but I would wager the majority haven't used this feature of
Erlang in practice. Let's change that.

ETS, or Erlang Term Storage, is one of those innovative Erlang
features that feels like it has been hiding in plain sight once you
use it. Projects across the community like `Phoenix.PubSub`,
`Phoenix.Presence`, and Elixir's own `Registry` take advantage of ETS, along with many internal Erlang and Elixir modules.
Simply put, ETS is an in-memory store for Elixir and Erlang terms with
fast access. Critically, it allows access to state outside of a
process and message passing. Before we talk when to ETS (*and when not to*), let's begin with a basic primer by firing up iex:

First, we'll create an ETS table with `:ets.new/2`:


```elixir
iex> tab = :ets.new(:my_table, [:set])
8211
```

That was easy enough. We created a table of type `:set`, which will allows us to map unique keys to values as a standard key-value storage. Let's insert a couple items:

```elixir
iex> :ets.insert(tab, {:key1, "value1"})
true
iex> :ets.insert(tab, {:key2, "value1"})
true
```

Now with a couple items in place, let's do a lookup:
```elixir
iex> :ets.lookup(tab, :key1)
[key1: "value1"]
```

Notices how we aren't re-binding `tab` to a new value after inserting items. ETS tables are managed by the VM and their existence lives and dies by the process that created them. We can see this in action by killing the current iex shell process:

```elixir
iex> Process.exit(self(), :kill)
** (EXIT from #PID<0.88.0>) killed

Interactive Elixir (1.4.4) - press Ctrl+C to exit (type h() ENTER for help)
iex> :ets.insert(8211, {:key1, "value1"})
** (ArgumentError) argument error
    (stdlib) :ets.insert(12307, {:key1, "value1"})
```

Once iex crashes, we lose our previous bindings, but we can pass the ets table ID returned from our call to `:ets.new/2`. We can see that when we tried to access the table after its owner crashed, an `ArgumentError` was thrown. This automatic cleanup of tables and data when the owning process crashes is one of ETS's great features. We don't have to be concerned about memory leaks when processes terminate after creating tables and inserting data. Here, we also got our first glimpse of the esoteric `:ets` API and its often unhelpful errors, such as `ArgumentError` with no other guidelines on what the problem may be. As you use the `:ets` module more and more, you'll undoubtably become famliar with frustrating argument errors and the [`:ets` documentation](http://erlang.org/doc/man/ets.html) is likely to end up in your bookmarks.

This just barely scratched the surface of what features ETS provides. We'll only be using a fraction of its capabilities, but just remember where it really shines is fast reads and writes to key-value storage, with the ability to efficiently match on most erlang terms stored within the table (excluding maps). In our examples, we'll only be storing simple key-values with basic lookups, but you should consult the docs to explore the breadth of provided features.


## Optimizing `GenServer` access with an ETS table

Optimizing code is a rewarding experince, but doubly so when you don't have to change your public interface. Let's see a common way ETS is used to optimize data access for state wrapped in a `GenServer`.

Imagine we're writing a rate limiter `GenServer` which is a process in our app that counts user requests and allows us to deny access once a user exceeds their allotted requests per minute. We know right away that we'll need to store the request count state for our users somewhere, as well as a process that periodically sweeps the state once per minute. A naive first-pass with a plain-old `GenServer` might look something like this:

```elixir
defmodule RateLimiter do
  use GenServer
  require Logger

  @max_per_minute 5
  @sweep_after :timer.seconds(60)

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def log(uid) do
    GenServer.call(__MODULE__, {:log, uid})
  end

  ## Server
  def init(_) do
    schedule_sweep()
    {:ok, %{requests: %{}}}
  end

  def handle_info(:sweep, state) do
    Logger.debug("Sweeping requests")
    schedule_sweep()
    {:noreply, %{state | requests: %{}}}
  end

  def handle_call({:log, uid}, _from, state) do
    case state.requests[uid] do
      count when is_nil(count) or count < @max_per_minute ->
        {:reply, :ok, put_in(state, [:requests, uid], (count || 0) + 1)}
      count when count >= @max_per_minute ->
        {:reply, {:error, :rate_limited}, state}
    end
  end

  defp schedule_sweep do
    Process.send_after(self(), :sweep, @sweep_after)
  end
end
```

First, we defined `start_link/0` which starts a `GenServer`, using our `RateLimiter` module as the callback module. We also named the server as our module so we can reference it later in our call to `log/1`. Next, we defined a `log/1` function which makes a synchronous call to the rate limiter server, asking it to log our user's request. We expect to receive either `:ok` back, to indicate our request can proceed, or `{:error, :rate_limited}`, to indicate the user has exceeded their allotted requests, and the request should not proceed.

Next, in `init/1`, we called a `schedule_sweep/0` function which simply has the server send itself a message one per minute to clear out all request data. Then we defined a `handle_info/2` clause to pickup the `:sweep` event and clear out the request state. To complete our implementation, we defined a `handle_call/3` clause to track request state for the user and return an `:ok`, or `{:error, :rate_limited}` response for our caller in `log/2`.

Let's try it out in iex:

```elixir
iex> RateLimiter.start_link()
{:ok, #PID<0.126.0>}
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
{:error, :rate_limited}

13:55:44.803 [debug] Sweeping requests
iex(9)> RateLimiter.log("user1")
:ok
```

It works! Once our "user1" exceeded 5 requests/minute, the server returned the expected error response. Then after we waited we observed the debug output of the state sweep, and we confirmed we were no longer rate limited. Looks great right? Unfortunately, there's some serious performance issues in our implementation. Let's see why.

Since this feature is for rate limiting, *all user requests* must pass through this server. Since messages are processed in serial, this effectively limits our application to single-threaded performance, and creates a bottleneck on this single process.

## ETS to the rescue

Fortunately for us, Erlangers solved these kinds of problems for us. We can refactor our rate limiter server to use a publicly accessible ETS table so clients can log their requests directly in ets, and our owning process can be responsible only for sweeping and cleaning up the table. This allows concurrent reads and writes against ETS without having to serialize calls through the single server. Let's make it happen:

```elixir
defmodule RateLimiter do
  use GenServer
  require Logger

  @max_per_minute 5
  @sweep_after :timer.seconds(60)
  @tab :rate_limiter_requests

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def log(uid) do
    case :ets.update_counter(@tab, uid, {2, 1}, {uid, 0}) do
      count when count > @max_per_minute -> {:error, :rate_limited}
      _count -> :ok
    end
  end

  ## Server
  def init(_) do
    :ets.new(@tab, [:set, :named_table, :public, read_concurrency: true,
                                                 write_concurrency: true])
    schedule_sweep()
    {:ok, %{}}
  end

  def handle_info(:sweep, state) do
    Logger.debug("Sweeping requests")
    :ets.delete_all_objects(@tab)
    schedule_sweep()
    {:noreply, state}
  end

  defp schedule_sweep do
    Process.send_after(self(), :sweep, @sweep_after)
  end
end
```

First, we modified our `init/1` function to create an ETS table with the `:named_table` and `:public` options so that callers outside of our process can access it. We also used the `read_concurrency` and `write_concurrency` options to optimize access. Next, we changed our `log/1` function to write the request count to `:ets` directly, rather than going through the `GenServer`. This allows requests to concurrently track their own rate-limit usage. Here we used the `update_counter/4` feature of ETS, which allows us to efficiently, and atomically, update a counter. After checking rate limit usage, we return the same value to the caller as before. Lastly, in our `:sweep` callback, we simply use `:ets.delete_all_objects/1` to wipe the table for the next rate limit interval.

Let's try it out:

```elixir
iex> RateLimiter.start_link
{:ok, #PID<0.124.0>}
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
:ok
iex> RateLimiter.log("user1")
{:error, :rate_limited}
iex> :ets.tab2list(:rate_limiter_requests)
[{"user1", 7}]
iex> RateLimiter.log("user2")
:ok
iex> :ets.tab2list(:rate_limiter_requests)
[{"user2", 1}, {"user1", 7}]

14:27:19.082 [debug] Sweeping requests

iex> :ets.tab2list(:rate_limiter_requests)
[]
iex> RateLimiter.log("user1")
:ok
```

It works just as before. We also used `:ets.tab2list/1` to spy on the data in the table. We can see our users requests are tracked properly, and the table is swept as expected.

That's all there to it. Our public interface remained unchanged and we vastly improve the performance of our mission-critical feature. Not bad!


## Here Be Dragons

This just scratched the surface on what's possible with ETS. But before you get too carried away and extract out all your serialized state access from `GenServer`'s and `Agent`'s to ETS, you need to think carefully about which actions in your application are atomic, and which require serialized access. You can easily introduce race conditions by allowing concurrent reads and writes in the pursuit of performance. One of the beautiful things about Elixir's process model is the serial processing of messages. It lets us avoid race conditions exactly because we can serialize access to state that requires atomic operations. In the case of our rate limiter, each user wrote to ets with the atomic `update_counter` operation so concurrent writes are not a problem. The following rule is helpful to keep in mind when thinking about moving serial access to ETS:

> The operation must be atomic. If clients are reading data from ets in one operation, then writing to ETS based on the result, you have a race condition and the fix is serial access in a server

If you're curious about using ETS for a dependency-free in-memory cache, check out Saša Jurić's excellent [ConCache](https://github.com/sasa1977/con_cache) library.
