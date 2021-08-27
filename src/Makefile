# $FreeBSD$

KMOD= if_wg

SRCS= opt_inet.h opt_inet6.h device_if.h bus_if.h ifdi_if.h

SRCS+= if_wg.c wg_noise.c wg_cookie.c crypto.c

CFLAGS.if_wg.c+= -include ${.CURDIR}/compat.h

.include <bsd.kmod.mk>
