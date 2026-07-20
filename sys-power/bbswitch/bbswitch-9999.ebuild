# Copyright 1999-2026 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

MODULES_KERNEL_MAX=5.6.0
MODULES_KERNEL_MIN=2.6.33

DESCRIPTION="Toggle discrete NVIDIA Optimus graphics card"
HOMEPAGE="https://github.com/Bumblebee-Project/bbswitch"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/Bumblebee-Project/bbswitch.git"
	EGIT_BRANCH="develop"
	inherit git-r3
else
	COMMIT="23891174a80ea79c7720bcc7048a5c2bfcde5cd9"
	SRC_URI="https://github.com/Bumblebee-Project/bbswitch/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.gh.tar.gz"
	KEYWORDS="amd64 x86"
	S="${WORKDIR}/${PN}-${COMMIT}"
fi

LICENSE="GPL-3+"
SLOT="0"

DEPEND="
	virtual/linux-sources
	sys-kernel/linux-headers
"

RESTRICT="mirror bindist"

PATCHES=(
	"${FILESDIR}/bbswitch-0.8-fix-acpi_bus_get_device-PR219.patch"
)

pkg_setup() {
	linux-mod-r1_pkg_setup

	CONFIG_CHECK="~ACPI ~VGA_SWITCHEROO"
}

src_compile() {
	local modlist=( bbswitch=kernel/drivers/misc/bbswitch:. )
	local modargs=(
		KVERSION="${KV_FULL}"
		KDIR=${KERNEL_DIR}
	)

	linux-mod-r1_src_compile
}

src_install() {
	insinto /etc/modprobe.d
	newins "${FILESDIR}"/bbswitch.modprobe bbswitch.conf
	dodoc NEWS README.md

	linux-mod-r1_src_install
}
