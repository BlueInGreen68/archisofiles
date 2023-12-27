#!/bin/bash 

wget https://yadi.sk/d/o4TMFnHFobxTsw -O "$dirArchIsoFiles"/Passwords.kdbx

openKeepass () {

  setStatusE true

  keepassxc-cli clip "$dirArchIsoFiles"/Passwords.kdbx github 0 -a token-cli
}

cloneDotfiles () {
  while :
  do openKeepass
    
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

cloneDotfiles
