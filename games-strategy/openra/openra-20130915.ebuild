# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils mono-env gnome2-utils vcs-snapshot games

VERSION="release-${PV}"
#VERSION="playtest-${PV}"

DESCRIPTION="A free RTS engine supporting games like Command & Conquer, Red Alert and Dune2k"
HOMEPAGE="http://open-ra.org/"
SRC_URI="https://github.com/OpenRA/OpenRA/archive/${VERSION}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
#KEYWORDS="~amd64 ~x86"
IUSE="cg tools"

RDEPEND="dev-lang/mono[-minimal]
	media-libs/freetype:2[X]
	media-libs/libsdl[X,opengl,video]
	media-libs/openal
	virtual/jpeg
	virtual/opengl
	cg? ( >=media-gfx/nvidia-cg-toolkit-2.1.0017 )"
DEPEND="${RDEPEND}
	app-text/discount[minimal]"

pkg_setup() {
	mono-env_pkg_setup
	games_pkg_setup
}

src_unpack() {
	vcs-snapshot_src_unpack
}

src_prepare() {
	epatch "${FILESDIR}/make.patch"
	# register game-version
	sed \
		-e "/Version/s/{DEV_VERSION}/${VERSION}/" \
		-i mods/{ra,cnc,d2k}/mod.yaml || die
}

src_compile() {
	emake $(usex tools "all" "")
}

src_install() 
{
	emake \
		datadir="${GAMES_DATADIR}" \
		bindir="${GAMES_BINDIR}" \
		libdir="$(games_get_libdir)/${PN}" \
		DESTDIR="${D}" \
		$(usex tools "install-all" "install") #docs

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
	make_desktop_entry "${PN}-editor" "OpenRA ver. ${VERSION} Map Editor" ${PN}-editor \
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
	insinto /usr/share/icons/
	doins -r packaging/linux/hicolor

	# desktop directory
	insinto ${GAMES_DATADIR_BASE}/desktop-directories
	doins "${FILESDIR}"/${PN}.directory

	# desktop menu
	insinto "${XDG_CONFIG_DIRS}/menus/applications-merged"
	doins "${FILESDIR}"/games-${PN}.menu

	# generate documentation
	dodoc "${FILESDIR}"/README.gentoo HACKING CHANGELOG AUTHORS
	rm -v "${D}"/${GAMES_DATADIR}/${PN}/AUTHORS || die
	#DOCUMENTATION was removed due to bug with make docs
	local file; for file in {README,CONTRIBUTING}; do \
		markdown ${file}.md > ${file}.html || die; dohtml ${file}.html; done
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

