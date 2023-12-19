#!/bin/bash

set -e

dirArchIsoFiles=~/archisofiles
dotfiles=~/.dotfiles

cloneDotfiles () {
  keepassxc-cli show "$dirArchIsoFiles"/Passwords.kdbx github | grep "Notes:" | awk '{ print $2 }' | wl-copy
  echo "Пароль скопирован и находится в буфере обмена"
  git clone https://github.com/blueingreen68/.dotfiles
}

readArrays () {
   readarray -t stowPackages < <(ls -l  "$dotfiles" | grep '^d' | awk '{ print $9 }') 
}

stowPackageExtract () {
  for package in ${stowPackages[@]}
    do
      packageFirstSymbol=${package:0:1}

      if [ "$packageFirstSymbol" = "_" ]; then
        stow --no-folding -vt ~ "$package"
      else
        stow -nvt ~ "$package" 
      fi
  done
}

startSetup () {
  select event in Pacman Stow; do
      case $event in
		    Pacman)
		      pacman -S --needed - < "$archisofiles"/pkglist.txt

			    break
			    ;;

        Stow)
          cloneDotfiles
          readArrays
          stowPackageExtract

			    break
			    ;;

        *)
			    echo "Invalid option... Выход"
			    exit
			    ;;
      esac
  done
}

# Установка
startSetup

