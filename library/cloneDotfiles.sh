#!/bin/bash 

getKdbxFile () {
  read -r passwordFile < <(yadisk-direct https://yadi.sk/d/o4TMFnHFobxTsw)

  wget "$passwordFile" -O $HOME/"$dirArchIsoFiles"/Passwords.kbdx
}

openKeepass () {
  setStatusE true

  keepassxc-cli clip "$dirArchIsoFiles"/Passwords.kdbx github 0 -a token-cli
}

cloneDotfiles () {
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
  git clone https://blueingreen68@github.com/blueingreen68/.dotfiles
  wl-copy -c
}

source "$dirArchIsoFiles"/library/setupPkgPipx.sh
cloneDotfiles
