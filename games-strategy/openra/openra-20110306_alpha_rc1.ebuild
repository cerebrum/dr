# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit versionator eutils #flag-o-matic

MY_PV=$(get_major_version)
#VERSION="release-${MY_PV}"
VERSION="playtest-${MY_PV}"

DESCRIPTION="A Libre/Free RTS engine supporting early Westwood games like Command & Conquer and Red Alert"
#HOMEPAGE="http://openra.res0l.net/"
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
	epatch "${FILESDIR}/ramusic.patch"
	emake PREFIX="${PREFIX}" || die "emake failed in ${S}"
}

src_install() {
	# Update mod versions
	sed "s/{DEV_VERSION}/$VERSION/" -i mods/ra/mod.yaml
	sed "s/{DEV_VERSION}/$VERSION/" -i mods/cnc/mod.yaml
	#filter-ldflags -s
	#emake DESTDIR="${D}" LDFLAGS="${LDFLAGS}" install || die "Install failed"
	emake PREFIX="${PREFIX}" DESTDIR="${D}" install || die "Install failed"
	#exeinto "${INSTALL_DIR_BIN}"
	#doexe packaging/linux/openra-bin || die "Install of openra-bin failed"
	exeinto "${INSTALL_DIR}"
	doexe packaging/linux/OpenRA.Utility.sh || die "Install of OpenRA.Utility.sh failed"
	# Move Tao libraries to correct place and remove empty dirs
	mv -v ${D}${INSTALL_DIR}/thirdparty/Tao/* ${D}${INSTALL_DIR}/
	rm -rv ${D}${INSTALL_DIR}/thirdparty
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
		elog " The RA packages will need to be manually extracted to mods/ra/packages/"
		elog " before the RA mod will work. You may try to download pack from our site"
		elog " http://open-ra.org/get-dependency.php?file=ra-packages"
		elog " But the better choise is to download full pack from original game iso."
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
		elog " The C&C packages will need to be manually extracted to mods/cnc/packages/"
		elog " before the C&C mod will work. You may try to download pack from our site"
		elog " http://open-ra.org/get-dependency.php?file=cnc-packages"
		elog " But the better choise is to download full pack from original game iso."
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
	elog " Red Alert and C&C have been released by EA Games as freeware. They can be"
	elog " downloaded from http://www.commandandconquer.com/classic"
	elog " Unfortunately the installer is 16-bit and so won’t run on 64-bit operating"
	elog " systems. This can be worked around by using the Red Alert Setup Manager "
	elog "	(http://ra.afraid.org/html/downloads/utilities-3.html). "
	elog " Make sure you apply the no-CD protection fix so all the files needed "
	elog " are installed to the hard drive."
	elog
	elog " If you have a case-sensitive filesystem you must change the filenames to"
	elog " lower case."
	elog
	elog " OpenRA is incompatible with Compiz, please disable desktop effects"
	elog " when trying to run OpenRA or the game will crash."
	elog
	elog " Please note: OpenRA is currently at an alpha release stage. Releases may"
	elog " be buggy or unstable. If you have any problems, please report them to the"
	elog " IRC channel (#openra on irc.freenode.net) or the bug-tracker"
	elog " (http://bugs.open-ra.org)."
	elog
	elog " You may also see servers list with"
	elog " http://master.open-ra.org/list.php"
	elog
	update-desktop-database
}
