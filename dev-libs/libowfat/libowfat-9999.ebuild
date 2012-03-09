# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libowfat/libowfat-0.28-r1.ebuild,v 1.7 2012/01/31 22:10:07 jer Exp $

EAPI=2

inherit flag-o-matic toolchain-funcs git-2

DESCRIPTION="reimplement libdjb - excellent libraries from Dan Bernstein."
HOMEPAGE="http://www.fefe.de/libowfat/"
if [[ ${PV} = 9999* ]]; then
	EGIT_REPO_URI="git://github.com/olliwolli/libowfat.git"
	SRC_URI=""
	KEYWORDS=""
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="diet"

RDEPEND="diet? ( >=dev-libs/dietlibc-0.33_pre20090721 )"
DEPEND="${RDEPEND}
	>=sys-apps/sed-4"

pkg_setup() {
	# Required for mult/umult64.c to be usable
	append-flags -fomit-frame-pointer
}

src_prepare() {
	[[ -z GNUmakefile ]] && die "No GNUmakefile found"
	sed -i \
		-e "s:^CFLAGS.*:CFLAGS=-I. ${CFLAGS}:" \
		-e "s:^DIET.*:DIET?=/usr/bin/diet -Os:" \
		-e "s:^prefix.*:prefix=/usr:" \
		-e "s:^INCLUDEDIR.*:INCLUDEDIR=\${prefix}/include/libowfat:" \
		GNUmakefile || die "sed failed"
}

src_compile() {
	emake \
		CC=$(tc-getCC) \
		$( use diet || echo 'DIET=' )
}

src_install () {
	emake \
		LIBDIR="${D}/usr/lib" \
		MAN3DIR="${D}/usr/share/man/man3" \
		INCLUDEDIR="${D}/usr/include/libowfat" \
		install || die "emake install failed"

	cd "${D}"/usr/share/man
	mv man3/buffer.3 man3/owfat-buffer.3
}
