---
layout: post
title: "Concurrent, Transactional End-to-End Tests with Ember and Phoenix"
social: true
author: Estelle DeBlois
summary: "This post explores how you can leverage the enhanced SQL sandbox functionality of `phoenix_ecto` to unlock concurrent, transactional end-to-end tests for your Ember and Phoenix stack."
published: true
tags: engineering, elixir, phoenix, ember
---

![Shot of biker on a bridge by Matthew Henry](https://i.imgur.com/Y4dJ9H1.png)

In the latest release of [`phoenix_ecto`](https://github.com/phoenixframework/phoenix_ecto) (version 3.3.0), Chris McCord introduced exciting changes to help bring the power of concurrent, transactional browser tests to our doorstep. The revised `Phoenix.Ecto.SQL.Sandbox` plug makes it a breeze to write client-side acceptance tests that hit actual API endpoints, rather than ones that execute against mocks.

While this push was motivated by DockYard's internal needs to support end-to-end tests for our own Ember and Phoenix stack, the implementation that landed in `phoenix_ecto` itself is completely agnostic of any client frameworks.

Before we take a closer look at `phoenix_ecto` and how we can rewrite Ember acceptance tests to take advantage of the new feature, let's briefly address an inevitable question.

## What's wrong with mocks?

Mocks still have their place in the frontend testing landscape. Developers may find themselves in need to develop features and write associated tests before the API endpoints are ready. Perhaps they are working within an environment that doesn’t give them full control over the backend. Mocks also result in tests that run faster, since server-side logic and database operations are removed from the picture altogether.

However, mocks also have the potential downside of concealing errors that creep up when they start growing out of sync with the actual API, or when invalid assumptions are made about how the server would respond to certain requests.

Just as integration tests complement unit tests, and acceptance tests complement integration tests, end-to-end tests provide developers with additional confidence that their application works as expected when pieced together. Many developers avoid going down this path, arguing that these tests are often too slow and flaky. This may have been proven true historically, but perhaps it is time to revisit this strategy.

## `Phoenix.Ecto.SQL.Sandbox`

Previous releases of `phoenix_ecto` already shipped with a plug named [`Phoenix.Ecto.SQL.Sandbox`](https://github.com/phoenixframework/phoenix_ecto/blob/v3.2.3/lib/phoenix_ecto/sql/sandbox.ex), which made it possible for Elixir developers to write concurrent, transactional tests for their Phoenix apps with ease. This is typically done in conjunction with testing libraries such as [Hound](https://github.com/HashNuke/Hound) or [Wallaby](https://github.com/keathley/wallaby), which simulate user interactions via headless browsers or Selenium WebDriver.

Let's take some time to understand how the underlying sandbox functionality works.

### Ecto's SQL Sandbox

By default, the test database for a Phoenix app is configured to use a sandbox connection pool called [Ecto.Adapters.SQL.Sandbox](https://hexdocs.pm/ecto/Ecto.Adapters.SQL.Sandbox.html). Using this, a process is able to check out a connection from the pool and take ownership of it. The sandbox manages that connection by wrapping it in a transaction that gets rolled back when the process either dies or checks the connection back in. The sandbox can also allow other processes to participate in the same transaction as the owning process.

```elixir
# Check out a connection
Ecto.Adapters.SQL.Sandbox.checkout(Repo)

# Allow another process (`pid`) to use the same connection
Ecto.Adapters.SQL.Sandbox.allow(Repo, self(), pid)

# Check in a connection
Ecto.Adapters.SQL.Sandbox.checkin(Repo)
```

This fulfills the need to not only have isolated tests, but also to return the database to its initial state once a test is complete.

### Maintaining a sandbox session

Over the course of a single test, a client may send multiple requests to the server, each resulting in a different process being spawned. For these to share the same sandboxed connection as the owning process that initiated the checkout, there must be a way to identify the active session.

The `Phoenix.Ecto.SQL.Sandbox` plug provides a function called `metadata_for/2` that can be called to get a map that identifies a session by its repository and owner's PID: `%{repo: repo, owner: pid}`. The setup for a test in Phoenix may look like this:

```ex
use Hound.Helpers

setup do
  :ok = Ecto.Adapters.SQL.Sandbox.checkout(YourApp.Repo)
  metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(YourApp.Repo, self())
  Hound.start_session(metadata: metadata)
end
```

Here, a connection is checked out from the pool, and the metadata is fed into `Hound` in order to associate all subsequent operations with that same sandbox session. The plug takes care of inspecting all incoming requests for the presence of a `user-agent` header that includes this metadata, and grants access to the sandboxed connection accordingly.

## Transactional Ember acceptance tests

When we explored using the plug to support end-to-end tests written with Ember, prior to `phoenix_ecto` 3.3.0, some limitations became apparent.

The first was that the plug only looked for the session metadata in the `user-agent` request header, and most browsers do not let you overwrite this value. This one was easily solved by making the request header configurable, a fix that made it into the latest release of `phoenix_ecto`.

The second issue was that there was no built-in functionality to check out and check in connections from an external HTTP client.

### Introducing Sandbox API endpoints

The client needs to be able to communicate with the server that a test is starting and that a new connection needs to be checked out from the sandbox pool. It also needs to be able to tell it to check the connection back in once the test is complete, so that we can roll back the transaction, along with any associated side effects.

This can be achieved very simply by introducing the following endpoints on the server, and protecting them so that they are only exposed when running Phoenix in a test environment:

* `POST http://localhost:4000/api/sandbox`
* `DELETE http://localhost:4000/api/sandbox`

We will take a look at the implementation details for those endpoints in a moment, but for now, let's remain focused on the client.

Armed with those endpoints, the setup and teardown for each acceptance test in Ember are straightforward:

```js
beforeEach() {
  return fetch('/api/sandbox', { method: 'POST' })
    .then((response) => response.text())
    .then((metadata) => {
      // Set the required header for all subsequent requests
      setHeader(this.application, 'x-user-agent', metadata);
    });
},

afterEach() {
  return fetch('/api/sandbox', { method: 'DELETE' });
}
```

The `beforeEach` hook makes a request to the server to start a new sandbox session, and stores the session metadata in a header for all subsequent requests (the implementation of `setHeader` will vary depending on whether you use `jQuery.ajax()` or `fetch`). Finally, the `afterEach` hook sends a request to the server at the end of the test to destroy the session. You can add this logic to the `module-for-acceptance.js` helper and continue to write acceptance tests as you always have.

Of course, the Phoenix server must be up and running during these tests (using an environment configured with the sandbox). Ember CLI also must be configured to proxy API requests to the backend:

```js
// Snippet config from testem.js
"proxies": {
  "/api": {
    "target": "http://localhost:4000"
  }
}
```

### Sandbox API: Behind the scenes

The tricky part isn’t on the Ember side of the implementation. Rather, it has to do with how the sandbox endpoints are implemented. One might be tempted to think we could just set up a controller action to respond to the checkout request this way:

```ex
def checkout(conn, _) do
  :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Repo, self())
  send_resp(200, encode_metadata(metadata))
end
```

However, this approach quickly falls apart because the process that owns the connection would have already been terminated by the time the check-in is requested.

A solution for keeping the owner process alive is to create a `GenServer` to handle the session:

```ex
defmodule SandboxSession do
  use GenServer

  def start_link(repo, opts) do
    GenServer.start_link(__MODULE__, [repo, opts])
  end

  def init([repo, opts]) do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(repo)
    {:ok, %{repo: repo}}
  end

  def handle_call(:checkin, _from, state) do
    :ok = Ecto.Adapters.SQL.Sandbox.checkin(state.repo)
    {:stop, :shutdown, :ok, state}
  end
end
```

When a `POST /api/sandbox` request is received, we spawn a new process to own the sandboxed connection, so that it persists even after the server has finished responding to the request. The code snippet above is a simplified example. In reality, we would need to make the code more robust by adding proper timeout handling, in case there is a longer than acceptable delay between checkouts and checkins. We also need to have this sandbox session be a worker that is managed by its own supervisor process.

You can explore the details of the final solution in the [PR](https://github.com/phoenixframework/phoenix_ecto/pull/91) that brought forth this feature in `phoenix_ecto`.

Today, the configuration to enable all of this functionality couldn’t be simpler. After adding the `Phoenix.Ecto.SQL.Sandbox` plug to your application endpoint, you just need to configure the sandbox route name, request header, and repository:

```ex
plug Phoenix.Ecto.SQL.Sandbox,
  at: "/sandbox",
  header: "x-user-agent",
  repo: MyApp.Repo
```

Behind the scenes, `phoenix_ecto` takes care of all the routing, process spawning, supervising, etc. that we described above.

## Concurrent Ember acceptance tests

The story wouldn't be complete without a word on concurrency. While hitting actual API endpoints and interacting with the database has its advantages, it also makes the tests slower than if the server responses were mocked out.

On the backend, concurrency is a no-brainer if you use PostgreSQL, as the database already supports concurrent tests with the SQL Sandbox. On the frontend, concurrency can be enabled with [`ember-exam`](https://github.com/trentmwillis/ember-exam) (you will need to enable the `parallel` option in Testem as well). Whether you're spinning up multiple browser instances or configure Testem to use headless Chrome (the default in Ember CLI 2.15), you can cut your test execution time significantly, by splitting the test suite into partitions and running them in parallel--all while hitting the actual API server.

The following command, for example, will split the tests into four partitions that will execute concurrently.

```sh
ember exam --split=4 --parallel
```

So there you have it: concurrent, transactional end-to-end tests for your Phoenix-powered Ember app, with very little configuration!
