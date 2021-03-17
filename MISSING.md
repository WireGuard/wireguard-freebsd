### Things missing out-of-tree

There are a few changes that we had in-tree that we now don't, and will need to add back when this is merged.

- Link local address for the new ether type, `IFT_WIREGUARD`.
- The `PRIV_NET_WG` privilege.
- `sogetsockaddr` helper function, which belongs in `uipc_socket.c`.

We're emulating these in support.h, but they should go away for the merge.
