# Copyright 1999-2026 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Few modules for ACPI debugging"
HOMEPAGE="https://github.com/Lekensteyn/acpi-stuff"

inherit linux-mod-r1 flag-o-matic

if [[ ${PV} =~ "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Lekensteyn/${PN}.git"
else
	COMMIT="b55f6bdbcf926bee991d3269deafd2647dd2c53f"
	SRC_URI="https://github.com/Lekensteyn/${PN}/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.gh.tar.gz"
	KEYWORDS="amd64 x86"
	S="${WORKDIR}/${PN}-${COMMIT}"
fi

LICENSE="GPL-2"
SLOT="0"

DEPEND="virtual/linux-sources"

pkg_setup() {
	linux-info_pkg_setup
	linux-mod-r1_pkg_setup

	CONFIG_CHECK="~ACPI_EXTLOG ~DEBUG_FS"

	filter-flags -fno-plt
	filter-lto
	strip-unsupported-flags
}

src_compile() {
	local modlist=( acpi_dump_info=kernel/drivers/acpi:./acpi_dump_info pcidev=kernel/drivers/acpi:./pcidev )
	local modargs=( KVER="${KV_FULL}" KSRC="${KERNEL_DIR}" )
	append-cflags -Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types
	export WERROR_CFLAGS=
	linux-mod-r1_src_compile
}
