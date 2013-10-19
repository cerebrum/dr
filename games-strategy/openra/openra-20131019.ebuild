# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils mono-env gnome2-utils vcs-snapshot games

#MY_PV=release-${PV}
MY_PV=playtest-${PV}-2
DESCRIPTION="A free RTS engine supporting games like Command & Conquer, Red Alert and Dune2k"
HOMEPAGE="http://open-ra.org/"
SRC_URI="https://github.com/OpenRA/OpenRA/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
#KEYWORDS="amd64 x86"
KEYWORDS="~amd64 ~x86"
IUSE="cg doc tools"

RDEPEND="dev-dotnet/libgdiplus
	dev-lang/mono
	media-libs/freetype:2[X]
	media-libs/libsdl[X,opengl,video]
	media-libs/openal
	virtual/jpeg
	virtual/opengl
	cg? ( >=media-gfx/nvidia-cg-toolkit-2.1.0017 )"
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
	# register game-version
	sed \
		-e "/Version/s/{DEV_VERSION}/${MY_PV}/" \
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

	# icons
	insinto /usr/share/icons/
	doins -r packaging/linux/hicolor

	# desktop entries
	local myrenderer
	for myrenderer in $(usex cg "Cg Gl" "Gl") ; do
		make_desktop_entry "${PN} Game.Mods=cnc Graphics.Renderer=${myrenderer}" \
			"OpenRA ver. ${MY_PV} (${myrenderer} renderer)" ${PN} "StrategyGame" \
			"GenericName=OpenRA - Command & Conquer (${myrenderer})"
		make_desktop_entry "${PN} Game.Mods=ra Graphics.Renderer=${myrenderer}" \
			"OpenRA ver. ${MY_PV} (${myrenderer} renderer)" ${PN} "StrategyGame" \
			"GenericName=OpenRA - Red Alert (${myrenderer})"
		make_desktop_entry "${PN} Game.Mods=d2k Graphics.Renderer=${myrenderer}" \
			"OpenRA ver. ${MY_PV} (${myrenderer} renderer)" ${PN} "StrategyGame" \
			"GenericName=OpenRA - Dune 2000 (${myrenderer})"
	done
	make_desktop_entry "${PN}-editor" "OpenRA ver. ${MY_PV} Map Editor" ${PN}-editor \
		"StrategyGame" "GenericName=OpenRA - Editor"

	# desktop directory
	insinto /usr/share/desktop-directories
	doins "${FILESDIR}"/${PN}.directory

	# desktop menu
	insinto /etc/xdg/menus/applications-merged
	doins "${FILESDIR}"/games-${PN}.menu

	# docs
	dodoc "${FILESDIR}"/README.gentoo HACKING CHANGELOG AUTHORS
	#DOCUMENTATION was removed due to bug with make docs
	if [[ -n "$(type -P markdown)" ]] ; then
		local file; for file in {README,CONTRIBUTING}; do \
		markdown ${file}.md > ${file}.html && dohtml ${file}.html || die; done
	elif [[ -n "$(type -P markdown_py)" ]] ; then
		local file; for file in {README,CONTRIBUTING}; do \
		markdown_py ${file}.md > ${file}.html && dohtml ${file}.html || die; done
	elif [[ -n "$(type -P Markdown.pl)" ]] ; then
		local file; for file in {README,CONTRIBUTING}; do \
		Markdown.pl ${file}.md > ${file}.html && dohtml ${file}.html || die; done
	else
		dodoc {README,CONTRIBUTING}.md
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

	elog
	elog "If you have problems starting the game or want to know more"
	elog "about it read README.gentoo file in your doc folder."
	elog
}

pkg_postrm() {
	gnome2_icon_cache_update
}

