# shellcheck shell=dash
# vim: ft=sh sw=2 sts=2 et ai :
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

# set PATH so it includes user's private bin if it exists
for d in "$HOME/go/bin" "$HOME/bin" "$HOME/.local/bin" "$HOME/.cargo/bin"; do
  [ -d "$d" ] && path_prepend "$d"
done

if [ -x "$HOME/.pyenv/bin/pyenv" ]; then
  PATH=$(echo ":$PATH" | sed "s#:$HOME/.pyenv/[^:]*##g;s#^:##")
  export PYENV_ROOT="$HOME/.pyenv"
  path_prepend "$PYENV_ROOT/bin"
  eval "$(pyenv init -)"
  [ -d "$PYENV_ROOT/plugins/pyenv-virtualenv" ] && eval "$(pyenv virtualenv-init -)"
fi

export PATH

export EDITOR=vim
export VISUAL=vim

[ -n "$SSH_TTY" ] && [ -n "$TMUX" ] && export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"

ssh_agent_run() {
  local ssh_agent
  ssh_agent=$(command -v ssh-agent)
  [ -x "$ssh_agent" ] || return 1
  eval "$("$ssh_agent" -s)" >/dev/null
  trap 'kill $SSH_AGENT_PID' 0
}

ssh_agent_addkeys() {
  local ssh_add
  ssh_add=$(command -v ssh-add)
  [ -x "$ssh_add" ] || return 1
  local key
  for key in "$@"; do
    case "$key" in
      /*) [ -f "$key" ] && "$ssh_add" "$key" >/dev/null 2>&1 ;;
      *) [ -f "$HOME/.ssh/$key" ] && "$ssh_add" "$HOME/.ssh/$key" >/dev/null 2>&1 ;;
    esac
  done
}

ssh_agent_add_tsh() {
  # Add tsh certs if they are still valid.
  # Otherwise I'll have to tsh login again anyway.
  local ssh_add ssh_keygen gawk
  ssh_add=$(command -v ssh-add)
  ssh_keygen=$(command -v ssh-keygen)
  gawk=$(command -v gawk)
  [ -x "$ssh_add" ] && [ -x "$ssh_keygen" ] && [ -x "$gawk" ] || return 1
  for key in "$HOME/.tsh/keys/"*/*; do
    [ -d "$key-ssh" ] || continue
    for cert in "$key-ssh/"*-cert.pub; do
      if "$ssh_keygen" -L -f "$cert" | gawk '
/Valid:/{
  from=mktime(gensub(/[T:-]/," ","g",$3));
  to=mktime(gensub(/[T:-]/," ","g",$5));
  now=systime();
  if(now < from || now > to)
    exit 1;
}'; then
        # Create symlinks to the keys next to the cert.
        # This seems to be the only way to get ssh-add to pick them up.
        ln -sf "$key" "${cert%*-cert.pub}"
        ln -sf "$key.pub" "${cert%*-cert.pub}.pub"
        "$ssh_add" -v "${cert%*-cert.pub}" >/dev/null 2>&1
      fi
    done
  done
}

if [ -z "$SSH_AUTH_SOCK" ] && [ -z "$SSH_CONNECTION" ] && ssh_agent_run; then
  ssh_agent_addkeys id_ed25519 id_rsa
  ssh_agent_add_tsh
fi

# shellcheck source=/dev/null
[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"

unset -f ssh_agent_run ssh_agent_addkeys ssh_agent_add_tsh
