# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs flag-o-matic

DESCRIPTION="SYSLINUX, PXELINUX, ISOLINUX, EXTLINUX and MEMDISK bootloaders"
HOMEPAGE="https://www.syslinux.org/"

EGIT_REPO_URI="https://repo.or.cz/syslinux"
EGIT_COMMIT="bd91041bff259cf4303fa6bbb0b6bce33fa7c1e8"
EGIT_SUBMODULES=()

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* amd64 x86"
IUSE="custom-cflags abi_x86_32 abi_x86_64 +bios +efi"
REQUIRED_USE="|| ( bios efi )
	efi? ( || ( abi_x86_32 abi_x86_64 ) )"

BDEPEND="
	dev-lang/perl
	bios? ( dev-lang/nasm )
	efi? ( >=sys-boot/gnu-efi-3.0u )
	app-arch/upx
"
RDEPEND="
	sys-apps/util-linux
	sys-fs/mtools
	dev-perl/Crypt-PasswdMD5
	dev-perl/Digest-SHA1
"
DEPEND="${RDEPEND}
	virtual/os-headers
"

QA_PREBUILT="usr/share/${PN}/*.c32"
QA_EXECSTACK="usr/share/syslinux/*"
QA_WX_LOAD="usr/share/syslinux/*"
QA_PRESTRIPPED="usr/share/syslinux/.*"
QA_FLAGS_IGNORED=".*"

PATCHES=(
	#"${FILESDIR}"/syslinux-6.04_pre1-acpi_off.patch
	"${FILESDIR}"/syslinux-6.03-sysmacros.patch
	"${FILESDIR}"/0002-gfxboot-menu-label.patch
	"${FILESDIR}"/0003-memdisk-Force-ld-output-format-to-32-bits.patch
	"${FILESDIR}"/0004-gnu-efi-from-arch.patch
	"${FILESDIR}"/0004-Inherit-toolchain-vars-from-environment.patch
	"${FILESDIR}"/0005-gnu-efi-version-compatibility.patch
	"${FILESDIR}"/0015-efi-main.c-include-efisetjmp.h.patch
	"${FILESDIR}"/0017-Replace-builtin-strlen-that-appears-to-get-optimized.patch
	"${FILESDIR}"/0016-strip-gnu-property.patch
	"${FILESDIR}"/0017-single-load-segment.patch
	"${FILESDIR}"/0018-prevent-pow-optimization.patch
	#"${FILESDIR}"/0025-reproducible-build.patch
	"${FILESDIR}"/0006-The-VPrint-definition-is-now-part-of-the-exports-of-.patch
	"${FILESDIR}"/0007-Update-the-longjump-calls-to-fit-the-new-declaration.patch
	"${FILESDIR}"/syslinux-6.04_pre1-fcommon.patch #705730
	"${FILESDIR}"/syslinux-6.04_pre3-debug.c-fix-printf-include.patch
)

src_prepare() {
	default

	rm -f gethostip #bug 137081

	# Don't prestrip or override user LDFLAGS, bug #305783
	local SYSLINUX_MAKEFILES="extlinux/Makefile linux/Makefile mtools/Makefile \
		sample/Makefile utils/Makefile"
	sed -i ${SYSLINUX_MAKEFILES} -e '/^LDFLAGS/d' || die "sed failed"
	sed -i mk/efi.mk mk/syslinux.mk -e "/^LIBDIR/s|\/lib|\/$(get_libdir)|g" || die "sed failed"
	# disable debug and development flags to reduce bootloader size
	truncate --size 0 mk/devel.mk
	append-ldflags "--no-dynamic-linker"
	append-cflags "-fno-PIE"

	if use custom-cflags; then
		sed -i ${SYSLINUX_MAKEFILES} \
			-e 's|-g -Os||g' \
			-e 's|-Os||g' \
			-e 's|CFLAGS[[:space:]]\+=|CFLAGS +=|g' \
			|| die "sed custom-cflags failed"
	fi

	# building with ld.gold causes problems, bug #563364
	if tc-ld-is-gold; then
		ewarn "Building syslinux with the gold linker may cause problems, see bug #563364"
		if [[ -z "${I_KNOW_WHAT_I_AM_DOING}" ]]; then
			tc-ld-disable-gold
			ewarn "set I_KNOW_WHAT_I_AM_DOING=1 to override this."
		else
			ewarn "Continuing anyway as requested."
		fi
	fi
}
src_compile() {
	filter-lto #863722

	local DATE=$(date -u -r NEWS +%Y%m%d)
	local HEXDATE=$(printf '0x%08x' "${DATE}")

	tc-export AR CC LD OBJCOPY RANLIB
	unset CFLAGS LDFLAGS

	if use bios; then
		emake bios DATE="${DATE}" HEXDATE="${HEXDATE}"
	fi
	if use efi; then
		if use abi_x86_32; then
			emake efi32 DATE="${DATE}" HEXDATE="${HEXDATE}"
		fi
		if use abi_x86_64; then
			emake efi64 DATE="${DATE}" HEXDATE="${HEXDATE}"
		fi
	fi
}

src_install() {
	local firmware=( $(usev bios) )
	if use efi; then
		use abi_x86_32 && firmware+=( efi32 )
		use abi_x86_64 && firmware+=( efi64 )
	fi
	local args=(
		INSTALLROOT="${ED}"
		MANDIR='$(DATADIR)/man'
		"${firmware[@]}"
		install
	)
	emake -j1 "${args[@]}"
	if use bios; then
		mv "${ED}"/usr/bin/keytab-{lilo,syslinux} || die
	fi
	einstalldocs
	dostrip -x /usr/share/syslinux
}
