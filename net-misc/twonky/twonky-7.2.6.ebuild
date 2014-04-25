# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v3
# $Header: $
EAPI="3"
INSTALL_DIR="/opt/${PN}"
DATA_DIR="/var/lib/${PN}"

inherit eutils savedconfig user
DESCRIPTION="DLNA/UPnP-AV compliant media server"
HOMEPAGE="http://www.twonky.com/"
SRC_URI="http://d1ctzy5vhd42ul.cloudfront.net/${PN}-i386-glibc-2.2.5-${PV}.zip"
LICENSE="GPL-3"
KEYWORDS="~x86 ~amd64"
SLOT="0"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"
RESTRICT="compile build"
QA_PREBUILT="opt/${PN}/cgi-bin/cgi-jpegscale
  opt/${PN}/cgi-bin/convert
  opt/${PN}/cgi-bin/ttu
  opt/${PN}/plugins/itunes-import
  opt/${PN}/twonkystarter
  opt/${PN}/twonkyproxy
  opt/${PN}/twonkyserver"

pkg_setup() {
enewgroup twonkymedia
enewuser twonkymedia -1 -1 "${DATA_DIR}" twonkymedia
}

src_unpack() {
mkdir "${WORKDIR}/${P}"
cd "${WORKDIR}/${P}"
unpack "${A}"
}

src_prepare() {
cp twonkyserver-default.ini twonkyserver.ini
sed -i `grep --line-number ^ignoredir twonkyserver.ini | sed s/:.*//`s/$/,\$RECYCLE.BIN/ twonkyserver.ini
touch twonkymedia-config.html
echo "#Enter your IP address here" > "${T}/${PN}"
echo "#TVMSIP=192.168.2.40" >> "${T}/${PN}"
use savedconfig && restore_config "${DATA_DIR}"/twonkyserver.ini "${DATA_DIR}"/twonkymedia-config.html
}

src_install() {
dodir "${INSTALL_DIR}"
dodir "${DATA_DIR}"
dodoc Linux-HowTo.txt *.pdf
rm -f Linux-HowTo.txt *.pdf

newinitd "${FILESDIR}"/${PN}.initd ${PN}

newconfd "${FILESDIR}"/${PN}.confd ${PN}
#cp ${FILESDIR}/${PN}.confd ${T}/${PN}
#doconfd ${T}/${PN}

fowners twonkymedia:twonkymedia ${DATA_DIR}
insinto ${DATA_DIR}
! use savedconfig && 
  {
  doins twonkymedia-config.html twonkyserver.ini
  fowners twonkymedia:twonkymedia ${DATA_DIR}/twonkymedia-config.html ${DATA_DIR}/twonkyserver.ini
  }
rm twonkymedia-config.html twonkyserver-default.ini

dodir /var/log/${PN}
fowners twonkymedia:twonkymedia /var/log/${PN}

insinto /opt/${PN}
doins -r *
dosym ${DATA_DIR}/twonkymedia-config.html /opt/${PN}/twonkymedia-config.html 
fperms 755 /opt/${PN}/{twonkystarter,twonkyserver,twonkyserver}
fperms 755 /opt/${PN}/cgi-bin/{cgi-jpegscale,convert,ttu}
fperms 755 /opt/${PN}/plugins/itunes-import
use savedconfig || save_config ${DATA_DIR}/twonkyserver.ini ${DATA_DIR}/twonkymedia-config.html
}
