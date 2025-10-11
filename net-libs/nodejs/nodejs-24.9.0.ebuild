# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CONFIG_CHECK="~ADVISE_SYSCALLS"
PYTHON_COMPAT=( python3_{11..13} )
PYTHON_REQ_USE="threads(+)"
MULTIPLEXER_VER="11"

inherit bash-completion-r1 check-reqs flag-o-matic linux-info ninja-utils pax-utils python-any-r1 toolchain-funcs xdg-utils

DESCRIPTION="A JavaScript runtime built on Chrome's V8 JavaScript engine"
HOMEPAGE="https://nodejs.org/"
LICENSE="Apache-1.1 Apache-2.0 BSD BSD-2 MIT npm? ( Artistic-2 )"

SLOT_MAJOR="$(ver_cut 1 ${PV})"
SLOT="${SLOT_MAJOR}/$(ver_cut 1-2 ${PV})"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nodejs/node"
	SLOT="24/0"
else
	SRC_URI="https://nodejs.org/dist/v${PV}/node-v${PV}.tar.xz"
	KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc64 ~riscv ~x86 ~amd64-linux ~x64-macos"
	S="${WORKDIR}/node-v${PV}"
fi

IUSE="+asm +corepack cpu_flags_x86_sse2 debug doc fips +icu inspector +jit \
lto lld man mold +npm pax-kernel pointer-compression +snapshot +ssl \
system-icu +system-ssl test v8-sandbox"
REQUIRED_USE="
	^^ ( mold lld )
	corepack
	inspector? ( icu ssl )
	npm? ( corepack ssl )
	system-icu? ( icu )
	system-ssl? ( ssl )
	v8-sandbox? ( pointer-compression )
"

RESTRICT="
	!test? ( test )
	mirror
"

RDEPEND="
	!net-libs/nodejs:0
	>=app-arch/brotli-1.1.0
	>=app-eselect/eselect-nodejs-20250106
	dev-db/sqlite:3
	>=dev-libs/libuv-1.51.0:=
	>=dev-libs/simdjson-3.10.1:=
	>=net-dns/c-ares-1.34.4:=
	>=net-libs/nghttp2-1.64.0:=
	>=net-libs/nghttp3-1.7.0:=
	>=sys-libs/zlib-1.3.1
	corepack? ( sys-apps/yarn )
	system-icu? (
		>=dev-libs/icu-77.1:=
	)
	system-ssl? (
		>=net-libs/ngtcp2-1.9.1:=
		>=dev-libs/openssl-3.0.16:0[asm?,fips?]
	)
"
BDEPEND="${PYTHON_DEPS}
	app-alternatives/ninja
	sys-apps/coreutils
	virtual/pkgconfig
	test? ( net-misc/curl )
	pax-kernel? ( sys-apps/elfix )
	mold? ( >=sys-devel/mold-2.0 )
	lld? ( llvm-core/lld )
"

DEPEND="${RDEPEND}"

# These are measured on a loong machine with -ggdb on, and only checked
# if debugging flags are present in CFLAGS.
#
# The final link consumed a little more than 7GiB alone, so 8GiB is the lower
# limit for memory usage. Disk usage was 19.1GiB for the build directory and
# 1.2GiB for the installed image, so we leave some room for architectures with
# fatter binaries and set the disk requirement to 22GiB.
CHECKREQS_MEMORY="8G"
CHECKREQS_DISK_BUILD="22G"

PATCHES=(
	"${FILESDIR}/${PN}-12.22.5-shared_c-ares_nameser_h.patch"
	"${FILESDIR}/${PN}-22.2.0-global-npm-config.patch"
	"${FILESDIR}/${PN}-24.2.0-lto-update.patch"
	"${FILESDIR}/${PN}-24.2.0-support-clang-pgo.patch"
	"${FILESDIR}/${PN}-19.3.0-v8-oflags.patch"
	"${FILESDIR}/${PN}-24.2.0-split-pointer-compression-and-v8-sandbox-options.patch"
)

pkg_pretend() {
	if [[ ${MERGE_TYPE} != "binary" ]]; then
		if is-flagq "-g*" && ! is-flagq "-g*0" ; then
			einfo "Checking for sufficient disk space and memory to build ${PN} with debugging CFLAGS"
			check-reqs_pkg_pretend
		fi
	fi
	( use x86 && ! use cpu_flags_x86_sse2 ) && \
		die "Your CPU doesn't support the required SSE2 instruction."
}

pkg_setup() {
	python-any-r1_pkg_setup
	linux-info_pkg_setup
}

is_flagq_last() {
	local flag="${1}"
	local olast=$(echo "${CFLAGS}" | grep -o -E -e "-O(0|g|1|z|s|2|3|4|fast)" | tr " " "\n" | tail -n 1)
	einfo "CFLAGS:\t${CFLAGS}"
	einfo "olast:\t${olast}"
	[[ "${flag}" == "${olast}" ]] && return 0
	return 1
}

src_prepare() {
	tc-export AR CC CXX PKG_CONFIG
	export V=1
	export CONFIGURATION="Release"

	# Fix compilation on Darwin
	# https://code.google.com/p/gyp/issues/detail?id=260
	sed -i -e "/append('-arch/d" tools/gyp/pylib/gyp/xcode_emulation.py || die

	# Proper libdir, hat tip @ryanpcmcquen https://github.com/iojs/io.js/issues/504
	local LIBDIR=$(get_libdir)
	sed -i -e "s|lib/|${LIBDIR}/|g" tools/install.py || die
	sed -i -e "s/'lib'/'${LIBDIR}'/" deps/npm/lib/npm.js || die

	# Avoid writing a depfile, not useful
	sed -i -e "/DEPFLAGS =/d" tools/gyp/pylib/gyp/generator/make.py || die

	# We need to disable mprotect on two files when it builds Bug 694100.
	use pax-kernel && PATCHES+=( "${FILESDIR}"/${PN}-20.6.0-paxmarking.patch )

	# https://github.com/nodejs/node/issues/51339
	use pointer-compression && PATCHES+=(
		"${FILESDIR}/${PN}-24.4.0-fix-v8-external-code-space.patch"
	)

	default

	local FP=(
		$(grep -l -r -e "-O3" $(find deps/openssl -name "*.gn*" -o -name "*gyp*"))
		common.gypi
		deps/llhttp/common.gypi
		deps/uv/common.gypi
		node.gypi
	)

	# -O3 removal breaks _FORITIFY_SOURCE
	local a1="-O3"
	local r1="-O2"
	local a2="-O2"
	local r2="-O3"
   	local oflag="-O3"
   	if is_flagq_last '-O0'; then
   		oflag="-O0"
   	elif is_flagq_last '-Og'; then
   		oflag="-Og"
   	elif is_flagq_last '-O1'; then
   		oflag="-O1"
   	elif is_flagq_last '-O2'; then
   		oflag="-O2"
   	elif is_flagq_last '-O3'; then
   		oflag="-O3 "
   	elif is_flagq_last '-O4'; then
   		oflag="-O4 "
   	elif is_flagq_last '-Ofast'; then
   		oflag="-Ofast"
   	elif is_flagq_last '-Os'; then
   		oflag="-Os"
   	elif is_flagq_last '-Oz'; then
   		oflag="-Oz"
   	fi


   	sed -i -e "s|- O3|${oflag}|g" ${FP[@]} || die
   	a1="${oflag}"
   	a2="${oflag}"

	sed -i \
		-e "s|__OFLAGS_A1__|${a1}|g" \
		-e "s|__OFLAGS_R1__|${r1}|g" \
		-e "s|__OFLAGS_A2__|${a2}|g" \
		-e "s|__OFLAGS_R2__|${r2}|g" \
		tools/v8_gypfiles/toolchain.gypi \
		|| die

	# debug builds. change install path, remove optimisations and override buildtype
	if use debug; then
		sed -i -e "s|out/Release/|out/Debug/|g" tools/install.py || die
		CONFIGURATION="Debug"
	fi
}

src_configure() {
	export ENINJA_BUILD_DIR="out/"$(usex debug "Debug" "Release")

	xdg_environment_reset

	# LTO compiler flags are handled by configure.py itself
	filter-lto

	# LTO compiler flags are handled by configure.py itself
	filter-flags \
		'-flto*' \
		'-fprofile*' \
		'-fuse-ld*'
	# GCC with -ftree-vectorize miscompiles node's exception handling code
	# causing it to fail to catch exceptions sometimes
	# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=116057
	tc-is-gcc && append-cxxflags -fno-tree-vectorize
	# https://bugs.gentoo.org/931514
	use arm64 && append-flags $(test-flags-CXX -mbranch-protection=none)
	# nodejs unconditionally links to libatomic #869992
	# specifically it requires __atomic_is_lock_free which
	# is not yet implemented by sys-libs/compiler-rt (see
	# https://reviews.llvm.org/D85044?id=287068), therefore
	# we depend on gcc and force using libgcc as the support lib
	tc-is-clang && append-ldflags "--rtlib=libgcc --unwindlib=libgcc"

	local myconf=(
		--ninja
		# ada is not packaged yet
		# https://github.com/ada-url/ada
		# --shared-ada
		--shared-brotli
		--shared-cares
		--shared-libuv
		--shared-nghttp2
		--shared-nghttp3
		--shared-ngtcp2
		--shared-simdjson
		# sindutf is not packaged yet
		# https://github.com/simdutf/simdutf
		# --shared-simdutf
		--shared-sqlite
		--shared-zlib
	)
	if ! use asm && ! use system-ssl ; then
		myconf+=( --openssl-no-asm )
	fi
	use debug && myconf+=( --debug )
	if use lto; then
		myconf+=( --enable-lto )
		use lld && myconf+=( --with-thinlto )
		use mold && myconf+=( --with-moldlto )
	else
		use mold && append-ldflags -fuse-ld=mold
		use lld && append-ldflags -fuse-ld=lld
	fi
	if use system-icu; then
		myconf+=( --with-intl=system-icu )
	elif use icu; then
		myconf+=( --with-intl=full-icu )
	else
		myconf+=( --with-intl=none )
	fi
	#use system-llhttp || myconf+=( --without-system-llhttp )
	use corepack || myconf+=( --without-corepack )
	use inspector || myconf+=( --without-inspector )
	use npm || myconf+=( --without-npm )
	use snapshot || myconf+=( --without-node-snapshot )
	if use ssl; then
		use system-ssl && myconf+=( --shared-openssl --openssl-use-def-ca-store )
	else
		myconf+=( --without-ssl )
	fi
	if use fips ; then
		myconf+=( --openssl-is-fips )
	fi
	if [[ -n "${NODEJS_OPENSSL_DEFAULT_LIST_CORE}" ]] ; then
		myconf+=( --openssl-default-cipher-list=${NODEJS_OPENSSL_DEFAULT_LIST_CORE} )
	fi
	use jit || myconf+=( --v8-lite-mode )
	if use jit && use debug && has_version "dev-debug/gdb" ; then
		myconf+=( --gdb )
	fi

	if use amd64 || use arm64 ; then
		use pointer-compression && myconf+=( --experimental-enable-pointer-compression )
	fi
	use v8-sandbox && myconf+=( --experimental-enable-v8-sandbox )
	if use kernel_linux && linux_chkconfig_present "TRANSPARENT_HUGEPAGE" ; then
		myconf+=( --v8-enable-hugepage )
	fi

	local myarch=""
	case "${ARCH}:${ABI}" in
		*:amd64) myarch="x64";;
		*:arm) myarch="arm";;
		*:arm64) myarch="arm64";;
		loong:lp64*) myarch="loong64";;
		riscv:lp64*) myarch="riscv64";;
		*:ppc64) myarch="ppc64";;
		*:x32) myarch="x32";;
		*:x86) myarch="ia32";;
		*) myarch="${ABI}";;
	esac

	GYP_DEFINES="linux_use_gold_flags=0
		linux_use_bundled_binutils=0
		linux_use_bundled_gold=0" \
	"${EPYTHON}" configure.py \
		--prefix="${EPREFIX}"/usr \
		--dest-cpu=${myarch} \
		"${myconf[@]}" || die

	# Prevent double build on install.
	sed -i -e "s|^install: all|install: |g" "Makefile" || die
}

src_compile() {
	export NINJA_ARGS=" $(get_NINJAOPTS)"
	emake -Onone
}

src_install() {
	local LIBDIR="${ED}/usr/$(get_libdir)"
	default

	local REL_D_BASE="usr/$(get_libdir)"
	local D_BASE="/${REL_D_BASE}"
	local ED_BASE="${ED}/${REL_D_BASE}"

	${EPYTHON} "tools/install.py" install \
		--dest-dir "${D}" \
		--prefix "${EPREFIX}"/usr \
		|| die

	mv "${ED}/usr/bin/node" "${ED}/usr/bin/node${SLOT_MAJOR}" || die
	dosym "node${SLOT_MAJOR}" "/usr/bin/node"

	pax-mark -m "${ED}/usr/bin/node${SLOT_MAJOR}"

	# set up a symlink structure that node-gyp expects..
	local D_INCLUDE_BASE="/usr/include/node${SLOT_MAJOR}"
	dodir "${D_INCLUDE_BASE}/deps/"{"v8","uv"}
	dosym "." "${D_INCLUDE_BASE}/src"
	local var
	for var in deps/{uv,v8}/include; do
		dosym "../.." "${D_INCLUDE_BASE}/${var}"
	done

	# Avoid merge conflict
	mv "${ED}/usr/include/node/"* "${ED}${D_INCLUDE_BASE}" || die
	rm -rf "${ED}/usr/include/node" || die

	if use doc; then
		docinto html
		dodoc -r "${S}"/doc/*
	fi

	# Use tarball instead.
	rm -rf "${ED}/usr/$(get_libdir)/node_modules/npm"
	rm -rf "${ED}/usr/bin/npm"
	rm -rf "${ED}/usr/bin/npx"

	mv \
		"${ED}/usr/share/doc/node" \
		"${ED}/usr/share/doc/${PF}" \
		|| die

	# Let eselect-nodejs handle switching corepack
	dodir "/usr/$(get_libdir)/corepack"
	mv \
		"${ED}/usr/$(get_libdir)/node_modules/corepack" \
		"${ED}/usr/$(get_libdir)/corepack/node${SLOT_MAJOR}" \
		|| die
	rm -rf "${ED}/usr/bin/corepack"

	if use npm; then
		keepdir /etc/npm
		echo "NPM_CONFIG_GLOBALCONFIG=${EPREFIX}/etc/npm/npmrc" > "${T}"/50npm
		#echo "PATH=${EPREFIX}/usr/$(get_libdir)/corepack/node${SLOT_MAJOR}" > "${T}"/50npm

		doenvd "${T}"/50npm

		dosym "/usr/$(get_libdir)/corepack/node${SLOT_MAJOR}/shims/npm" "/usr/bin/npm"
		sed -e "/^dirname /s|\$\(.\+\)|\$(readlink -q \$0)|g" -i "${ED}/usr/$(get_libdir)/corepack/node${SLOT_MAJOR}/shims/npm" || die

		# Install bash completion for `npm`
		local tmp_npm_completion_file="$(TMPDIR="${T}" mktemp -t npm.XXXXXXXXXX)"
		"${ED}/usr/$(get_libdir)/corepack/node${SLOT_MAJOR}/shims/npm" completion > "${tmp_npm_completion_file}"
		newbashcomp "${tmp_npm_completion_file}" npm

		# Move man pages
		#use man && doman "${LIBDIR}"/node_modules/npm/man/man{1,5,7}/*

		# Clean up
		rm -f "${LIBDIR}"/node_modules/npm/{.mailmap,.npmignore,Makefile}
		rm -rf "${LIBDIR}"/node_modules/npm/{doc,html,man}

		local find_exp="-or -name"
		local find_name=()
		for match in "AUTHORS*" "CHANGELOG*" "CONTRIBUT*" "README*" \
			".travis.yml" ".eslint*" ".wercker.yml" ".npmignore" \
			"*.bat" "*.cmd"; do
			find_name+=( ${find_exp} "${match}" )
		done

		# Remove various development and/or inappropriate files and
		# useless docs of dependend packages.
		find "${LIBDIR}"/node_modules \
			\( -type d -name examples \) -or \( -type f \( \
				-iname "LICEN?E*" \
				"${find_name[@]}" \
			\) \) -exec rm -rf "{}" \;
	fi

	use doc && ( mv "${ED}"/usr/share/doc/node "${ED}"/usr/share/doc/${PF} || die )

	cp --remove-destination "${FILESDIR}/node-multiplexer-v${MULTIPLEXER_VER}" "${ED}/usr/bin/node" || die
	sed -e "s|__EPREFIX__|${EPREFIX}|g" -i "${ED}/usr/bin/node" || die
	fperms 0755 "/usr/bin/node" || die
	fowners -R root:root "/usr/bin/node" || die
}

src_test() {
	local drop_tests=(
		test/parallel/test-dns.js
		test/parallel/test-dns-resolveany-bad-ancount.js
		test/parallel/test-dns-setserver-when-querying.js
		test/parallel/test-dotenv.js
		test/parallel/test-fs-mkdir.js
		test/parallel/test-fs-read-stream.js
		test/parallel/test-fs-utimes-y2K38.js
		test/parallel/test-fs-watch-recursive-add-file.js
		test/parallel/test-http2-client-set-priority.js
		test/parallel/test-http2-priority-event.js
		test/parallel/test-process-euid-egid.js
		test/parallel/test-process-get-builtin.mjs
		test/parallel/test-process-initgroups.js
		test/parallel/test-process-setgroups.js
		test/parallel/test-process-uid-gid.js
		test/parallel/test-release-npm.js
		test/parallel/test-socket-write-after-fin-error.js
		test/parallel/test-strace-openat-openssl.js
		test/sequential/test-tls-session-timeout.js
		test/sequential/test-util-debug.js
	)
	[[ "$(nice)" -gt 10 ]] && drop_tests+=( "test/parallel/test-os.js" )
	# https://bugs.gentoo.org/963649
	has_version '>=dev-libs/openssl-3.6' &&
		drop_tests+=(
			test/parallel/test-tls-ocsp-callback
		)
	use inspector ||
		drop_tests+=(
			test/parallel/test-inspector-emit-protocol-event.js
			test/parallel/test-inspector-network-arbitrary-data.js
			test/parallel/test-inspector-network-domain.js
			test/parallel/test-inspector-network-fetch.js
			test/parallel/test-inspector-network-http.js
			test/sequential/test-watch-mode.mjs
		)
	rm -f "${drop_tests[@]}" || die "disabling tests failed"

	if has usersandbox ${FEATURES}; then
		rm -f "${S}/test/parallel/test-fs-mkdir.js"
		ewarn
		ewarn "You are emerging ${PN} with 'usersandbox' enabled. Excluding tests known"
		ewarn "to fail in this mode.  For full test coverage, emerge =${CATEGORY}/${PF}"
		ewarn "with 'FEATURES=-usersandbox'."
		ewarn
	fi

	"out/${CONFIGURATION}/cctest" || die
	"${EPYTHON}" \
		"tools/test.py" \
		--mode="${CONFIGURATION,,}" \
		--flaky-tests="dontcare" \
		-J \
		message \
		parallel \
		sequential \
		|| die
}

pkg_postinst() {
	if use npm; then
		ewarn "remember to run: source /etc/profile if you plan to use nodejs"
		ewarn "in your current shell"
	fi
	if has_version ">net-libs/nodejs-${PV}" ; then
		einfo "Found higher slots, manually change the headers with \`eselect nodejs\`."
	else
		eselect nodejs set "node${SLOT_MAJOR}"
	fi
	grep -q -F "NODE_VERSION" "${EROOT}/usr/bin/node" || die "Wrapper did not copy."
	einfo
	einfo "When compiling with nodejs multislot, you to switch via"
	einfo "\`eselect nodejs\` in order to compile against the headers matching the"
	einfo "corresponding SLOT.  This means that you cannot compile with different"
	einfo "SLOTS simultaneously."
	einfo
}
