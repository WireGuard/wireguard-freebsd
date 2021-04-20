/* SPDX-License-Identifier: ISC
 *
 * Copyright (C) 2021 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
 * Copyright (c) 2021 Kyle Evans <kevans@FreeBSD.org>
 *
 * support.h contains code that is not _yet_ upstream in FreeBSD's main branch.
 * It is different from compat.h, which is strictly for backports.
 */

#ifndef _WG_SUPPORT
#define _WG_SUPPORT

#include <sys/socket.h>
#include <sys/socketvar.h>
#include <sys/protosw.h>
#include <net/vnet.h>

#ifndef PRIV_NET_WG
#define PRIV_NET_WG PRIV_NET_HWIOCTL
#endif

#ifndef IFT_WIREGUARD
#define IFT_WIREGUARD IFT_PPP
#endif

#ifndef ck_pr_store_bool
#define ck_pr_store_bool(dst, val) ck_pr_store_8((uint8_t *)(dst), (uint8_t)(val))
#endif

#ifndef ck_pr_load_bool
#define ck_pr_load_bool(src) ((bool)ck_pr_load_8((uint8_t *)(src)))
#endif

static inline int
sogetsockaddr(struct socket *so, struct sockaddr **nam)
{
	int error;

	CURVNET_SET(so->so_vnet);
	error = (*so->so_proto->pr_usrreqs->pru_sockaddr)(so, nam);
	CURVNET_RESTORE();
	return (error);
}

#endif
