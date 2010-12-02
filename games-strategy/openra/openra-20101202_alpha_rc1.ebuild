# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit versionator eutils

MY_PV=$(get_major_version)
VERSION=${MY_PV}

DESCRIPTION="A Libre/Free RTS engine supporting early Westwood games like Command & Conquer and Red Alert"
HOMEPAGE="http://openra.res0l.net/"
SRC_URI="http://www.github.com/OpenRA/OpenRA/tarball/release-${VERSION}"
#SRC_URI="https://www.github.com/OpenRA/OpenRA/zipball/playtest-${VERSION}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cg ra cnc video_cards_nvidia"
DEPEND="video_cards_nvidia? (
	cg? (
	>=media-gfx/nvidia-cg-toolkit-2
	)
	)
	dev-lang/mono
	media-libs/mesa
	media-libs/freetype
	>=media-libs/openal-1.1
	>=media-libs/libsdl-1.2"
RDEPEND="${DEPEND}"
INSTALL_PREFIX="/usr/local/share"
INSTALL_DIR=${INSTALL_PREFIX}/${PN}
ICON_DIR="/usr/share/icons"

src_unpack() {
	cp "${DISTDIR}/${A}" "${T}/${A}.tar.gz"
	cd "${T}"
	unpack "./${A}.tar.gz"
	OPENRADIR="`ls -d OpenRA-OpenRA-*`"
	mv ${OPENRADIR} "${WORKDIR}/"
}

src_compile() {
	cd ${OPENRADIR}
	emake || die "emake failed in ${S}"
}

src_install() {
	cd ${OPENRADIR}
	emake DESTDIR="${D}" install || die "Install failed"
	exeinto "${INSTALL_DIR}"
	doexe ${FILESDIR}/inst_tao_deps.sh || die "inst_tao_deps.sh"
	# Remove unneeded files
	rm OpenRA.Launcher.exe
	# Desktop Icons
	dodir ${DESK_DIR}/
	sed "s/{VERSION}/${VERSION}/" ${FILESDIR}/openra-ra.desktop > openra-ra.desktop
	sed "s/{VERSION}/${VERSION}/" ${FILESDIR}/openra-cnc.desktop > openra-cnc.desktop
	domenu openra-ra.desktop openra-cnc.desktop
	if use cg ; then
		sed "s/{VERSION}/${VERSION}/" ${FILESDIR}/openra-ra-cg.desktop > openra-ra-cg.desktop
		sed "s/{VERSION}/${VERSION}/" ${FILESDIR}/openra-cnc-cg.desktop > openra-cnc-cg.desktop
		domenu openra-ra-cg.desktop openra-cnc-cg.desktop
	fi
	# Icon images
	dodir ${PIXM_DIR}/
	doicon ${FILESDIR}/openra.32.xpm
	dodir ${ICON_DIR}/
	insinto ${ICON_DIR}
	doins -r ${FILESDIR}/hicolor
}

pkg_postinst() {
	elog
	elog " You will need to install the Tao deps (.dll and .config) from the"
	elog " thirdparty/Tao dir permanently into your GAC with the following script:"
	elog " inst_tao_deps.sh (run in OpenRA dir)"
	elog
	elog " You may run the game from desktop games menu or just manually"
	elog " run the game with \`mono OpenRA.Game.exe Game.Mods=ra\` for Red Alert"
	elog " or \`mono OpenRA.Game.exe Game.Mods=cnc\` for Command & Conquer."
	if use cg ; then
		elog
		elog " You may also run the game with alternative Cg Graphics Renderer"
		elog " by adding \`Graphics.Renderer=Cg\` parameter to above commands."
	fi
	cd "${INSTALL_DIR}"
	# Download and install RA packages
	if use ra ; then
			mono OpenRA.Utility.exe --download-url=http://open-ra.org/get-dependency.php?file=ra-packages,/tmp/ra-packages.zip
			mono OpenRA.Utility.exe --extract-zip=/tmp/ra-packages.zip,ra/packages/
	else
		elog
		elog " The RA packages will need to be manually extracted from"
		elog " http://open-ra.org/get-dependency.php?file=ra-packages to mods/ra/packages/"
		elog " before the RA mod will work."
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
		elog " The C&C packages will need to be manually extracted from"
		elog " http://open-ra.org/get-dependency.php?file=cnc-packages to mods/cnc/packages/"
		elog " before the C&C mod will work."
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
#	elog " If you have a case-sensitive filesystem you must change the filenames to"
#	elog " lower case."
#	elog
#	elog " Red Alert and C&C have been released by EA Games as freeware. They can be"
#	elog " downloaded from http://www.commandandconquer.com/classic"
#	elog " Unfortunately the installer is 16-bit and so won’t run on 64-bit operating"
#	elog " systems. This can be worked around by using the Red Alert Setup Manager "
#	elog "	(http://ra.afraid.org/html/downloads/utilities-3.html). "
#	elog " Make sure you apply the no-CD protection fix so all the files needed "
#	elog " are installed to the hard drive."
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