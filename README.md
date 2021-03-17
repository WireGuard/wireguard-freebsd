# WireGuard for FreeBSD

This is a kernel module for FreeBSD to support [WireGuard](https://www.wireguard.com/). It is being developed here before its eventual submission to FreeBSD 13.1 or 14.

### Installation instructions

First make sure you have the latest net/wireguard package installed, version ≥1.0.20210315.

Then, on FreeBSD 12 &amp; 13:

```
# git clone https://git.zx2c4.com/wireguard-freebsd
# make -C wireguard-freebsd/src load install
```

After that, it should be possible to use `wg(8)` and `wg-quick(8)` like usual, but with the faster kernel implementation.
