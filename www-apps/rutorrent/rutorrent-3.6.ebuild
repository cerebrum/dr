# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

inherit webapp eutils depend.php

DESCRIPTION="ruTorrent is a front-end for the popular Bittorrent client rTorrent"
HOMEPAGE="http://code.google.com/p/rutorrent/"
SRC_URI="
			http://dl.bintray.com/novik65/generic/${P}.tar.gz
			http://dl.bintray.com/novik65/generic/plugins-${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~ppc ~x86"
IUSE="geoip"

need_httpd_cgi
need_php_httpd

DEPEND="|| ( dev-lang/php[xml,gd] dev-lang/php[xml,gd-external] )
	www-apache/mod_xsendfile
	geoip? ( >=dev-php/pecl-geoip-1.0.8-r1 )"

S="${WORKDIR}"

pkg_setup() {
	webapp_pkg_setup
}

src_install() {
	webapp_src_preinst

	insinto "${MY_HTDOCSDIR}"
	mv plugins rutorrent
	cd rutorrent
	doins -r .

	chmod +x "${ED}${MY_HTDOCSDIR}"/plugins/*/*.sh \
		"$ED${MY_HTDOCSDIR}"/php/test.sh || die "chmod failed"

	webapp_serverowned "${MY_HTDOCSDIR}"/share
	webapp_serverowned "${MY_HTDOCSDIR}"/share/settings
	webapp_serverowned "${MY_HTDOCSDIR}"/share/torrents
	webapp_serverowned "${MY_HTDOCSDIR}"/share/users

	webapp_configfile "${MY_HTDOCSDIR}"/conf/.htaccess
	webapp_configfile "${MY_HTDOCSDIR}"/conf/config.php
	webapp_configfile "${MY_HTDOCSDIR}"/conf/access.ini
	webapp_configfile "${MY_HTDOCSDIR}"/conf/plugins.ini
	webapp_configfile "${MY_HTDOCSDIR}"/share/.htaccess

	webapp_src_install
}

pkg_postinst() {
	elog
	elog "Add \"-D XSENDFILE\" to APACHE2_OPTS in /etc/conf.d/apache2"
	elog "and restart apache2 daemon."
	elog
}
