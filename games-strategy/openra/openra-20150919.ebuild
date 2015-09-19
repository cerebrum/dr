# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils mono-env gnome2-utils vcs-snapshot fdo-mime games

MY_PV=release-${PV}
#MY_PV=playtest-${PV}
DESCRIPTION="A free RTS engine supporting games like Command & Conquer, Red Alert and Dune2k"
HOMEPAGE="http://www.openra.net/"
SRC_URI="https://github.com/OpenRA/OpenRA/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
#KEYWORDS="~amd64 ~x86"
IUSE="+debug doc +tools +xdg +zenity"

RDEPEND="dev-dotnet/libgdiplus
	>=dev-lang/mono-3.2
	media-libs/freetype:2[X]
	media-libs/libsdl2[X,opengl,video]
	media-libs/openal
	virtual/jpeg:0
	virtual/opengl
	=dev-lang/lua-5.1*:0
	xdg? ( x11-misc/xdg-utils )
	zenity? ( gnome-extra/zenity )"
DEPEND="${RDEPEND}
	doc? ( || ( app-text/discount
		app-text/peg-markdown
		dev-python/markdown
		dev-perl/Text-Markdown ) )"

pkg_setup() {
	mono-env_pkg_setup
	games_pkg_setup
}

src_unpack() {
	vcs-snapshot_src_unpack
}

src_prepare() {
	emake cli-dependencies
}

src_compile() {
	emake $(usex tools "all" "") $(usex debug "" "DEBUG=false")
	emake VERSION=${MY_PV} docs man-page
}

src_install()
{
	emake $(usex debug "" "DEBUG=false") \
		datadir="${GAMES_DATADIR}" \
		bindir="${GAMES_BINDIR}" \
		libdir="$(games_get_libdir)/${PN}" \
		gameinstalldir="${GAMES_DATADIR}/${PN}" \
		DESTDIR="${D}" \
		$(usex tools "install-all" "install") install-linux-scripts install-man-page
	emake \
		datadir="/usr/share" \
		DESTDIR="${D}" install-linux-mime install-linux-icons

	# desktop entries
	make_desktop_entry "${PN} Game.Mod=cnc" "OpenRA ver. ${MY_PV}" ${PN} \
		"StrategyGame" "GenericName=OpenRA - Command & Conquer"
	make_desktop_entry "${PN} Game.Mod=ra" "OpenRA ver. ${MY_PV}" ${PN} \
		"StrategyGame" "GenericName=OpenRA - Red Alert"
	make_desktop_entry "${PN} Game.Mod=d2k" "OpenRA ver. ${MY_PV}" ${PN} \
		"StrategyGame" "GenericName=OpenRA - Dune 2000"

	# desktop directory
	insinto /usr/share/desktop-directories
	doins "${FILESDIR}"/${PN}.directory

	# desktop menu
	insinto /etc/xdg/menus/applications-merged
	doins "${FILESDIR}"/games-${PN}.menu

	# docs
	dodoc "${FILESDIR}"/README.gentoo
	if [[ -n "$(type -P markdown)" ]] ; then
		local file; for file in {README,CONTRIBUTING,DOCUMENTATION,Lua-API}; do \
		markdown ${file}.md > ${file}.html && dohtml ${file}.html || die; done
	elif [[ -n "$(type -P markdown_py)" ]] ; then
		local file; for file in {README,CONTRIBUTING,DOCUMENTATION,Lua-API}; do \
		markdown_py ${file}.md > ${file}.html && dohtml ${file}.html || die; done
	elif [[ -n "$(type -P Markdown.pl)" ]] ; then
		local file; for file in {README,CONTRIBUTING,DOCUMENTATION,Lua-API}; do \
		Markdown.pl ${file}.md > ${file}.html && dohtml ${file}.html || die; done
	else
		dodoc {README,CONTRIBUTING,DOCUMENTATION,Lua-API}.md
	fi
	# file permissions
	prepgamesdirs
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	games_pkg_postinst
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update

	elog
	elog "If you have problems starting the game or want to know more"
	elog "about it read README.gentoo file in your doc folder."
	elog
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
