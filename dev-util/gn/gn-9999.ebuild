# Copyright 2018-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python{2_7,3_{5,6,7}} )

inherit git-r3 ninja-utils python-any-r1 toolchain-funcs

DESCRIPTION="GN is a meta-build system that generates build files for Ninja"
HOMEPAGE="https://gn.googlesource.com/"
if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://gn.googlesource.com/gn"
fi

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE="vim-syntax"

BDEPEND="
	${PYTHON_DEPS}
	dev-util/ninja
"

pkg_setup() {
	:
}

src_configure() {
	python_setup
	tc-export AR CC CXX
	unset CFLAGS
	set -- ${EPYTHON} build/gen.py --no-last-commit-position --no-strip
	echo "$@" >&2
	"$@" || die
	cat >out/last_commit_position.h <<-EOF || die
	#ifndef OUT_LAST_COMMIT_POSITION_H_
	#define OUT_LAST_COMMIT_POSITION_H_
	#define LAST_COMMIT_POSITION "${PV}"
	#endif  // OUT_LAST_COMMIT_POSITION_H_
	EOF
}

src_compile() {
	eninja -C out gn
}

src_test() {
	eninja -C out gn_unittests
	out/gn_unittests || die
}

src_install() {
	dobin out/gn
	einstalldocs

	if use vim-syntax; then
		insinto /usr/share/vim/vimfiles
		doins -r tools/gn/misc/vim/{autoload,ftdetect,ftplugin,syntax}
	fi
}
