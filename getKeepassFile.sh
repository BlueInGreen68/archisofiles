#!/bin/bash

setStatusE () {
  if [ "$1" = true ]; then
    set +e 
  else
    set -e
  fi
}

setStatusE false

getKdbxFile () {
  read -r passwordFileLink < <(yadisk-direct https://yadi.sk/d/o4TMFnHFobxTsw)

  wget "$passwordFileLink" -O "$dirArchIsoFiles"/Passwords.kdbx
}

openKeepass () {
  setStatusE true

  keepassxc-cli clip "$dirArchIsoFiles"/Passwords.kdbx github 0 -a token-cli
}

while :
do 
    openKeepass
    
	  if [ $? -eq 0 ]; then
      setStatusE false
      echo -e "Пароль скопирован!\n"
      break
    fi
done

cd
git clone https://blueingreen68@github.com/blueingreen68/dotfiles $HOME/.dotfiles
wl-copy -c
