# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="SYSLINUX, PXELINUX, ISOLINUX, EXTLINUX and MEMDISK bootloaders"
HOMEPAGE="https://www.syslinux.org/"

EGIT_REPO_URI="https://repo.or.cz/syslinux"
EGIT_COMMIT="458a54133ecdf1685c02294d812cb562fe7bf4c3"
EGIT_SUBMODULES=()

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="custom-cflags"

RDEPEND="
	sys-apps/util-linux
	sys-fs/mtools
		dev-perl/Crypt-PasswdMD5
		dev-perl/Digest-SHA1"
DEPEND="${RDEPEND}
	dev-lang/nasm
	app-arch/upx
	>=sys-boot/gnu-efi-3.0u
	virtual/os-headers"

# This ebuild is a departure from the old way of rebuilding everything in syslinux
# This departure is necessary since hpa doesn't support the rebuilding of anything other
# than the installers.

# These are executables which come precompiled and are run by the boot loader
QA_PREBUILT="usr/share/${PN}/*.c32"
QA_PRESTRIPPED="usr/share/syslinux/efi64/ldlinux.e64"

# removed all the unpack/patching stuff since we aren't rebuilding the core stuff anymore

PATCHES=(
	#"${FILESDIR}"/acpi_off.patch
	"${FILESDIR}"/0002-gfxboot-menu-label.patch
	#"${FILESDIR}"/0003-memdisk-Force-ld-output-format-to-32-bits.patch
	"${FILESDIR}"/0004-gnu-efi-from-arch.patch
	"${FILESDIR}"/0005-gnu-efi-version-compatibility.patch
	"${FILESDIR}"/0015-efi-main.c-include-efisetjmp.h.patch
	"${FILESDIR}"/0017-Replace-builtin-strlen-that-appears-to-get-optimized.patch
	"${FILESDIR}"/0016-strip-gnu-property.patch
	"${FILESDIR}"/0017-single-load-segment.patch
	"${FILESDIR}"/0018-prevent-pow-optimization.patch
	#"${FILESDIR}"/0025-reproducible-build.patch
	#"${FILESDIR}"/0006-The-VPrint-definition-is-now-part-of-the-exports-of-.patch
	#"${FILESDIR}"/0007-Update-the-longjump-calls-to-fit-the-new-declaration.patch
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
	else
		QA_FLAGS_IGNORED="
			/sbin/extlinux
			/usr/bin/memdiskfind
			/usr/bin/gethostip
			/usr/bin/isohybrid
			/usr/bin/syslinux
			"
	fi
	case ${ARCH} in
		amd64)	loaderarch="efi64" ;;
		x86)	loaderarch="efi32" ;;
		*)	ewarn "Unsupported architecture, building installers only." ;;
	esac

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

	tc-export AR CC LD OBJCOPY RANLIB
}

_emake() {
	emake \
		AR="${AR}" \
		CC="${CC}" \
		LD="${LD}" \
		OBJCOPY="${OBJCOPY}" \
		RANLIB="${RANLIB}" \
		"$@"
}

src_compile() {
	# build system abuses the LDFLAGS variable to pass arguments to ld
	unset LDFLAGS
	_emake spotless
	if [[ ! -z ${loaderarch} ]]; then
		_emake ${loaderarch}
	fi
	_emake bios
	_emake installer
}

src_install() {
	# parallel install fails sometimes
	einfo "loaderarch=${loaderarch}"
	_emake -j1 INSTALLROOT="${D}" MANDIR=/usr/share/man bios ${loaderarch} install
	dodoc README NEWS doc/*.txt
}

