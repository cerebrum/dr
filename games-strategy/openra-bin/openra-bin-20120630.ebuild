# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils mono gnome2-utils games

MY_PN=${PN%-bin}

VERSION="release-${PV}"
#VERSION="playtest-${PV}"
LVERSION="release.${PV}"
#LVERSION="playtest.${PV}"

DESCRIPTION="A free RTS engine supporting games like Command & Conquer and Red Alert"
HOMEPAGE="http://open-ra.org/"
SRC_URI="http://openra.res0l.net/assets/downloads/linux/arch/${MY_PN}-${LVERSION}-1-any.pkg.tar.xz
			 -> ${P}.tar.xz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cg"

RDEPEND="dev-lang/mono[-minimal]
	media-libs/freetype:2[X]
	media-libs/libsdl[X,video]
	media-libs/openal
	virtual/jpeg
	virtual/opengl
	cg? ( >=media-gfx/nvidia-cg-toolkit-2.1.0017 )"

ICON_DIR="usr/share/icons"
DESK_APPS="${GAMES_DATADIR_BASE}/applications"

src_prepare() {
	# remove old and unnecessary desktop file
	rm -v ${WORKDIR}/${GAMES_DATADIR_BASE}/applications/${MY_PN}.desktop || die
	# move program files to correct binary location
	mkdir -v ${WORKDIR}/${GAMES_PREFIX_OPT} || die
	mv -v ${WORKDIR}/${GAMES_DATADIR_BASE}/${MY_PN} \
		${WORKDIR}/${GAMES_PREFIX_OPT}/${PN} || die
	for size in {16x16,32x32,48x48,64x64,128x128}; do mv -v \
		${ICON_DIR}/hicolor/${size}/apps/${MY_PN}.png \
		${ICON_DIR}/hicolor/${size}/apps/${PN}.png || die; done
}

src_install() {
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
	insinto /${ICON_DIR}
	doins -r ${ICON_DIR}/hicolor || die

	# desktop directory
	insinto ${GAMES_DATADIR_BASE}/desktop-directories
	doins ${FILESDIR}/${PN}.directory || die

	# desktop menu
	insinto "${XDG_CONFIG_DIRS}/menus/applications-merged"
	doins ${FILESDIR}/games-${PN}.menu || die

	dodir ${GAMES_PREFIX_OPT}/${PN} || die
	cp -R "${WORKDIR}/${GAMES_PREFIX_OPT}/${PN}" "${D}/${GAMES_PREFIX_OPT}/" \
		|| die "Install failed!"

	dodoc ${FILESDIR}/README.gentoo \
		${WORKDIR}/${GAMES_PREFIX_OPT}/${PN}/{CHANGELOG,COPYING,HACKING} || die
	rm -v ${D}/${GAMES_PREFIX_OPT}/${PN}/{CHANGELOG,COPYING,HACKING,INSTALL} || die

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

