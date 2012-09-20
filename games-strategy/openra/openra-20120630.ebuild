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
	epatch "${FILESDIR}/capFramerate20120630.patch"
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
	make_desktop_entry "${PN} Game.Mods=cnc Graphics.Renderer=Gl" \
		"OpenRA ver. ${VERSION} (Gl Renderer)" ${PN} "StrategyGame" \
		"GenericName=OpenRA - Command & Conquer (Gl)" || die
	make_desktop_entry "${PN} Game.Mods=ra Graphics.Renderer=Gl" \
		"OpenRA ver. ${VERSION} (Gl Renderer)" ${PN} "StrategyGame" \
		"GenericName=OpenRA - Red Alert (Gl)" || die
	make_desktop_entry "${PN}-editor" "OpenRA ver. ${VERSION} Map Editor" ${PN} \
		"StrategyGame" "GenericName=OpenRA - Editor" || die

	if use cg ; then
		# cg desktop entries
		make_desktop_entry "${PN} Game.Mods=cnc Graphics.Renderer=Cg" \
			"OpenRA ver. ${VERSION} (Cg Renderer)" ${PN} "StrategyGame" \
			"GenericName=OpenRA - Command & Conquer (Cg)" || die
		make_desktop_entry "${PN} Game.Mods=ra Graphics.Renderer=Cg" \
			"OpenRA ver. ${VERSION} (Cg Renderer)" ${PN} "StrategyGame" \
			"GenericName=OpenRA - Red Alert (Cg)" || die
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

