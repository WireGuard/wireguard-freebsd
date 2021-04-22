### Primary systems TODO

- Finish porting [this script](https://git.zx2c4.com/wireguard-linux/tree/tools/testing/selftests/wireguard/netns.sh)
  to `./tests/netns.sh` using vnets and epairs.
- Rework locking and epoch lifetimes; come up with consistent set of rules.
- Shore up vnet support and races/locking around moving between vnets.
- Work out `priv_check` from vnet perspective. (There's no `ns_capable()` on
  FreeBSD, just `capable()`, which makes it a bit weird for one jail to have
  permissions in another.)
- Make code style consistent with one FreeBSD way, rather than a mix of styles.
- Make sure noise state machine is correct.
- The cookie logic appears to be broken in unusual ways, in particular right
  after boot up. Audit and compare all `is_valid` checks, as well as
  `have_sent_mac1` guards.
- Investigate whether the allowed ips lookup structure needs reference
  counting.
- Handle failures of `rn_inithead` and remember to call `rn_detachhead`
  somewhere during cleanup.
- Stop using `M_WAITOK` and use `M_NOWAIT` instead.
- Make sure ratelimiter is empty and deinited.
- Check return value of `rn_inithead`.
- Perhaps call `rn_detachhead` to free memory when destroying aip.
- Have one rate limiter table per module, and hash in jail/fib pointer.

### Crypto TODO

- Do packet encryption using opencrypto/ with sg lists on the mbuf, so that we don't need to linearize mbufs.
- Send 25519 upstream to sys/crypto, and port to it.
- Send simple chapoly upstream to sys/crypto, and port to it.
- Port to sys/crypto's blake2s implementation.

### Tooling TODO

- Relicense wg(8) as MIT and integrate into upstream build system.
- Examine possibility of a non-bash wg-quick(8) for sending upstream.
