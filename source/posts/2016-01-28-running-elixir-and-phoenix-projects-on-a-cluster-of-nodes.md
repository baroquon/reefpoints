---
layout: post
title: "Running Elixir and Phoenix projects on a cluster of nodes"
social: true
author: Chris McCord
twitter: "chris_mccord"
github: chrismccord
summary: "How to use distributed elixir in a few simple steps"
published: true
tags: elixir, phoenix, deployment
---

Once you're ready to deploy your Elixir application to multiple servers, you'll want to take advantage of the distributed features that the runtime offers. For example, if you are using Phoenix channels, you'll want broadcasts to be sent across the cluster. You can setup your deployment as a cluster in a few simple steps:

Start by creating a new `sys.config` file in your project. We'll conventionally use the name `sys.config` because Erlang assumes exactly one system configuration file is used when building releases, with this name. Add the following contents the new file:

```erlang
[{kernel,
  [
    {sync_nodes_optional, ['n1@127.0.0.1', 'n2@127.0.0.1']},
    {sync_nodes_timeout, 10000}
  ]}
].
```

In this example, we have two nodes in the cluster, `n1@127.0.0.1` and `n2@127.0.0.1`. The `sync_nodes_optional` configuration specifies which nodes to attempt to connect to within the `sync_nodes_timeout` window, before continuing with startup. There is also a `sync_nodes_mandatory` key which can be used to enforce all nodes are connected within the timeout window or else the node terminates. With our `sys.config` in place, we can pass a VM `-config` flag to use our configuration when booting the Erlang VM. For example, you could start two iex sessions like this:

```console
n1@host$ iex --name n1@127.0.0.1 --erl "-config sys.config" -S mix
n2@host$ iex --name n2@127.0.0.1 --erl "-config sys.config" -S mix
iex(n2@127.0.0.1)1> Node.list
[:"n1@127.0.0.1"]
```

If you're building Phoenix projects, you could start your servers like this:

```console
n1@host$ elixir --name n1@127.0.0.1 --erl "-config sys.config" -S mix phoenix.server
n2@host$ elixir --name n2@127.0.0.1 --erl "-config sys.config" -S mix phoenix.server
```

You might be wondering why we have to use Erlang-based configuration in our `sys.config` instead of Mix configuration. This is because the configuration must be passed to the Erlang VM when starting. By the time Mix configuration would be loaded, the VM has already booted. That said, we can use Mix configuration to drive our `sync_nodes_optional` list if we are using [exrm](https://github.com/bitwalker/exrm) to build releases for deployment. `exrm` builds your Mix configuration into a `sys.config` within the release, which lets you specify your node configuration like this, in your Mix config:

```elixir
config :kernel,
  sync_nodes_optional: [:"n1@127.0.0.1", :"n2@127.0.0.1"],
  sync_nodes_timeout: 10000
```

Then you build and run your releases as normal and the proper VM configuration is provided when starting. For a complete rundown on using `exrm` to deploy a Phoenix project, see the [official guide](http://www.phoenixframework.org/docs/advanced-deployment).

That's all it takes to run distributed Elixir on a cluster of servers! The Erlang VM supports a number of more advanced options and strategies for running distributed applications, including automatic application failover to a configured subset of nodes, and more. See the [Erlang documentation](http://erlang.org/doc/design_principles/distributed_applications.html) for a comprehensive rundown.
