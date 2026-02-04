# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

HOMEPAGE="https://sr.ht/~bptato/chawan"
DESCRIPTION="Lightweight and featureful terminal web browser"

inherit flag-o-matic toolchain-funcs

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://git.sr.ht/~bptato/chawan"
	KEYWORDS="-*"
else
	SRC_URI="https://git.sr.ht/~bptato/chawan/archive/v${PV}.tar.gz -> ${P}.srht.tar.gz"
	KEYWORDS="amd64 arm64 arm x86"
	S=${WORKDIR}/${PN}-v${PV}
fi

LICENSE="Unlicense"
SLOT="0"
IUSE=""

BDEPEND="
	app-arch/unzip
	dev-lang/nim
	virtual/pkgconfig
	virtual/pandoc
"

RDEPEND="
	app-arch/brotli:=
    sys-libs/ncurses:=[unicode(+)]
    net-misc/curl:=[http2,ssl,adns]
	llvm-runtimes/libatomic-stub
	>=virtual/zlib-1.2.9:=
	dev-libs/openssl:=
	net-libs/libssh2
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

src_compile() {
	append-cflags "-ffile-prefix-map=${S}/="
	use x86 && appnd-cflags "-fpermissive"
	default
}

src_install(){
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
}

