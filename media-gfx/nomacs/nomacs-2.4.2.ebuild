# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils

DESCRIPTION="Qt4-based image viewer"
HOMEPAGE="http://www.nomacs.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}-source.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="raw tiff webp"

#PATCHES=( "${FILESDIR}/${PN}-1.6.2-use-system-webp.patch" )

RDEPEND="
	>=media-gfx/exiv2-0.20[zlib]
	>=dev-qt/qtcore-4.7.0:4
	>=dev-qt/qtgui-4.7.0:4
	raw? (
		>=media-libs/libraw-0.12.0
		>=media-libs/opencv-2.1.0[qt4]
	)
	tiff? (
		media-libs/tiff:0=
		>=media-libs/opencv-2.1.0[qt4]
	)
	webp? ( >=media-libs/libwebp-0.3.1:= )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_enable raw)
		$(cmake-utils_use_enable tiff)
		$(cmake-utils_use_enable webp)
	)
	cmake-utils_src_configure
}
