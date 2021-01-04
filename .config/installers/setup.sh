#!/bin/bash
# vim: et sw=2 ts=2 ai :

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

# may be useful for OS-dependent stuff, e.g. choosing a package manager
#[ -f /etc/os-release ] && source /etc/os-release

APT=""
cmd() { command -v $1 >/dev/null 2>&1; }
pkg() { cmd $1 || APT="$APT $2"; }

# Check for presence of software or install it
pkg git git
pkg nvim neovim
pkg zsh zsh
pkg tmux tmux
pkg black black
pkg node nodejs  # For coc-nvim
pkg npx npm  # For coc-git
pkg yarnpkg yarnpkg  # For building node-based coc extensions. Seems to be known as 'yarn' - is 'yarnpkg' debian-specific?
[[ -f "/usr/share/fonts/opentype/PowerlineSymbols.otf" ]] || APT="$APT fonts-powerline"
python3 -m ensurepip -h >/dev/null 2>&1 || APT="$APT python3-venv"

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

mkdir -p "$CONFIG/nvim/pack/manual/"{opt,start}

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

maybeclone() { [[ -d "$2" ]] || git clone "$1" "$2"; }

# Oh my Zsh extension for zsh
maybeclone "https://github.com/ohmyzsh/ohmyzsh.git" "$HOME/.oh-my-zsh"

# tmux package manager
maybeclone "https://github.com/tmux-plugins/tpm" "$CONFIG/tmux/plugins/tpm"

# Vim8/neovim package manager
maybeclone "https://github.com/k-takata/minpac.git" "$CONFIG/nvim/pack/minpac/opt/minpac"

# Python development
curl https://raw.githubusercontent.com/psf/black/stable/plugin/black.vim -o "$CONFIG/nvim/plugin/black.vim"

nvim --headless '+PackUpdate' +qa

#chsh -s "$(which zsh)"