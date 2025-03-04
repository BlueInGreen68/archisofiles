#!/usr/bin/env bash

declare -g httpsToken

function setStatusE() {
  if [[ "$1" = "on" ]]; then
    set -e
  else
    set +e
  fi
}

setStatusE "on"

function getKdbxFile() {
  read -r passwordFileLink < <("$HOME/.local/bin/yadisk-direct" https://yadi.sk/d/o4TMFnHFobxTsw)

  wget "$passwordFileLink" -O "$HOME/Passwords.kdbx"
}

function openKeepass() {
  setStatusE "off"

  httpsToken=$(keepassxc-cli show --attributes https-token "$HOME/Passwords.kdbx" soft-serve)
  return 0
}

pipx install wldhx.yadisk-direct

if [[ "$?" -eq 1 ]]; then
  echo "Ошибка установки wldhx.yadisk-direct... Выход"
  exit 1
fi

getKdbxFile

while :; do
  if openKeepass; then
    setStatusE "on"
    break
  fi
done

cd
git clone https://"$httpsToken"@ss.bluig.xyz/.init.git "$HOME/init"
unset httpsToken
