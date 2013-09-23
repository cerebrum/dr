# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils mono-env gnome2-utils games

MY_PN=${PN%-bin}

VERSION="release-${PV}"
#VERSION="playtest-${PV}"
LVERSION="release.${PV}"
#LVERSION="playtest.${PV}"

DESCRIPTION="A free RTS engine supporting games like Command & Conquer, Red Alert and Dune2k"
HOMEPAGE="http://open-ra.org/"
SRC_URI="http://openra.res0l.net/assets/downloads/linux/arch/${MY_PN}-${LVERSION}-1-any.pkg.tar.xz
			 -> ${P}.tar.xz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
#KEYWORDS="~amd64 ~x86"
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
	rm -v ${WORKDIR}/${GAMES_DATADIR_BASE}/applications/${MY_PN}.desktop
	# move program files to correct binary location
	mkdir -v ${WORKDIR}/${GAMES_PREFIX_OPT}
	mv -v ${WORKDIR}/${GAMES_DATADIR_BASE}/${MY_PN} \
		${WORKDIR}/${GAMES_PREFIX_OPT}/${PN}
	for size in {16x16,32x32,48x48,64x64,128x128}; do mv -v \
		${ICON_DIR}/hicolor/${size}/apps/${MY_PN}.png \
		${ICON_DIR}/hicolor/${size}/apps/${PN}.png; done
}

src_install() {
	# desktop entries
	make_desktop_entry "${PN} Game.Mods=cnc Graphics.Renderer=Gl" \
		"OpenRA ver. ${VERSION} (Gl Renderer)" ${PN} "StrategyGame" \
		"GenericName=OpenRA - Command & Conquer (Gl)"
	make_desktop_entry "${PN} Game.Mods=ra Graphics.Renderer=Gl" \
		"OpenRA ver. ${VERSION} (Gl Renderer)" ${PN} "StrategyGame" \
		"GenericName=OpenRA - Red Alert (Gl)"
	make_desktop_entry "${PN} Game.Mods=d2k Graphics.Renderer=Gl" \
		"OpenRA ver. ${VERSION} (Gl Renderer)" ${PN} "StrategyGame" \
		"GenericName=OpenRA - Dune 2000 (Gl)"
	make_desktop_entry "${PN}-editor" "OpenRA ver. ${VERSION} Map Editor" ${PN} \
		"StrategyGame" "GenericName=OpenRA - Editor"

	if use cg ; then
		# cg desktop entries
		make_desktop_entry "${PN} Game.Mods=cnc Graphics.Renderer=Cg" \
			"OpenRA ver. ${VERSION} (Cg Renderer)" ${PN} "StrategyGame" \
			"GenericName=OpenRA - Command & Conquer (Cg)"
		make_desktop_entry "${PN} Game.Mods=ra Graphics.Renderer=Cg" \
			"OpenRA ver. ${VERSION} (Cg Renderer)" ${PN} "StrategyGame" \
			"GenericName=OpenRA - Red Alert (Cg)"
		make_desktop_entry "${PN} Game.Mods=d2k Graphics.Renderer=Cg" \
			"OpenRA ver. ${VERSION} (Cg Renderer)" ${PN} "StrategyGame" \
			"GenericName=OpenRA - Dune 2000 (Cg)"
	fi

	# icons
	insinto /${ICON_DIR}
	doins -r ${ICON_DIR}/hicolor

	# desktop directory
	insinto ${GAMES_DATADIR_BASE}/desktop-directories
	doins ${FILESDIR}/${PN}.directory

	# desktop menu
	insinto "${XDG_CONFIG_DIRS}/menus/applications-merged"
	doins ${FILESDIR}/games-${PN}.menu

	# wrapper script
	dogamesbin ${FILESDIR}/${PN}

	dodir ${GAMES_PREFIX_OPT}/${PN}
	cp -R "${WORKDIR}/${GAMES_PREFIX_OPT}/${PN}" "${D}/${GAMES_PREFIX_OPT}/"

	dodoc ${FILESDIR}/README.gentoo \
		${WORKDIR}/${GAMES_PREFIX_OPT}/${PN}/{README.md,HACKING,CHANGELOG,AUTHORS,COPYING}
	rm -v ${D}/${GAMES_PREFIX_OPT}/${PN}/{README.md,HACKING,CHANGELOG,AUTHORS,COPYING,INSTALL}

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

