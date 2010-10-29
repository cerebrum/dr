# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit versionator

MY_PV=$(get_major_version)

DESCRIPTION="A Libre/Free RTS engine supporting early Westwood games like Command & Conquer and Red Alert"
HOMEPAGE="http://openra.res0l.net/"
SRC_URI="http://github.com/OpenRA/OpenRA/tarball/release-${MY_PV}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="video_cards_nvidia"
DEPEND="video_cards_nvidia? ( >=media-gfx/nvidia-cg-toolkit-2 )
	dev-lang/mono
	media-libs/freetype
	>=media-libs/openal-1.1
	>=media-libs/libsdl-1.2"
RDEPEND="${DEPEND}"

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
	dodoc HACKING || die
}

pkg_postinst() {
	elog
	elog " You will need to copy the Tao dependencies (.dll and .config) from the"
	elog " thirdparty/Tao directory into the game root, or install them permanently into"
	elog " your GAC with the following script"
	elog
	elog "	#!/bin/sh"
	elog
	elog "	gacutil -i thirdparty/Tao/Tao.Cg.dll"
	elog "	gacutil -i thirdparty/Tao/Tao.OpenGl.dll"
	elog "	gacutil -i thirdparty/Tao/Tao.OpenAl.dll"
	elog "	gacutil -i thirdparty/Tao/Tao.Sdl.dll"
	elog "	gacutil -i thirdparty/Tao/Tao.FreeType.dll"
	elog
	elog " To run OpenRA, several files are needed from the original game disks."
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
	elog " These need to be copied into the mods/ra/packages/ directory."
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
	elog " These need to be copied into the mods/cnc/packages/ directory."
	elog " If you have a case-sensitive filesystem you must change the filenames to"
	elog " lower case."
	elog
	elog " Red Alert and C&C have been released by EA Games as freeware. They can be"
	elog " downloaded from http://www.commandandconquer.com/classic"
	elog " Unfortunately the installer is 16-bit and so won’t run on 64-bit operating"
	elog " systems. This can be worked around by using the Red Alert Setup Manager "
	elog "	(http://ra.afraid.org/html/downloads/utilities-3.html). "
	elog " Make sure you apply the no-CD protection fix so all the files needed "
	elog " are installed to the hard drive."
	elog
	elog " OpenRA is incompatible with Compiz, please disable desktop effects"
	elog " when trying to run OpenRA or the game will crash."
	elog
	elog " Run the game with \`mono OpenRA.Game.exe Game.Mods=ra\` for Red Alert"
	elog " or \`mono OpenRA.Game.exe Game.Mods=cnc\` for Command & Conquer."
	elog
}