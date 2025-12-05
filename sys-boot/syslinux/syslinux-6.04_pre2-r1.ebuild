# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs flag-o-matic secureboot

DESCRIPTION="SYSLINUX, PXELINUX, ISOLINUX, EXTLINUX and MEMDISK bootloaders"
HOMEPAGE="https://www.syslinux.org/"

MY_P="${P/_/-}"
SRC_URI="https://www.zytor.com/pub/syslinux/Testing/6.04/${MY_P}.tar.xz
https://git.zytor.com/syslinux/syslinux.git/snapshot/${MY_P}.tar.xz"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-2"
SLOT="0"
#KEYWORDS="-* ~amd64 ~x86"
IUSE="custom-cflags abi_x86_32 abi_x86_64 +bios +uefi"

RESTRICT="mirror test"

BDEPEND="
	dev-lang/perl
	bios? ( dev-lang/nasm )
	sys-devel/gcc:*
"
RDEPEND="
	sys-apps/util-linux
	sys-fs/mtools
	dev-perl/Crypt-PasswdMD5
	dev-perl/Digest-SHA1
"
DEPEND="${RDEPEND}
	app-arch/upx
	uefi? ( sys-boot/gnu-efi[abi_x86_32(-)?,abi_x86_64(-)?] )
	virtual/os-headers
"

# This ebuild is a departure from the old way of rebuilding everything in syslinux
# This departure is necessary since hpa doesn't support the rebuilding of anything other
# than the installers.

# These are executables which come precompiled and are run by the boot loader
QA_EXECSTACK="usr/share/syslinux/*"
QA_WX_LOAD="usr/share/syslinux/*"
QA_PRESTRIPPED="usr/share/syslinux/.*"
QA_FLAGS_IGNORED=".*"

pkg_setup() {
	use uefi && secureboot_pkg_setup
}

# removed all the unpack/patching stuff since we aren't rebuilding the core stuff anymore

PATCHES=(
	#"${FILESDIR}"/acpi_off.patch
	"${FILESDIR}"/0002-gfxboot-menu-label.patch
	#"${FILESDIR}"/0003-memdisk-Force-ld-output-format-to-32-bits.patch
	"${FILESDIR}"/0004-gnu-efi-from-arch.patch
	#"${FILESDIR}"/0005-gnu-efi-version-compatibility.patch
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
    #"${FILESDIR}"/0001-linux-syslinux-support-ext2-3-4-device.patch
    #"${FILESDIR}"/0002-linux-syslinux-implement-open_ext2_fs.patch
    #"${FILESDIR}"/0003-linux-syslinux-implement-install_to_ext2.patch
    #"${FILESDIR}"/0004-linux-syslinux-add-ext_file_read-and-ext_file_write.patch
    #"${FILESDIR}"/0005-linux-syslinux-implement-handle_adv_on_ext.patch
    #"${FILESDIR}"/0006-linux-syslinux-implement-write_to_ext-and-add-syslin.patch
    #"${FILESDIR}"/0007-linux-syslinux-implement-ext_construct_sectmap_fs.patch
    #"${FILESDIR}"/0008-libinstaller-syslinuxext-implement-syslinux_patch_bo.patch
    #"${FILESDIR}"/0009-linux-syslinux-implement-install_bootblock.patch
    "${FILESDIR}"/0010-Workaround-multiple-definition-of-symbol-errors.patch
    "${FILESDIR}"/0001-install-don-t-install-obsolete-file-com32.ld.patch
    "${FILESDIR}"/determinism.patch
)

src_prepare() {
	default

	# Force gcc because build failed with clang, #729426
	if ! tc-is-gcc ; then
		ewarn "syslinux can be built with gcc only."
		ewarn "Ignoring CC=$(tc-getCC) and forcing ${CHOST}-gcc"
		export CC=${CHOST}-gcc
		export CXX=${CHOST}-g++
		tc-is-gcc || die "tc-is-gcc failed in spite of CC=${CC}"
	fi

	use elibc_musl && ( eapply "${FILESDIR}/syslinux-musl.patch" || die )

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
	append-cflags "-DNO_INLINE_FUNCS"

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

efimake() {
	local ABI="${1}"
	local libdir="$(get_libdir)"
	shift
	local args=(
		EFIINC="${ESYSROOT}/usr/include/efi"
		LIBDIR="${ESYSROOT}/usr/${libdir}"
		LIBEFI="${ESYSROOT}/usr/${libdir}/libefi.a"
		"${@}"
	)
	emake "${args[@]}"
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
	filter-lto #863722

	local DATE=$(date -u -r NEWS +%Y%m%d)
	local HEXDATE=$(printf '0x%08x' "${DATE}")

	tc-export AR CC LD OBJCOPY RANLIB
	unset CFLAGS LDFLAGS

	if use bios; then
		emake bios DATE="${DATE}" HEXDATE="${HEXDATE}" UPX=false
	fi
	if use uefi; then
		if use abi_x86_32; then
			efimake x86 efi32 DATE="${DATE}" HEXDATE="${HEXDATE}"
		fi
		if use abi_x86_64; then
			efimake amd64 efi64 DATE="${DATE}" HEXDATE="${HEXDATE}"
		fi
	fi
}

src_install() {
	local firmware=( $(usev bios) )
	if use uefi; then
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

	use uefi && secureboot_auto_sign --in-place
}
