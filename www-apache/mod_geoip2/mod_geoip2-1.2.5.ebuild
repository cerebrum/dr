# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit apache-module eutils

DESCRIPTION="Apache2 module for hooking into GeoIP"
HOMEPAGE="http://www.maxmind.com/app/mod_geoip"
LICENSE="MaxMind"

SRC_URI="http://geolite.maxmind.com/download/geoip/api/mod_geoip2/${PN}_${PV}.tar.gz"
KEYWORDS="~amd64"
IUSE=""
SLOT="0"

DEPEND="www-servers/apache dev-libs/geoip"

S="${WORKDIR}/${PN}_${PV}"

# See apache-module.eclass for more information.
APACHE2_MOD_CONF="XX_${PN}"
APACHE2_MOD_DEFINE=""

need_apache2

src_compile() {
	apxs -lGeoIP -c mod_geoip.c

	cat >80_mod_geoip.conf <<CONF_FILE
<IfDefine GEOIP>
	<IfModule !mod_geoip.c>
		LoadModule geoip_module modules/mod_geoip.so
	</IfModule>

	# Use 'GeoIPEnable On' in the vhosts where you need this.
	GeoIPDBFile /var/tmp/GeoIP.dat
</IfDefine>
CONF_FILE
}

src_install() {
	insinto "${APACHE_MODULESDIR}"
	insopts -m755 -oroot -groot
	doins .libs/mod_geoip.so
	
	insinto "${APACHE_MODULES_CONFDIR}"
	insopts -m644 -oroot -groot
	doins 80_mod_geoip.conf

	dodoc Changes INSTALL README README.php
}
