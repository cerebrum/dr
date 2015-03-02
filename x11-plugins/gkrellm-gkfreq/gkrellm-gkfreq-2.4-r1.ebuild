# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit toolchain-funcs gkrellm-plugin

DESCRIPTION="Displays CPU's current frequencies in gkrellm2"
HOMEPAGE="http://sourceforge.net/projects/gkrellm-gkfreq/"
SRC_URI="http://downloads.sourceforge.net/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	export CMD_CC=$(tc-getCC)
}
