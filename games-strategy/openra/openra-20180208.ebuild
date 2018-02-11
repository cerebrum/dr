# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils mono-env gnome2-utils vcs-snapshot xdg-utils

#MY_PV=release-${PV}
MY_PV=playtest-${PV}
DESCRIPTION="A free RTS engine supporting games like Command & Conquer, Red Alert and Dune2k"
HOMEPAGE="http://www.openra.net/"
SRC_URI="https://github.com/OpenRA/OpenRA/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+debug doc -nuget +xdg +zenity"
RESTRICT="mirror"

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
	nuget? ( dev-dotnet/nuget )
	doc? ( || ( app-text/discount
		app-text/peg-markdown
		dev-python/markdown
		dev-perl/Text-Markdown ) )"
DOCS="${FILESDIR}/README.gentoo"
HTML_DOCS=""

pkg_setup() {
	has network-sandbox $FEATURES && \
		die "games-strategy/openra requires 'network-sandbox' to be disabled in FEATURES"
	mono-env_pkg_setup
}

src_unpack() {
	vcs-snapshot_src_unpack
}

src_prepare() {
	local NUGET=$(usex nuget "true" "false");
	sed "s/if \[ ! \$TRAVIS \]/if ${NUGET} \&\& \[ ! \$TRAVIS \]/" \
		-i thirdparty/fetch-thirdparty-deps.sh || die
	emake cli-dependencies
	eapply_user
}

src_compile() {
	emake $(usex debug "" "DEBUG=false")
	emake VERSION=${MY_PV} version man-page
}

src_install()
{
	emake $(usex debug "" "DEBUG=false") \
		datadir="/usr/share/games" \
		bindir="/usr/games/bin" \
		libdir="/usr/games/$(get_libdir)/${PN}" \
		gameinstalldir="/usr/share/games/${PN}" \
		DESTDIR="${D}" \
		install install-linux-scripts install-man-page
	emake VERSION=${MY_PV} \
		datadir="/usr/share" \
		DESTDIR="${D}" install-linux-mime install-linux-icons

	# desktop entries
	make_desktop_entry "${PN}-cnc" "OpenRA ver. ${MY_PV}" "${PN}-cnc" \
		"StrategyGame" "GenericName=OpenRA - Command & Conquer"
	make_desktop_entry "${PN}-ra" "OpenRA ver. ${MY_PV}" "${PN}-ra" \
		"StrategyGame" "GenericName=OpenRA - Red Alert"
	make_desktop_entry "${PN}-d2k" "OpenRA ver. ${MY_PV}" "${PN}-d2k" \
		"StrategyGame" "GenericName=OpenRA - Dune 2000"

	# desktop directory
	insinto /usr/share/desktop-directories
	doins "${FILESDIR}"/${PN}.directory

	# desktop menu
	insinto /etc/xdg/menus/applications-merged
	doins "${FILESDIR}"/games-${PN}.menu

	# docs
	if [[ -n "$(type -P markdown)" ]] ; then
		local file; for file in {README,CONTRIBUTING}; do \
		markdown ${file}.md > ${file}.html && HTML_DOCS="${HTML_DOCS} ${file}.html" || die; done
	elif [[ -n "$(type -P markdown_py)" ]] ; then
		local file; for file in {README,CONTRIBUTING}; do \
		markdown_py ${file}.md > ${file}.html && HTML_DOCS="${HTML_DOCS} ${file}.html" || die; done
	elif [[ -n "$(type -P Markdown.pl)" ]] ; then
		local file; for file in {README,CONTRIBUTING}; do \
		Markdown.pl ${file}.md > ${file}.html && HTML_DOCS="${HTML_DOCS} ${file}.html" || die; done
	else
		DOCS="${DOCS} README.md CONTRIBUTING.md"
	fi
	einstalldocs
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
