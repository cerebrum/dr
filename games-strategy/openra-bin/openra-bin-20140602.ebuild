# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils mono-env gnome2-utils games

MY_PN=${PN%-bin}
#MY_PV=release-${PV}
MY_PV=playtest-${PV}
#MY_PVL=release.${PV}
MY_PVL=playtest.${PV}
DESCRIPTION="A free RTS engine supporting games like Command & Conquer, Red Alert and Dune2k"
HOMEPAGE="http://open-ra.org/ http://wiki.openra.net"
SRC_URI="http://openra.res0l.net/assets/downloads/linux/arch/${MY_PN}-${MY_PVL}-1-any.pkg.tar.xz
			 -> ${P}.tar.xz"
LICENSE="GPL-3"
SLOT="0"
#KEYWORDS="amd64 x86"
KEYWORDS="~amd64 ~x86"
IUSE="+xdg +zenity"

RDEPEND="dev-lang/mono[-minimal]
	media-libs/freetype:2[X]
	media-libs/libsdl2[X,opengl,video]
	media-libs/openal
	virtual/jpeg
	virtual/opengl
	=dev-lang/lua-5.1*
	xdg? ( x11-misc/xdg-utils )
	zenity? ( gnome-extra/zenity )"

ICON_DIR="usr/share/icons"
DESK_APPS="${GAMES_DATADIR_BASE}/applications"
MY_LIBDIR="/usr/lib"

src_prepare() {
	# remove old and unnecessary desktop file
	rm -v "${WORKDIR}"/${GAMES_DATADIR_BASE}/applications/${MY_PN}.desktop || die
	# move program files to correct binary location
	mkdir -v "${WORKDIR}"/${GAMES_PREFIX_OPT} || die
	mv -v "${WORKDIR}"/"${MY_LIBDIR}"/${MY_PN} \
		"${WORKDIR}"/${GAMES_PREFIX_OPT}/${PN} || die
	# remove unnecessary thirdparty files
	rm -v "${WORKDIR}"/${GAMES_PREFIX_OPT}/${PN}/{liblua*.*.so,libSDL2*.*.so} || die

	mv -v ${ICON_DIR}/hicolor/scalable/apps/${MY_PN}.svg ${ICON_DIR}/hicolor/scalable/apps/${PN}.svg || die
	local size; for size in {16x16,32x32,48x48,64x64,128x128}; do mv -v \
		${ICON_DIR}/hicolor/${size}/apps/${MY_PN}.png \
		${ICON_DIR}/hicolor/${size}/apps/${PN}.png || die; \
		mv -v ${ICON_DIR}/hicolor/${size}/apps/${MY_PN}-editor.png \
		${ICON_DIR}/hicolor/${size}/apps/${PN}-editor.png; done
}

src_install() {
	# desktop entries
	make_desktop_entry "${PN} Game.Mod=cnc" "OpenRA ver. ${MY_PV}" ${PN} \
		"StrategyGame" "GenericName=OpenRA - Command & Conquer" || die
	make_desktop_entry "${PN} Game.Mod=ra" "OpenRA ver. ${MY_PV}" ${PN} \
		"StrategyGame" "GenericName=OpenRA - Red Alert" || die
	make_desktop_entry "${PN} Game.Mod=d2k" "OpenRA ver. ${MY_PV}" ${PN} \
		"StrategyGame" "GenericName=OpenRA - Dune 2000" || die
	make_desktop_entry "${PN}-editor" "OpenRA ver. ${MY_PV} Map Editor" ${PN}-editor \
		"StrategyGame" "GenericName=OpenRA - Editor" || die

	# icons
	insinto /${ICON_DIR}
	doins -r ${ICON_DIR}/hicolor || die

	# desktop directory
	insinto /usr/share/desktop-directories
	doins "${FILESDIR}"/${PN}.directory || die

	# desktop menu
	insinto /etc/xdg/menus/applications-merged
	doins "${FILESDIR}"/games-${PN}.menu || die

	# wrapper script
	dogamesbin "${FILESDIR}"/${PN} || die

	dodir ${GAMES_PREFIX_OPT}/${PN} || die
	cp -R "${WORKDIR}/${GAMES_PREFIX_OPT}/${PN}" "${D}/${GAMES_PREFIX_OPT}/" \
		|| die "Install failed!"

	dodoc "${FILESDIR}"/README.gentoo \
	"${WORKDIR}"/${GAMES_PREFIX_OPT}/${PN}/{AUTHORS,COPYING} || die
	rm -v ${D}/${GAMES_PREFIX_OPT}/${PN}/COPYING || die
	#dohtml \
	#"${WORKDIR}"/${GAMES_PREFIX_OPT}/${PN}/{README,CONTRIBUTING,DOCUMENTATION}.html \
	#	|| die
	#rm -v "${D}"/${GAMES_PREFIX_OPT}/${PN}/{README,CONTRIBUTING,DOCUMENTATION}.html \
	#	|| die

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

