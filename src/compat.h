/* SPDX-License-Identifier: MIT
 *
 * Copyright (C) 2021 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
 *
 * compat.h contains code that is backported from FreeBSD's main branch.
 * It is different from support.h, which is for code that is not _yet_ upstream.
 */

#include <sys/param.h>

#if __FreeBSD_version < 1400000
#include <sys/smp.h>
#include <sys/gtaskqueue.h>

struct taskqgroup_cpu {
	LIST_HEAD(, grouptask)  tgc_tasks;
	struct gtaskqueue       *tgc_taskq;
	int     tgc_cnt;
	int     tgc_cpu;
};

struct taskqgroup {
	struct taskqgroup_cpu tqg_queue[MAXCPU];
	/* Other members trimmed from compat. */
};

static inline void taskqgroup_drain_all(struct taskqgroup *tqg)
{
	struct gtaskqueue *q;

	for (int i = 0; i < mp_ncpus; i++) {
		q = tqg->tqg_queue[i].tgc_taskq;
		if (q == NULL)
			continue;
		gtaskqueue_drain_all(q);
	}
}
#endif

#if __FreeBSD_version < 1300000
#define VIMAGE

#include <sys/types.h>
#include <sys/limits.h>
#include <sys/endian.h>
#include <sys/socket.h>
#include <sys/libkern.h>
#include <sys/malloc.h>
#include <sys/proc.h>
#include <sys/lock.h>
#include <sys/socketvar.h>
#include <sys/protosw.h>
#include <net/vnet.h>
#include <net/if.h>
#include <net/if_var.h>
#include <vm/uma.h>

#define taskqgroup_attach(a, b, c, d, e, f) taskqgroup_attach((a), (b), (c), -1, (f))
#define taskqgroup_attach_cpu(a, b, c, d, e, f, g) taskqgroup_attach_cpu((a), (b), (c), (d), -1, (g))

#undef NET_EPOCH_ENTER
#define NET_EPOCH_ENTER(et) NET_EPOCH_ENTER_ET(et)
#undef NET_EPOCH_EXIT
#define NET_EPOCH_EXIT(et) NET_EPOCH_EXIT_ET(et)
#define NET_EPOCH_CALL(f, c) epoch_call(net_epoch_preempt, (c), (f))
#define NET_EPOCH_ASSERT() MPASS(in_epoch(net_epoch_preempt))

#undef atomic_load_ptr
#define atomic_load_ptr(p) (*(volatile __typeof(*p) *)(p))

static inline void m_snd_tag_rele(struct m_snd_tag *mst)
{
	struct ifnet *ifp;
	if (!mst)
		return;
	ifp = mst->ifp;
	ifp->if_snd_tag_free(mst);
	if_rele(ifp);
}

#endif

#if __FreeBSD_version < 1202000
static inline uint32_t arc4random_uniform(uint32_t bound)
{
	uint32_t ret, max_mod_bound;

	if (bound < 2)
		return 0;

	max_mod_bound = (1 + ~bound) % bound;

	do {
		ret = arc4random();
	} while (ret < max_mod_bound);

	return ret % bound;
}

typedef void callout_func_t(void *);
#endif
