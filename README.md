# WireGuard for FreeBSD

This is a kernel module for FreeBSD to support [WireGuard](https://www.wireguard.com/). It is being developed here before its eventual submission to FreeBSD.

### Installation instructions

Snapshots of this may be installed from packages:

```
# pkg install wireguard
```

### Building instructions

If you'd prefer to build this repo from scratch, rather than using a package, first make sure you have the latest net/wireguard-tools package installed, version ≥1.0.20210424. Then, on FreeBSD 12.3, 13.0, 13.1, and 13.2:

```
# git clone https://git.zx2c4.com/wireguard-freebsd
# make -C wireguard-freebsd/src
# make -C wireguard-freebsd/src load install
```

After that, it should be possible to use `wg(8)` and `wg-quick(8)` like usual, but with the faster kernel implementation.
