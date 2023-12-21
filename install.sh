#!/bin/bash

dirArchIsoFiles=~/archisofiles
dotfiles=~/.dotfiles
counterAbortedPkg=0

setStatusE () {
  if [ "$1" = true ]; then
    set +e 
  else
    set -e
  fi
}

setStatusE false

yaySetupPkg () {
  cd
  git clone https://aur.archlinux.org/yay
  
  cd ~/yay
  makepkg -isr

	yay -S --needed - < "$dirArchIsoFiles"/pkglist.txt
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
      break
	  fi

  done

  cd
  git clone https://github.com/blueingreen68/.dotfiles
  wl-copy -c
}

readArrays () {
   readarray -t stowPkgs < <(ls -l  "$dotfiles" | grep '^d' | awk '{ print $9 }') 
}

checkPkg () {
  counterAbortedPkg=$((counterAbortedPkg+1))

  echo "Название: $package" >> "$dotfiles"/abortedPkg.txt 

  stow -d "$dotfiles" -nvt ~ "$package" 2>&1 | awk  '{ print $11 }' >> "$dotfiles"/abortedPkg.txt 
}

stowNoFolding () {
  setStatusE true

  stow -d "$dotfiles" --no-folding -nvt ~ "$package"

  if [ $? -eq 1 ]; then
    setStatusE false
    checkPkg
  else
    setStatusE false
    stow -d "$dotfiles" --no-folding -vt ~ "$package"
  fi
}

stowDir () {
  setStatusE true

  stow -d "$dotfiles" -nvt ~ "$package" 

  if [ $? -eq 1 ]; then
    setStatusE false
    checkPkg
  else
    setStatusE false
    stow -d "$dotfiles" -vt ~ "$package"
  fi
}

stowPkgExtract () {
  for package in ${stowPkgs[@]}
    do
      packageFirstSymbol=${package:0:1}

      if [ "$packageFirstSymbol" = "_" ]; then
        stowNoFolding  
      else
        stowDir
      fi
  done
}

stowUpdateNoFoldingPkg () {
  for package in ${stowPkgs[@]}
    do
      packageFirstSymbol=${package:0:1}

      if [ "$packageFirstSymbol" = "_" ]; then
        stowNoFolding
      fi
  done
}

swaySetup () {
  echo "[ "$(tty)" = "/dev/tty1" ] && exec sway" >> .bash_profile
}

startSetup () {
  select event in Pacman Stow StowUpdate; do
      case $event in
		    Yay)
          yaySetupPkg
          swaySetup

          break
			    ;;

        Stow)
          cloneDotfiles
          readArrays
          stowPkgExtract

			    break
			    ;;

        StowUpdateNoFolding)
          stowUpdateNoFoldingPkg

          break 
          ;;

        *)
			    echo "Invalid option... Выход"
			    exit
			    ;;
      esac
  done
  
  if [ "$counterAbortedPkg" -gt 0 ]; then
    echo "Количество нераспакованных пакетов: $counterAbortedPkg"
    echo "Список находится в ~/.dotfiles/abortedPkg.txt"
  fi
}

# Установка
cloneDotfiles
