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
url="https://github.com/mendess/${pkgname%-git}"
license=('GPL')
depends=(xdg-utils file curl youtube-dl coreutils)
optdepends=(libnotify mpv xclip)
provides=("${pkgname%-git}")
conflicts=("${pkgname%-git}")
install="${pkgname%-git}".install
source=("git+$url")
md5sums=('SKIP')

# pkgver() {
#     printf 'r%s.g%s' "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
# }

package() {
    cd "${pkgname%-git}" || exit
    make PREFIX=/usr DESTDIR="$pkgdir" install
}
