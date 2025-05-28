# Tschat

An proof of concept Elixir-based chat app for your Tailscale network that uses
Tailscale to authenticate clients.

This app uses is based in the [`libtailscale` NIF
wrapper](https://hex.pm/packages/libtailscale),
[`gen_tailscale`](https://hex.pm/packages/gen_tailscale) and
[`tailscale_transport`](https://hex.pm/packages/tailscale_transport) to make
Phoenix/Bandit expose the application directly to your Tailscale network.

## Warning

Everything in this chain of packages should be considered proof of concept at
this point and should not be used for anything important. Especially
`gen_tailscale`, which has been constructed by crudely hacking the original
`gen_tcp` module to use `libtailscale` and could use a total rewrite at some
point.

## Usage

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`tschat:4000`](http://tschat:4000) from your browser.
