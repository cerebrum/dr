# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/eclipse-cdt-bin/eclipse-cdt-bin-3.0.2.ebuild,v 1.1 2006/06/26 19:04:09 ribosome Exp $

inherit eclipse-ext

DESCRIPTION="C/C++ Development Tools for Eclipse"
LICENSE="CPL-1.0"
HOMEPAGE="http://www.eclipse.org/cdt"
#SRC_URI="amd64? ( http://download.eclipse.org/tools/cdt/releases/eclipse3.1/dist/${PV}/org.eclipse.cdt-${PV}-linux.x86_64.tar.gz )
#x86? ( http://download.eclipse.org/tools/cdt/releases/eclipse3.1/dist/${PV}/org.eclipse.cdt-${PV}-linux.x86.tar.gz )"
SRC_URI="x86? ( http://download.eclipse.org/tools/cdt/releases/eclipse3.1/dist/${PV}/org.eclipse.cdt-${PV}-linux.x86.tar.gz )"

SLOT="0"
IUSE=""
KEYWORDS="-* ~x86 ~amd64"

DEPEND=">=dev-util/eclipse-sdk-3.1"

S="${WORKDIR}/eclipse"

src_compile() {
	einfo "${P} is a binary package"
}

src_install () {
	cd "${S}"
	eclipse-ext_require-slot 3.1 || die \
			"Failed to find suitable Eclipse installation"

	eclipse-ext_create-ext-layout binary || die "Failed to create layout"

	eclipse-ext_install-features features/* || die "Failed to install features"
	eclipse-ext_install-plugins plugins/* || die "Failed to install plugins"
}
