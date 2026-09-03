# Maintainer: xsiphr <https://github.com/xsiphr>
pkgname=voxr-git
pkgver=1.1.0
pkgrel=1
pkgdesc="A unified terminal aesthetics manager (system-info fetch layout + terminal colorscheme)"
arch=('any')
url="https://github.com/xsiphr/voxr24"
license=('MIT')
depends=('bash' 'fastfetch')
optdepends=(
  'kitty: for Kitty terminal color switching support'
  'alacritty: for Alacritty terminal color switching support'
  'ghostty: for Ghostty terminal color switching support'
  'foot: for Foot terminal color switching support'
)
provides=('voxr')
conflicts=('voxr')
source=("git+https://github.com/xsiphr/voxr24.git")
sha256sums=('SKIP')

pkgver() {
  cd "$srcdir/voxr24"
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
  cd "$srcdir/voxr24"

  # Install binary
  install -Dm755 voxr "$pkgdir/usr/bin/voxr"

  # Install assets and modules
  install -d "$pkgdir/usr/share/voxr"
  cp -dr --no-preserve=ownership fetchers colorschemes adapters presets "$pkgdir/usr/share/voxr/"

  # Install shell completions
  install -Dm644 completions/voxr.bash "$pkgdir/usr/share/bash-completion/completions/voxr"
  install -Dm644 completions/voxr.zsh "$pkgdir/usr/share/zsh/site-functions/_voxr"
  install -Dm644 completions/voxr.fish "$pkgdir/usr/share/fish/vendor_completions.d/voxr.fish"

  # Install license and documentation
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
}
