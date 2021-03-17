# WireGuard for FreeBSD

This is a kernel module for FreeBSD to support [WireGuard](https://www.wireguard.com/). It is being developed here before its eventual submission to FreeBSD 13.1 or 14.

### Installation instructions

First make sure you have the latest net/wireguard package installed, version ≥1.0.20210315.

Then, on FreeBSD 13.0:

```
# pkg install wireguard
# git clone https://git.zx2c4.com/wireguard-freebsd
# cd wireguard-freebsd/src
# make load
# make install
```

After that, it should be possible to use `wg(8)` and `wg-quick(8)` like usual, but with the faster kernel implementation.
