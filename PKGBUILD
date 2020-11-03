#!/bin/bash
# This is an example PKGBUILD file. Use this as a start to creating your own,
# and remove these comments. For more information, see 'man PKGBUILD'.
# NOTE: Please fill out the license field for your package! If it is unknown,
# then please put 'unknown'.

# The following guidelines are specific to BZR, GIT, HG and SVN packages.
# Other VCS sources are not natively supported by makepkg yet.

# Maintainer: Pedro Mendes <pedro.mendes.26@gmail.com>
pkgname=web-xdg-open-git
pkgver=1.0
pkgrel=1
pkgdesc="A smart browser that tries to open content in the appropriate xdg app before resorting to the browser"
arch=('any')
url="https://github.com/mendess/web-xdg-open"
license=('GPL')
depends=('xdg-utils')
provides=("${pkgname%-VCS}")
conflicts=("${pkgname%-VCS}")
install='./install.sh'
source=('FOLDER::VCS+URL#FRAGMENT')
md5sums=('SKIP')
srcdir=
pkgdir=

# Please refer to the 'USING VCS SOURCES' section of the PKGBUILD man page for
# a description of each element in the source array.

pkgver() {
    cd "$srcdir/${pkgname%-VCS}"

    # The examples below are not absolute and need to be adapted to each repo. The
    # primary goal is to generate version numbers that will increase according to
    # pacman's version comparisons with later commits to the repo. The format
    # VERSION='VER_NUM.rREV_NUM.HASH', or a relevant subset in case VER_NUM or HASH
    # are not available, is recommended.

    # Git, no tags available
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
    cd "$srcdir/${pkgname%-VCS}" || exit
    make DESTDIR="$pkgdir/" install
}
