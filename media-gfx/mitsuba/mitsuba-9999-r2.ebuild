# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python3_5 )
inherit cmake-utils eutils toolchain-funcs multilib python-single-r1 git-2 

EGIT_REPO_URI="https://github.com/fjuhec/mitsuba.git"
EGIT_BRANCH="blender-integration"
DESCRIPTION="Mitsuba is a physically based renderer."
HOMEPAGE="https://www.mitsuba-renderer.org"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="blender"

RDEPEND="${PYTHON_DEPS}
	virtual/jpeg
        media-libs/libpng
	x11-libs/libX11
	media-libs/glew
	dev-qt/qtcore
	dev-qt/qtgui
	dev-qt/qtopengl
	media-libs/openexr
	dev-libs/xerces-c
	dev-libs/boost[${PYTHON_USEDEP}]
	dev-libs/collada-dom"
DEPEND="dev-util/cmake
	${RDEPEND}"
	
PDEPEND="blender? ( =media-plugins/mitsuba-blender-${PV} )"

#S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}"/fix_boost_include.patch
	epatch "${FILESDIR}"/python_bindings.patch
}

src_configure() {
	python-single-r1_pkg_setup
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}
	-DCMAKE_INSTALL_PREFIX="/usr"
	-DBUILD_PYTHON=ON
	-DPYTHON_VERSION="${EPYTHON/python/}"
	-DPYTHON_LIBRARY="$(python_get_library_path)"
	-DPYTHON_INCLUDE_PATH="$(python_get_includedir)"
	-DMTS_USE_PCH=OFF"
	cmake-utils_src_configure
}

src_install() {
	cd ${BUILD_DIR}/binaries/
	
	exeinto /usr/bin
	doexe mitsuba mtsgui mtsimport mtssrv mtsutil || die
	dolib.so libmitsuba-bidir.so libmitsuba-core.so libmitsuba-hw.so libmitsuba-render.so   || die
	
	insinto "/usr/share/${PN}"
	doins -r data/*  || die
	
	exeinto "/usr/share/${PN}/plugins"
	doexe plugins/*.so  || die

	exeinto "/usr/lib/python3.5/lib-dynload"
	doexe python/*.so  || die
	
	insinto "/usr/include"
	doins -r ${S}/include/${PN}  || die
}