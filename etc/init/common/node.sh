#!/bin/bash
# stop script if errors occure
trap 'echo error: $0:$LINENO stopped; exit 1' ERR INT
set -eu

# get utilities
. "$DOTFILES_PATH/etc/lib/vital.sh"

# Node.js version
major=11
minor=11
build=0
version="$major.$minor.$build"

# install nodenv
if has 'nodenv'; then
  log_pass 'nodenv: already installed!'
else
  case "$(get_os)" in
    osx)
      if has 'brew'; then
        log_echo 'install nodenv with Homebrew'
        if brew install nodenv; then
          log_pass 'nodenv: installed successfully!'
        else
          log_fail 'nodenv: failed to install'
          exit 1
        fi
      else
        log_fail 'error: Homebrew is required'
        exit 1
      fi
      ;;
    *)
      log_fail 'error: this script only supported OSX'
      exit 1
      ;;
    esac
fi

# install Node.js with nodenv
if [[ "$(node -v 2>&1)" =~ ^v$version$ ]]; then
  log_pass "Node.js ($version): already installed!"
else
  if has 'nodenv'; then
    log_echo "install Node.js ($version) with nodenv"

    # initialize nodenv
    export NODENV_ROOT='/usr/local/var/nodenv'
    eval "$(nodenv init -)"

    if nodenv install $version; then
      log_pass "Node.js ($version): installed successfully!"

    else
      log_fail "Node.js ($version): failed to install"
      exit 1
    fi

    # set the installed node.js global
    nodenv rehash
    nodenv global $version

  else
    log_fail 'error: nodenv is required'
    exit 1
  fi
fi

# update npm
log_echo 'update npm'
if npm install -g npm; then
  log_pass 'npm: update successfully!'
else
  log_fail 'npm: failed to update'
  exit 1
fi
