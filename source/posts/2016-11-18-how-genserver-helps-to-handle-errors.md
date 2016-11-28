---
layout: post
title: "How GenServer deals with errors in a concurrent environment"
summary: "GenServer can help deal with race conditions, deadlocks, and many edge cases"
author: "Daniel Xu"
twitter: "Daniel_Xu_For"
github: "Daniel-Xu"
published: true
tags: Elixir
---

## Pattern for stateful server process

After newcomers wrap their minds around immutability, they quickly question how to hold and change state in a language that
does not allow mutation. Elixir uses Erlang's OTP libraries to formalize state access and mutation,
but to understand how this can happen in an immutable world we can implement our own stateful server using only a process with tail recursion:

* In the following sample code, we define a start function which can be used to start the server process with an initial state.
* Because of `receive`, the process will be blocked to wait for messages. Whenever clients send a message to the server process using `call`,
  it will pattern match on `{:message, caller, msg}` and invoke the corresponding function to get the new state.
* After getting the new state, it replies to the client and runs the loop function from the beginning with the new state.

```elixir
def start(inital_state) do
  spawn(fn ->
    initial_state = ...
    loop(initial_state)
  end)
end

defp loop(state) do
  receive do
    {:message, caller, msg} ->
      new_state = handle(msg, state)
      send(caller, {:reply, new_msg})
      loop(new_state)
    :stop -> terminate()
  end
end

def call(name_or_pid, message)
  send(name_or_pid, {:message, self(), message})
  receive do
    {:reply, reply} -> reply
  end
end
```

It's simple but error-prone because we don't handle any error condition. This becomes more complicated when dealing with a concurrent environment.
The good news is that [GenServer](http://elixir-lang.org/docs/stable/elixir/GenServer.html) can help deal with race conditions, deadlocks,
and many edge cases.

## GenServer helps with error handling

### Ensure source of message using `reference`

In the stateful server process above, the client sends a message to the server with a format of `{:message, pid_or_name, message}`
and waits for a message with a format of `{:reply, reply}`.

As shown in the picture, the client might receive a similarly formatted reply from different servers,
how can we make sure that the reply is from the correct server?

![msg](http://d.pr/i/BS8a+)

The solution is to use **a unique reference** to tag the message. when the client sends a request to the server,
it creates a unique reference first and sends it with its pid together: `{:message, {ref, pid}, message}`,
and the server can reply with `{:reply, ref, reply}`. This way, the client can pattern match based on the unique reference.

Now, the `call` function becomes:

```elixir
def call(name_or_pid, message)
  ref = make_ref()
  send(name_or_pid, {:message, {ref, self()}, message})
  receive do
    {:reply, ^ref, reply} -> reply
  end
end
```

Erlang/OTP solves this problem with a unique reference as shown [here](https://github.com/erlang/otp/blob/maint/lib/stdlib/src/gen.erl#L167).

### What if the server crashes

1. Server crashes before message is sent by client via server Pid

  If the server crashes before the message is sent from the client, the message will be lost and the client will be **blocked** in the `receive` block.

  The solution is to monitor the server process using `Process.monitor(server_pid)`. The reason why we choose `monitor` instead of
  `links` is that monitor is unidirectional, so termination of the client will not affect the server.

  In case of a server crash, the client will receive a `Down` message, so we can take action in the `receive` block.
  Noting that `monitor` returns a reference, we can now drop the `make_ref()`.

2. Server crashes before message is sent by client via registered name

  In this case, the client process will terminate. To avoid crashing and return better error stack, we need to rescue the runtime error by
  using `try...rescue`.

3. Server crashes right after replying to client

  If the server crashes right after it sends its reply to the client, a `Down` message will be sent to the client's
  mailbox. The client, however, will never have a chance to pattern match this message because it `demonitors` the server.

  This might cause memory leak and slow down the server. Ultimately, a single slow process may cause an entire system to crash by consuming all the available memory.

  `Process.demonitor(ref, [:flush])` is the solution for this issue. Every time we demonitor a server,
  passing in a `flush` option can make sure that any Down message that belongs to that monitor will be cleared.

After handling the server crash, the `call` function looks like:

```elixir
def call(name_or_pid, message, timeout \\ 5000)
  ref = Process.monitor(name_or_pid)
  try do
    send(name_or_pid, {:message, {ref, self()}, message})
  rescue
    _ -> :error
  end
  receive do
    {:reply, ref, reply} ->
      Process.demonitor(ref, [:flush])
      reply
    {:DOWN, ref, ...} ->
      {:error, reason}
      exit(reason)
    {:DOWN, ref, ..., :noconnection} ->
      node = get_node(name_or_pid)
      exit({:node_down, node})
  after timeout -> exit(:timeout)
  end
end
```

### Deadlock

If two processes synchronously call each other using the code above, both of them enter the `receive` block which will cause
a [Deadlock](https://en.wikipedia.org/wiki/Deadlock). This can be resolved with a timeout in the receive block. When the time is
out, the system can terminate the process and release the resources held by the process.

An example is shown [here](https://github.com/erlang/otp/blob/maint/lib/stdlib/src/gen.erl#L178-L181).

## Conclusion

There are a lot more concurrent errors that we haven't discussed yet. Fortunately, GenServer handles all the concurrent conditions and
edge cases, we should almost always use it instead of reinventing the wheel.
