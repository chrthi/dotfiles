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
for d in "$HOME/bin" "$HOME/.local/bin"; do
  [ -d "$d" ] && path_prepend "$d"
done

if [ -x "$HOME/.pyenv/bin/pyenv" ]; then
  PATH=`echo ":$PATH" | sed "s#:$HOME/.pyenv/[^:]*##g;s#^:##"`
  export PYENV_ROOT="$HOME/.pyenv"
  path_prepend "$PYENV_ROOT/bin"
  eval "$(pyenv init -)"
  [ -d "$PYENV_ROOT/plugins/pyenv-virtualenv" ] && eval "$(pyenv virtualenv-init -)"
fi

export PATH

export EDITOR=vim
export VISUAL=vim

ssh_agent_run() {
  local ssh_agent="$(which ssh-agent)"
  if [ -z "$SSH_AUTH_SOCK" -a -x "$ssh_agent" ]; then
    eval `$ssh_agent -s` > /dev/null
    trap "kill $SSH_AGENT_PID" 0
  fi
}

ssh_agent_addkeys() {
  local ssh_add="$(which ssh-add)"
  if [ -n "$SSH_AGENT_PID" -a -x "$ssh_add" -a -d "$HOME/.ssh" ]; then
    local keys=""
    local key
    for key in "$@"; do
      [ -f "$HOME/.ssh/$key" ] && keys="$keys $HOME/.ssh/$key"
    done
    [ -n $keys ] && "$ssh_add" $keys >/dev/null 2>&1
  fi
}

ssh_agent_run
ssh_agent_addkeys id_ed25519 id_rsa
unset -f ssh_agent_run ssh_agent_addkeys
