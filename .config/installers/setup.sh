#!/bin/bash
# vim: et sw=2 ts=2 ai :

# may be useful for OS-dependent stuff, e.g. choosing a package manager
#[ -f /etc/os-release ] && source /etc/os-release

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
maybeclone() { [[ -d "$2" ]] || git clone "$1" "$2"; }
cmd() { command -v $1 >/dev/null 2>&1; }
APT=""
pkg() { cmd $1 || APT="$APT $2"; }

# Check for presence of software or install it
pkg git git
pkg nvim neovim
pkg zsh zsh
pkg tmux tmux
[[ -f "/usr/share/tmux-plugin-manager/tpm" ]] || APT="$APT tmux-plugin-manager"
pkg black black
pkg shellcheck shellcheck
pkg node nodejs  # For coc-nvim
pkg npx npm  # For coc-git
pkg go "golang-go golang-src"  # For shfmt
pkg yarnpkg yarnpkg  # For building node-based coc extensions. Seems to be known as 'yarn' - is 'yarnpkg' debian-specific?
[[ -f "/usr/share/fonts/opentype/PowerlineSymbols.otf" ]] || APT="$APT fonts-powerline"
python3 -m ensurepip -h >/dev/null 2>&1 || APT="$APT python3-venv"
GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt
go get github.com/mattn/efm-langserver

if [[ -n $APT ]]; then
  echo "Need to install: $APT"
  if cmd apt; then
    echo sudo apt install $APT
  else
    echo "No apt found." >&2
    exit 1
  fi
else
  echo "Nothing to install."
fi

mkdir -p "$CONFIG/nvim/pack/manual/"{opt,start} "$CONFIG/git"

echo "Please enter your settings for $CONFIG/git/personal.config:"
read -e -i 'Christian Thießen' -p 'Name: ' gitname
read -e -i 'flos''s@ct''hiessen.de' -p 'E-Mail address: ' gitemail
cat > "$CONFIG/git/personal.config" <<EOF
[user]
	name = $gitname
	email = $gitemail
EOF

# For building coc-git. Doen't work when installed locally
sudo npm install -g npx-run npm-run-all

wget -O - 'https://github.com/latex-lsp/texlab/releases/latest/download/texlab-x86_64-linux.tar.gz' | tar xzf - -C "$HOME/.local/bin/"

# Install the SourceCodePro font
mkdir -p "$HOME/.local/share/fonts"
wget -O /tmp/fonts-master.zip 'https://github.com/powerline/fonts/archive/master.zip'
unzip /tmp/fonts-master.zip -d "/tmp"
cp -r "/tmp/fonts-master/SourceCodePro" "$HOME/.local/share/fonts/"
rm /tmp/fonts-master.zip
fc-cache

# Oh my Zsh extension for zsh
maybeclone "https://github.com/ohmyzsh/ohmyzsh.git" "$HOME/.oh-my-zsh"

# tmux package manager is installed globally
# maybeclone "https://github.com/tmux-plugins/tpm" "$CONFIG/tmux/plugins/tpm"
if [[ `(echo 'tmux 3.1'; tmux -V) | sort -k 2 -V -s | tail -n 1` == 'tmux 3.1' ]]; then
  # tmux version less than 3.1?
  ln -s ".config/tmux/tmux.conf" "$HOME/.tmux.conf"
fi
mkdir -p "$HOME/.tmux/"
ln -s "../.config/tmux/plugins" "$HOME/.tmux/plugins"

# Vim8/neovim package manager
maybeclone "https://github.com/k-takata/minpac.git" "$CONFIG/nvim/pack/minpac/opt/minpac"
# Vim features / plugins to enable
cat > "$CONFIG/nvim/features.vim" <<EOF
" todo: Have the install script ask questions before installation and create
" this file accordingly.
let g:have_c=1
let g:have_python=1
let g:have_latex=1
let g:have_yocto=1
let g:have_bash=1
EOF
nvim --headless '+PackUpdate' +qa

if cmd zsh; then
  echo "Changing shell to zsh."
  chsh -s "$(which zsh)"
fi
