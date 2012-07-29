# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils mono gnome2-utils vcs-snapshot games

VERSION="release-${PV}"
#VERSION="playtest-${PV}"

DESCRIPTION="A free RTS engine supporting games like Command & Conquer and Red Alert"
HOMEPAGE="http://open-ra.org/"
SRC_URI="http://www.github.com/OpenRA/OpenRA/tarball/${VERSION} -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cg"

DEPEND="dev-lang/mono[-minimal]
	media-libs/freetype:2[X]
	media-libs/libsdl[X,video]
	media-libs/openal
	virtual/jpeg
	virtual/opengl
	cg? ( >=media-gfx/nvidia-cg-toolkit-2.1.0017 )"
RDEPEND="${DEPEND}"

DESK_APPS="/usr/share/applications"

src_unpack() {
	vcs-snapshot_src_unpack
}

src_prepare() {
	# register game-version
	sed \
		-e "/Version/s/{DEV_VERSION}/${VERSION}/" \
		-i mods/{ra,cnc}/mod.yaml || die
}

src_install() 
{
	emake \
		datadir="${GAMES_DATADIR}" \
		bindir="${GAMES_BINDIR}" \
		libdir="$(games_get_libdir)/${PN}" \
		DESTDIR="${D}" \
		install || die "Install failed"

	# desktop entries
	domenu "${FILESDIR}"/${PN}-{cnc,editor,ra}.desktop || die
	# register game-version for desktop entries
	sed \
		-e "/Name/s/{VERSION}/${VERSION}/" \
		-i "${D}/${DESK_APPS}"/${PN}-{cnc,editor,ra}.desktop || die
	if use cg ; then
		# cg desktop entries
		domenu "${FILESDIR}"/${PN}-{cnc,ra}-cg.desktop || die
		# register game-version for cg desktop entries
		sed \
			-e "/Name/s/{VERSION}/${VERSION}/" \
			-i "${D}/${DESK_APPS}"/${PN}-{cnc,ra}-cg.desktop || die
	fi

	# icons
	insinto /usr/share/icons/
	doins -r packaging/linux/hicolor || die

	# desktop directory
	insinto /usr/share/desktop-directories
	doins ${FILESDIR}/${PN}.directory || die

	# desktop menu
	insinto "${XDG_CONFIG_DIRS}/menus/applications-merged"
	doins ${FILESDIR}/games-${PN}.menu || die

	dodoc ${FILESDIR}/README.gentoo AUTHORS CHANGELOG COPYING HACKING || die
	rm AUTHORS CHANGELOG COPYING HACKING INSTALL README || die

	# file permissions
	prepgamesdirs
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	games_pkg_postinst
	gnome2_icon_cache_update

	elog
	elog "If you have problems starting the game or want to know more"
	elog "about it read README.gentoo file in your doc folder."
	elog
}

pkg_postrm() {
	gnome2_icon_cache_update
}

