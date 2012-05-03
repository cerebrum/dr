# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils mono

MY_PN=${PN%-bin}

VERSION="release-${PV}"
#VERSION="playtest-${PV}"
LVERSION="release.${PV}"
#LVERSION="playtest.${PV}"

DESCRIPTION="A Libre/Free RTS engine supporting early Westwood games like Command & Conquer and Red Alert"
HOMEPAGE="http://open-ra.org/"
SRC_URI="http://openra.res0l.net/assets/downloads/linux/arch/${MY_PN}-${LVERSION}-1-any.pkg.tar.xz
			 -> ${PN}-${VERSION}.tar.xz"
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

PREFIX="usr"
DATA_ROOT_DIR="${PREFIX}/share"
INSTALL_DIR="${DATA_ROOT_DIR}/${PN}"
INSTALL_DIR_BIN="${PREFIX}/bin"
ICON_DIR="${DATA_ROOT_DIR}/icons"
DESK_DIR="${DATA_ROOT_DIR}/desktop-directories"
DESK_APPS="${DATA_ROOT_DIR}/applications"

src_prepare() {
	# Remove old and unnecessary desktop file
	rm -v ${DATA_ROOT_DIR}/applications/${MY_PN}.desktop
	# Move program files to correct binary location
	mv -v ${DATA_ROOT_DIR}/${MY_PN} ${INSTALL_DIR}
	for size in {16x16,32x32,48x48,64x64,128x128}; do mv -v \
		${ICON_DIR}/hicolor/${size}/apps/${MY_PN}.png \
		${ICON_DIR}/hicolor/${size}/apps/${PN}.png; done
}

src_install() {
	# Install Desktop Icons
	domenu "${FILESDIR}"/${PN}-{cnc,editor,ra}.desktop || die
	# Register game-version for Desktop Icons
	sed \
		-e "/Name/s/{VERSION}/${VERSION}/" \
		-i "${D}/${DESK_APPS}"/${PN}-{cnc,editor,ra}.desktop || die
	if use cg ; then
		# Install Cg Desktop Icons
		domenu "${FILESDIR}"/${PN}-{cnc,ra}-cg.desktop || die
		# Register game-version for Cg Desktop Icons
		sed \
			-e "/Name/s/{VERSION}/${VERSION}/" \
			-i "${D}/${DESK_APPS}"/${PN}-{cnc,ra}-cg.desktop || die
	fi
	# Icon images
	insinto ${ICON_DIR}
	doins -r ${ICON_DIR}/hicolor || die
	# Desktop directory
	insinto /${DESK_DIR}
	doins ${FILESDIR}/${PN}.directory || die
	# Desktop menu
	insinto "${XDG_CONFIG_DIRS}/menus/applications-merged"
	doins ${FILESDIR}/games-${PN}.menu || die
	dodir /${INSTALL_DIR}
	cp -R "${WORKDIR}/${INSTALL_DIR}/" "${D}/${DATA_ROOT_DIR}/" || die "Install failed!"
	dodoc ${FILESDIR}/README.gentoo \
		${INSTALL_DIR}/{CHANGELOG,COPYING,HACKING} || die
	rm ${INSTALL_DIR}/{CHANGELOG,COPYING,HACKING,INSTALL} || die
}

pkg_postinst() {
	elog
	elog "If you have problems starting the game or want to know more"
	elog "about it read README.gentoo file in your doc folder."
	elog
	update-desktop-database
}
