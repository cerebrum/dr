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
IUSE="cg ra cnc"

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
	# Remove old and unnecessary wrapper script
	rm -v ${D}${INSTALL_DIR_BIN}/${PN} || die
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
	dodoc README HACKING CHANGELOG COPYING || die
}

pkg_postinst() {
	elog
	elog " You may run the game from desktop games menu or just manually"
	elog " run the game with \`mono OpenRA.Game.exe Game.Mods=ra\` for Red Alert"
	elog " or \`mono OpenRA.Game.exe Game.Mods=cnc\` for Command & Conquer."
	if use cg ; then
		elog
		elog " You may also run the game with alternative Cg Graphics Renderer"
		elog " by adding \`Graphics.Renderer=Cg\` parameter to above commands"
		elog " (convenient for some integrated graphics cards) or run explicitly"
		elog " with a default one by adding \`Graphics.Renderer=Gl\` parameter."
	fi
	cd "${INSTALL_DIR}"
	# Download and install RA packages
	if use ra ; then
			mono OpenRA.Utility.exe --download-url=http://open-ra.org/get-dependency.php?file=ra-packages,/tmp/ra-packages.zip
			mono OpenRA.Utility.exe --extract-zip=/tmp/ra-packages.zip,ra/packages/
	else
		elog
		elog " The RA packages will need to be extracted to ~/.openra/Content/ra/"
		elog " before the RA mod will actually work. You may execute OpenRA and it will"
                elog " suggest to download content from CD or from OpenRA site automatically."
		elog " You may also try to download minimal content pack from OpenRA site manually:"
		elog " http://open-ra.org/get-dependency.php?file=ra-packages"
		elog " But the better choice is to download full pack from original game CD or iso."
		elog " However, full CD pack usage result in slower game start from OpenRA Lobby."
		elog
		elog " The required files for the Red Alert mod are:"
		elog " EITHER:"
		elog "	* conquer.mix"
		elog "	* temperat.mix"
		elog "	* interior.mix"
		elog "	* snow.mix"
		elog "	* sounds.mix"
		elog "	* allies.mix"
		elog "	* russian.mix"
		elog " OR:"
		elog "	* main.mix"
		elog " AND:"
		elog "	* redalert.mix"
		elog
	fi

	if use cnc ; then
			mono OpenRA.Utility.exe --download-url=http://open-ra.org/get-dependency.php?file=cnc-packages,/tmp/cnc-packages.zip
			mono OpenRA.Utility.exe --extract-zip=/tmp/cnc-packages.zip,cnc/packages/
	else
		elog
		elog " The C&C packages will need to be extracted to ~/.openra/Contet/cnc/"
		elog " before the C&C mod will actually work. You may execute OpenRA and it will"
		elog " suggest to download content from CD or from OpenRA site automatically."
		elog " You may also try to download minimal content pack from OpenRA site manually:"
		elog " http://open-ra.org/get-dependency.php?file=cnc-packages"
		elog " But the better choice is to download full pack from original game CD or iso."
		elog " However, full CD pack usage result in slower game start from OpenRA Lobby."
		elog
		elog " The required files for the Command and Conquer mod are:"
		elog "	* cclocal.mix"
		elog "	* speech.mix"
		elog "	* conquer.mix"
		elog "	* sounds.mix"
		elog "	* tempicnh.mix"
		elog "	* temperat.mix"
		elog "	* winter.mix"
		elog "	* desert.mix"
		elog
	fi
	elog
	elog " Red Alert and C&C have been released by EA Games as freeware. They could be"
	elog " downloaded from http://www.commandandconquer.com/classic"
	elog " Unfortunately the installer is 16-bit and so won’t run on 64-bit operating"
	elog " systems. This can be worked around by using the Red Alert Setup Manager"
	elog "	(http://ra.afraid.org/html/downloads/utilities-3.html)."
	elog " Make sure you apply the no-CD protection fix so all the files needed"
	elog " are installed to the hard drive."
	elog
	elog " If you have a case-sensitive filesystem you must change the filenames to"
	elog " lower case."
	elog
	elog " Please note: OpenRA is currently at a beta release stage. Releases may"
	elog " be buggy or unstable. If you have any problems, please report them to the"
	elog " IRC channel (#openra on irc.freenode.net) or to the bug-tracker"
	elog " (http://bugs.open-ra.org)."
	elog
	elog " You may also see servers list with"
	elog " http://master.open-ra.org/list.php"
	elog
	update-desktop-database
}
