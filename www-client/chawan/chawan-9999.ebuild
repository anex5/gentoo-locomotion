# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="TUI web browser; supports CSS, images, JavaScript, and multiple web protocols"
HOMEPAGE="https://chawan.net"

inherit flag-o-matic toolchain-funcs multiprocessing

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://git.sr.ht/~bptato/chawan"
else
	SRC_URI="https://git.sr.ht/~bptato/chawan/archive/v${PV}.tar.gz -> ${P}.srht.tar.gz"
	KEYWORDS="amd64 arm64 arm x86"
	S=${WORKDIR}/${PN}-v${PV}
fi

LICENSE="Unlicense"
SLOT="0"
IUSE="static-libs lto"

DEPEND="
	sys-libs/ncurses:=[unicode(+),static-libs?]
	net-misc/curl:=[brotli,http2,openssl,ssl,ssh,adns,static-libs?]
	>=virtual/zlib-1.2.9:=[static-libs?]
"

BDEPEND="
	app-arch/unzip
	>=dev-lang/nim-2.2.10
	|| (
		llvm-runtimes/libatomic-stub
		sys-devel/gcc
	)
	virtual/pkgconfig
	virtual/pandoc
"

RESTRICT="mirror"

QA_PRESTRIPPED="
usr/libexec/chawan/nc
usr/libexec/chawan/urlenc
usr/libexec/chawan/img2html
usr/libexec/chawan/dirlist2html
usr/libexec/chawan/gmi2html
usr/libexec/chawan/ansi2html
usr/libexec/chawan/md2html
usr/libexec/chawan/gopher2html
usr/libexec/chawan/tohtml
usr/libexec/chawan/cgi-bin/ssl
usr/libexec/chawan/cgi-bin/sftp
usr/libexec/chawan/cgi-bin/gemini
usr/libexec/chawan/cgi-bin/http
usr/libexec/chawan/cgi-bin/nanosvg
usr/libexec/chawan/cgi-bin/resize
usr/libexec/chawan/cgi-bin/canvas
usr/libexec/chawan/cgi-bin/sixel
usr/libexec/chawan/cgi-bin/jebp
usr/libexec/chawan/cgi-bin/stbi
usr/libexec/chawan/cgi-bin/man
usr/libexec/chawan/cgi-bin/ftp
usr/libexec/chawan/cgi-bin/file
usr/bin/mancha
usr/bin/cha
"

src_prepare(){
	default
	if use lto; then
		sed -i -E 's|^FLAGS\s+\+=.+|& -d:lto|' Makefile ||
		die "Trying to sed the Makefile for lto failed!"
	fi
	# Build native chac
	sed -e "/^\$(OBJDIR)\/chac.*$/,/^$/s|\$(NIMC)|env NIMFLAGS="" CROSS_COMPILE="" CFLAGS="" CXXFLAGS="" \
		CC=$(tc-getBUILD_CC) CXX=$(tc-getBUILD_CXX) \$(NIMC)\
		--skipCfg --skipUserCfg --skipParentCfg --skipProjCfg --cc:env --path:lib/monoucha0 --path:src \
		--cpu:$(tc-arch ${CBUILD}) --os:linux --nimcache:\$(OBJDIR)\/nimcache-host|" -i Makefile || die
}

src_configure(){
	# code is mostly copy pasted from the nim_gen_config() function from nim-utils.eclass, modifed a bit to actually
	# append to the original nim.cfg, instead of replacing it
	cat >> "${S}"/nim.cfg <<- EOF || die "Failed to append to Nim config"
		--parallelBuild:"$(get_makeopts_jobs)"

		cc:"gcc"
		gcc.exe:"$(tc-getCC)"
		gcc.linkerexe:"$(tc-getCC)"
		gcc.cpp.exe:"$(tc-getCXX)"
		gcc.cpp.linkerexe:"$(tc-getCXX)"
		gcc.options.speed:"${CFLAGS}"
		gcc.options.size:"${CFLAGS}"
		gcc.options.debug:"${CFLAGS}"
		gcc.options.always:"${CPPFLAGS}"
		gcc.options.linker:"${LDFLAGS}"
		gcc.cpp.options.speed:"${CXXFLAGS}"
		gcc.cpp.options.size:"${CXXFLAGS}"
		gcc.cpp.options.debug:"${CXXFLAGS}"
		gcc.cpp.options.always:"${CPPFLAGS}"
		gcc.cpp.options.linker:"${LDFLAGS}"
	EOF
	default
}

src_compile() {
	append-cflags "-ffile-prefix-map=${S}/="
	use x86 && appnd-cflags "-fpermissive"
	export STATIC_LINK=$(usex static-libs 1 0)
	emake all
}

src_install(){
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
}

src_test(){
	emake test
}
