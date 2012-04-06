# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

#VERSION="release-${PV}"
VERSION="playtest-${PV}"

DESCRIPTION="A Libre/Free RTS engine supporting early Westwood games like Command & Conquer and Red Alert"
HOMEPAGE="http://open-ra.org/"
SRC_URI="http://www.github.com/OpenRA/OpenRA/tarball/${VERSION}
			 -> ${PN}-${VERSION}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cg ra cnc"
DEPEND="cg? (
	>=media-gfx/nvidia-cg-toolkit-2
	)
	>=dev-lang/mono-2.6.7
	media-libs/mesa
	media-libs/freetype
	>=media-libs/openal-1.1
	>=media-libs/libsdl-1.2"
RDEPEND="${DEPEND}"

PREFIX="/usr"
DATA_ROOT_DIR="${PREFIX}/share"
INSTALL_DIR="${DATA_ROOT_DIR}/${PN}"
INSTALL_DIR_BIN="${PREFIX}/bin"
ICON_DIR="${DATA_ROOT_DIR}/icons"
DESK_DIR="${DATA_ROOT_DIR}/desktop-directories"


src_unpack() {
	unpack "${A}"
	mv OpenRA-OpenRA-* "${S}"
}

src_compile() {
	#epatch "${FILESDIR}/fix-prefix.patch"
	#epatch "${FILESDIR}/ramusic.patch"
	emake prefix="/usr" || die "emake failed in ${S}"
}

src_install() {
	# Update mod versions
	sed "s/{DEV_VERSION}/$VERSION/" -i mods/ra/mod.yaml
	sed "s/{DEV_VERSION}/$VERSION/" -i mods/cnc/mod.yaml
	emake prefix="/usr" DESTDIR="${D}" install || die "Install failed"
	exeinto "${INSTALL_DIR}"
	# Move Tao libraries to correct place and remove empty dirs
	mv -v ${D}${INSTALL_DIR}/thirdparty/Tao/* ${D}${INSTALL_DIR}/
	rm -rv ${D}${INSTALL_DIR}/thirdparty
	# Remove old and unnecessary wrapper script
	rm -v ${D}${INSTALL_DIR_BIN}/openra
	# Desktop Icons
	sed "s/{VERSION}/${VERSION}/" ${FILESDIR}/openra-ra.desktop > openra-ra.desktop
	sed "s/{VERSION}/${VERSION}/" ${FILESDIR}/openra-cnc.desktop > openra-cnc.desktop
	sed "s/{VERSION}/${VERSION}/" ${FILESDIR}/openra-editor.desktop > openra-editor.desktop
	domenu openra-ra.desktop openra-cnc.desktop openra-editor.desktop
	if use cg ; then
		sed "s/{VERSION}/${VERSION}/" ${FILESDIR}/openra-ra-cg.desktop > openra-ra-cg.desktop
		sed "s/{VERSION}/${VERSION}/" ${FILESDIR}/openra-cnc-cg.desktop > openra-cnc-cg.desktop
		domenu openra-ra-cg.desktop openra-cnc-cg.desktop
	fi
	# Icon images
	insinto ${ICON_DIR}
	doins -r packaging/linux/hicolor
	# Desktop directory
	insinto ${DESK_DIR}
	doins ${FILESDIR}/openra.directory
	# Desktop menu
	insinto "$XDG_CONFIG_DIRS/menus/applications-merged"
	doins ${FILESDIR}/games-openra.menu
	dodoc COPYING HACKING CHANGELOG
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
		elog " The RA packages will need to be extracted to /home/<user>/.openra/Content/ra/"
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
		elog " The C&C packages will need to be extracted to /home/<user>/.openra/Contet/cnc/"
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
