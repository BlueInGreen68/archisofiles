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

pacmanSetupPkg () {
	sudo pacman -S --needed - < "$archisofiles"/pkglist.txt
}

cloneDotfiles () {
  keepassxc-cli show "$dirArchIsoFiles"/Passwords.kdbx github | grep "Notes:" | awk '{ print $2 }' | wl-copy
  echo "Пароль скопирован и находится в буфере обмена"
  git clone https://github.com/blueingreen68/.dotfiles
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

    stow -d "$dotfiles" --no-folding --adopt -vt ~ "$package"
  fi
}

stowDir () {
  setStatusE true

  stow -d "$dotfiles" --adopt -nvt ~ "$package" 

  if [ $? -eq 1 ]; then
    setStatusE false

    checkPkg
  else
    setStatusE false
    
    stow -d "$dotfiles" --adopt -vt ~ "$package"
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

startSetup () {
  select event in Pacman Stow StowUpdate; do
      case $event in
		    Pacman)
          pacmanSetupPkg
          break
			    ;;

        Stow)
          pacmanSetupPkg
          cloneDotfiles
          readArrays
          stowPkgExtract

			    break
			    ;;

        StowUpdate)
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
startSetup
