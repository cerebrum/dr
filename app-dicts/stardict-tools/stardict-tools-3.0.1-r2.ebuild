# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-dicts/stardict/stardict-3.0.1-r2.ebuild,v 1.4 2009/08/19 14:20:00 betelgeuse Exp $

EAPI="2"

inherit gnome2 eutils autotools

# NOTE: Even though the *.dict.dz are the same as dictd/freedict's files,
#       their indexes seem to be in a different format. So we'll keep them
#       seperate for now.

IUSE="festival espeak gnome gucharmap qqwry pronounce spell"
DESCRIPTION="A GNOME2 international dictionary supporting fuzzy and glob style matching"
HOMEPAGE="http://stardict.sourceforge.net/"
SRC_URI="mirror://sourceforge/stardict/${P}.tar.bz2"

RESTRICT="test"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"

DEP="gnome? ( >=gnome-base/libbonobo-2.2.0
		>=gnome-base/libgnome-2.2.0
		pronounce? ( >=gnome-base/libgnome-2.2.0[esd] )
		>=gnome-base/libgnomeui-2.2.0
		>=gnome-base/gconf-2
		>=gnome-base/orbit-2.6
		app-text/scrollkeeper )
	spell? ( app-text/enchant )
	gucharmap? ( >=gnome-extra/gucharmap-1.4.0 )
	>=sys-libs/zlib-1.1.4
	>=x11-libs/gtk+-2.12"

RDEPEND="${DEP}
	espeak? ( >=app-accessibility/espeak-1.29 )
	festival? ( ~app-accessibility/festival-1.96_beta )"

DEPEND="${DEP}
	>=dev-util/intltool-0.22
	dev-util/pkgconfig"

src_prepare() {
#	epatch "${FILESDIR}"/${P}-configure.in-EST.diff
	epatch "${FILESDIR}"/gconf-m4.diff
	epatch "${FILESDIR}"/gcc_new.patch
#	epatch "${FILESDIR}"/${P}-gcc43.patch
#	epatch "${FILESDIR}"/${P}-transparent_trayicon.patch
#	epatch "${FILESDIR}"/${P}-changelog-minor-typo-fixes.patch
#	epatch "${FILESDIR}"/${P}-gcc44.patch

	# Fix compatibility with gucharmap-2, bug #240728
#	epatch "${FILESDIR}/${P}-gucharmap2.patch"

	AT_M4DIR="m4" eautoreconf
	gnome2_omf_fix
}

src_configure() {
	export PKG_CONFIG=$(type -P pkg-config)
	# Festival plugin crashes, bug 188684. Disable for now.
	G2CONF="$(use_enable gnome gnome-support)
		$(use_enable spell)
		$(use_enable gucharmap)
		$(use_enable espeak)
		$(use_enable qqwry)
		--disable-festival
		--disable-advertisement
		--disable-updateinfo"
	gnome2_src_configure
}

src_install() {
	gnome2_src_install
}

#
#src_unpack() {
#	unpack ${A}
#	cd ${S}
#}
#
#src_compile() {
#	AT_M4DIR="m4" eautoreconf
#	econf --with-posix-regex
#	emake || die "emake failed"
#}
#
#src_install() {
#	emake DESTDIR="${D}" install || die "make install failed"
#}