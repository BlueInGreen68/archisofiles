#!/bin/bash

function setStatusE() {
  if [[ "$1" = true ]]; then
    set +e
  else
    set -e
  fi
}

setStatusE false

function getKdbxFile() {
  read -r passwordFileLink < <("$HOME/.local/bin/yadisk-direct" https://yadi.sk/d/o4TMFnHFobxTsw)

  wget "$passwordFileLink" -O ~/Passwords.kdbx
}

function openKeepass() {
  setStatusE true

  keepassxc-cli clip ~/Passwords.kdbx Github 0 -a token-cli
}

pipx install wldhx.yadisk-direct

if [[ "$?" -eq 1 ]]; then
  echo "Ошибка установки wldhx.yadisk-direct... Выход"
  exit 1
fi

getKdbxFile

while :; do
  openKeepass

  if [[ $? -eq 0 ]]; then
    setStatusE false
    echo -e "Пароль скопирован!\n"
    break
  fi
done

cd
git clone https://blueingreen68@github.com/blueingreen68/dotfiles "$HOME"/.dotfiles
wl-copy -c
