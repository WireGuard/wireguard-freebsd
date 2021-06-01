#!/usr/bin/env bash
#
# SPDX-License-Identifier: MIT
#
# Copyright (C) 2015-2021 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
#
# This requires iperf3, bash, and wireguard-tools.

set -e
exec 3>&1
export LANG=C
export WG_HIDE_KEYS=never
pretty() { echo -e "\x1b[32m\x1b[1m[+] ${1:+J$1: }${2}\x1b[0m" >&3; }
pp() { pretty "" "$*"; "$@"; }
maybe_exec() { if [[ $BASHPID -eq $$ ]]; then "$@"; else exec "$@"; fi; }
je() { local jid="$1"; shift; pretty "$jid" "$*"; maybe_exec jexec "$jid" "$@"; }
j0() { je "$jid0" "$@"; }
j1() { je "$jid1" "$@"; }
j2() { je "$jid2" "$@"; }
ifconfig0() { j0 ifconfig "$@"; }
ifconfig1() { j1 ifconfig "$@"; }
ifconfig2() { j2 ifconfig "$@"; }
waitiperf() { pretty "$1" "wait for iperf:${3:-5201} pid $2"; jexec "$1" bash -c "while ! sockstat -ql -P tcp -p '${3:-5201}' | grep -Eq 'iperf3[[:space:]]+$2[[:space:]]'; do sleep 0.1; done;"; }

cleanup() {
	set +e
	exec 2>/dev/null
	for i in 0 1 2; do
		ifconfig$i wg1 destroy
		ifconfig$i wg2 destroy
	done
	pp jail -r $jid0 # Should take care of children
	exit
}

trap cleanup EXIT

key1="$(pp wg genkey)"
key2="$(pp wg genkey)"
pub1="$(pp wg pubkey <<<"$key1")"
pub2="$(pp wg pubkey <<<"$key2")"
psk="$(pp wg genpsk)"
[[ -n $key1 && -n $key2 && -n $pub1 && -n $pub2 && -n $psk ]]

jid0="$(pp jail -ic path=/ vnet=new children.max=2 persist)"
jid1="$(j0 jail -ic path=/ vnet=new persist)"
jid2="$(j0 jail -ic path=/ vnet=new persist)"

pp sysctl net.inet.udp.maxdgram=65535 # Global! Eep!
pp sysctl net.inet.udp.recvspace=65535 # Global! Eep!
j0 sysctl net.inet6.ip6.dad_count=0
j1 sysctl net.inet6.ip6.dad_count=0
j2 sysctl net.inet6.ip6.dad_count=0
ifconfig0 lo0 mtu 65535
ifconfig0 lo0 127.0.0.1/8
ifconfig0 lo0 inet6 ::1/128
ifconfig0 lo0 up
ifconfig0 wg1 create
ifconfig0 wg1 debug
ifconfig0 wg1 vnet $jid1
ifconfig0 wg2 create
ifconfig0 wg2 debug
ifconfig0 wg2 vnet $jid2

configure_peers() {
	ifconfig1 wg1 inet 192.168.241.1/24
	ifconfig1 wg1 inet6 fd00::1/112 up

	ifconfig2 wg2 inet 192.168.241.2/24
	ifconfig2 wg2 inet6 fd00::2/112 up

	j1 wg set wg1 \
		private-key <(echo "$key1") \
		listen-port 1 \
		peer "$pub2" \
			preshared-key <(echo "$psk") \
			allowed-ips 192.168.241.2/32,fd00::2/128
	j2 wg set wg2 \
		private-key <(echo "$key2") \
		listen-port 2 \
		peer "$pub1" \
			preshared-key <(echo "$psk") \
			allowed-ips 192.168.241.1/32,fd00::1/128
}
configure_peers

tests() {
	# Ping over IPv4
	j2 ping -c 10 -f -W 1 192.168.241.1
	j1 ping -c 10 -f -W 1 192.168.241.2

	# Ping over IPv6
	local wtarg=-W
	[[ $(ping6 2>&1) == *"-x waittime"* ]] && wtarg=-x # Terrible FreeBSD12ism, fixed in 13
	j2 ping6 -c 10 -f $wtarg 1 fd00::1
	j1 ping6 -c 10 -f $wtarg 1 fd00::2

	# TCP over IPv4
	j2 iperf3 -s -1 -B 192.168.241.2 &
	waitiperf $jid2 $!
	j1 iperf3 -Z -t 3 -c 192.168.241.2

	# TCP over IPv6
	j1 iperf3 -s -1 -B fd00::1 &
	waitiperf $jid1 $!
	j2 iperf3 -Z -t 3 -c fd00::1

	# UDP over IPv4
	j1 iperf3 -s -1 -B 192.168.241.1 &
	waitiperf $jid1 $!
	j2 iperf3 -Z -t 3 -b 0 -u -c 192.168.241.1

	# UDP over IPv6
	j2 iperf3 -s -1 -B fd00::2 &
	waitiperf $jid2 $!
	j1 iperf3 -Z -t 3 -b 0 -u -c fd00::2

	# TCP over IPv4, in parallel
	for max in 4 5 50; do
		local pids=( )
		for ((i=0; i < max; ++i)) do
			j2 iperf3 -p $(( 5200 + i )) -s -1 -B 192.168.241.2 &
			pids+=( $! ); waitiperf $jid2 $! $(( 5200 + i ))
		done
		for ((i=0; i < max; ++i)) do
			j1 iperf3 -Z -t 3 -p $(( 5200 + i )) -c 192.168.241.2 &
		done
		wait "${pids[@]}"
	done
}

[[ $(ifconfig1 wg1) =~ mtu\ ([0-9]+) ]] && orig_mtu="${BASH_REMATCH[1]}"
big_mtu=$(( 65535 - 1500 + $orig_mtu ))

# Test using IPv4 as outer transport
ifconfig1 wg1 mtu $orig_mtu
ifconfig2 wg2 mtu $orig_mtu
j1 wg set wg1 peer "$pub2" endpoint 127.0.0.1:2
j2 wg set wg2 peer "$pub1" endpoint 127.0.0.1:1
tests
ifconfig1 wg1 mtu $big_mtu
ifconfig2 wg2 mtu $big_mtu
tests

# Test using IPv6 as outer transport
ifconfig1 wg1 mtu $orig_mtu
ifconfig2 wg2 mtu $orig_mtu
j1 wg set wg1 peer "$pub2" endpoint [::1]:2
j2 wg set wg2 peer "$pub1" endpoint [::1]:1
tests
ifconfig1 wg1 mtu $big_mtu
ifconfig2 wg2 mtu $big_mtu
tests
