/* SPDX-License-Identifier: BSD-2-Clause-FreeBSD
 *
 * Copyright (C) 2015-2021 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
 */

#include "support.h"
#include <sys/socketvar.h>
#include <sys/protosw.h>
#include <net/vnet.h>

int
sogetsockaddr(struct socket *so, struct sockaddr **nam)
{
	int error;

	CURVNET_SET(so->so_vnet);
	error = (*so->so_proto->pr_usrreqs->pru_sockaddr)(so, nam);
	CURVNET_RESTORE();
	return (error);
}
