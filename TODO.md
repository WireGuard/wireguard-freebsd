### Primary TODO

- Finish porting [this script](https://git.zx2c4.com/wireguard-linux/tree/tools/testing/selftests/wireguard/netns.sh)
  to `./tests/netns.sh` using vnets and epairs.
- Shore up vnet support and races/locking around moving between vnets.
- Work out `priv_check` from vnet perspective. (There's no `ns_capable()` on
  FreeBSD, just `capable()`, which makes it a bit weird for one jail to have
  permissions in another.)
- Make code style consistent with one FreeBSD way, rather than a mix of styles.
- Review all included headers, and minimize a bit.
- Figure out clear locking rules for network stack stuff -- when different
  functions run under what locks and what they race with.

### Crypto TODO

- Do packet encryption using opencrypto/ with sg lists on the mbuf.
- Send 25519 upstream to sys/crypto, and port to it.
- Send simple chapoly upstream to sys/crypto, and port to it.
- Port to sys/crypto's blake2s implementation.

### Tooling TODO

- Relicense wg(8) as MIT and integrate into upstream build system.
- Examine possibility of a non-bash wg-quick(8) for sending upstream.
