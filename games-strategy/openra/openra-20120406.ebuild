# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils mono git-2

#VERSION="release-${PV}"
VERSION="playtest-${PV}"

DESCRIPTION="A Libre/Free RTS engine supporting early Westwood games like Command & Conquer and Red Alert"
HOMEPAGE="http://open-ra.org/"

EGIT_REPO_URI="git://github.com/OpenRA/OpenRA.git"
#EGIT_BRANCH="master"
EGIT_BRANCH="next"
EGIT_COMMIT="${VERSION}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cg"

DEPEND="dev-lang/mono[-minimal]
	!games-strategy/openra-bin
	media-libs/freetype:2[X]
	media-libs/libsdl[X,video]
	media-libs/openal
	virtual/jpeg
	virtual/opengl
	cg? ( >=media-gfx/nvidia-cg-toolkit-2.1.0017 )"
RDEPEND="${DEPEND}"

PREFIX="/usr"
DATA_ROOT_DIR="${PREFIX}/share"
INSTALL_DIR="${DATA_ROOT_DIR}/${PN}"
INSTALL_DIR_BIN="${PREFIX}/bin"
ICON_DIR="${DATA_ROOT_DIR}/icons"
DESK_DIR="${DATA_ROOT_DIR}/desktop-directories"
DESK_APPS="${DATA_ROOT_DIR}/applications"

src_install() {
	# Register game-version
	sed \
		-e "/Version/s/{DEV_VERSION}/${VERSION}/" \
		-i mods/{ra,cnc}/mod.yaml || die
	emake prefix="${PREFIX}" DESTDIR="${D}" install || die "Install failed"
	exeinto "${INSTALL_DIR}"
	# Remove old and unnecessary wrapper scripts
	rm -v ${D}${INSTALL_DIR_BIN}/${PN}{,-editor} || die
	# Install Desktop Icons
	domenu "${FILESDIR}"/${PN}-{cnc,editor,ra}.desktop || die
	# Register game-version for Desktop Icons
	sed \
		-e "/Name/s/{VERSION}/${VERSION}/" \
		-i "${D}/${DESK_APPS}"/${PN}-{cnc,editor,ra}.desktop || die
	if use cg ; then
		# Install Desktop Icons
		domenu "${FILESDIR}"/${PN}-{cnc,ra}-cg.desktop || die
		# Register game-version for Desktop Icons
		sed \
			-e "/Name/s/{VERSION}/${VERSION}/" \
			-i "${D}/${DESK_APPS}"/${PN}-{cnc,ra}-cg.desktop || die
	fi
	# Icon images
	insinto ${ICON_DIR}
	doins -r packaging/linux/hicolor || die
	# Desktop directory
	insinto ${DESK_DIR}
	doins ${FILESDIR}/${PN}.directory || die
	# Desktop menu
	insinto "$XDG_CONFIG_DIRS/menus/applications-merged"
	doins ${FILESDIR}/games-${PN}.menu || die
	dodoc ${FILESDIR}/README.gentoo HACKING CHANGELOG COPYING || die
}

pkg_postinst() {
	elog
	elog "If you have problems starting the game or want to know more"
	elog "about it read README.gentoo file in your doc folder."
	elog
	update-desktop-database
}
