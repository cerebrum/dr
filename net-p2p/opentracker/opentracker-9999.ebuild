# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit git-2

DESCRIPTION="An open and free bittorrent tracker"
HOMEPAGE="http://erdgeist.org/arts/software/opentracker/"
if [[ ${PV} = 9999* ]]; then
	EGIT_REPO_URI="git://github.com/wereHamster/opentracker.git"
	SRC_URI=""
	KEYWORDS=""
fi

LICENSE="BEER-WARE"
SLOT="0"
#TODO set (+)default and exclusivity (blacklist, ...)
IUSE="blacklist debug gzip ipv6 live-sync log-network restrict-stats syslog whitelist"

DEPEND="dev-libs/dietlibc
		>=dev-libs/libowfat-0.27"
# dietlibc make static binary
RDEPEND=""

src_compile() {
	# TODO: are we safe with a simple sed failure ?xs
	[[ -z Makefile ]] && die "No Makefile found"
	# fix use of FEATURES, so it's not mixed up with portage's FEATURES (#214969)
	nonfatal sed -i \
		-e "s|FEATURES|FEATURES_INTERNAL|g" \
		-e "s|PREFIX?=..|PREFIX?=/usr|g" \
		-e "s|LIBOWFAT_HEADERS=\$(PREFIX)/libowfat|LIBOWFAT_HEADERS=\$(PREFIX)/include/libowfat|g" \
		-e "s|-pthread|-lpthread|g" \
		-e "s|CC?=gcc|CC=diet gcc|g" \
		-e "s|BINDIR?=\$(PREFIX)/bin|BINDIR?=\$(DESTDIR)\$(PREFIX)/bin|g" \
		Makefile

	use ipv6 && sed -i '/WANT_V6/s/^#*//' Makefile
	use blacklist && use whitelist && die "USE blacklist and whitelist are exclusive"
	use blacklist && sed -i '/DWANT_ACCESSLIST_BLACK/s/^#*//' Makefile
	use whitelist && sed -i '/DWANT_ACCESSLIST_WHITE/s/^#*//' Makefile
	use !debug && sed -i 's/^OPTS_debug/#OPTS_debug/' Makefile
	use gzip && sed -i '/DWANT_COMPRESSION_GZIP/s/^#*//' Makefile
	use restrict-stats && sed -i '/DWANT_RESTRICT_STATS/s/^#*//' Makefile
	use live-sync && sed -i '/DWANT_SYNC_LIVE/s/^#*//' Makefile
	use log-network && sed -i '/DWANT_LOG_NETWORKS/s/^#*//' Makefile
	use syslog && sed -i '/DWANT_SYSLOG/s/^#*//' Makefile

	local target=opentracker
	if use debug; then
		sed -i '/D_DEBUG_HTTPERROR/s/^#*//' Makefile
		# tricky: build opentracker.debug but target as opentracker
		sed -i 's/$@ $(OBJECTS_debug)/opentracker $(OBJECTS_debug)/' Makefile
		target=opentracker.debug
	fi

	nonfatal emake $target
}

src_install() {
	dodir /usr/bin
	emake install DESTDIR="${D}"
	nonfatal dodoc README README_v6 opentracker.conf.sample
	nonfatal newinitd "${FILESDIR}/${PN}.init.d" ${PN}
	nonfatal newconfd "${FILESDIR}/${PN}.conf.d" ${PN}
}

pkg_postinst() {
	#! [[ "${FEATURES}" =~ nostrip ]]
	use debug && \
	# commented-out as splitdebug doesn't created /usr/lib/debug
	#! has splitdebug ${FEATURES} && \
	! has nostrip ${FEATURES} && \
	ewarn "debug useflag efficiency depends upon FEATURES=splitdebug or FEATURES=nostrip"
}
