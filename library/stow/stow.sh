#!/bin/bash 

stowReadArrays () {
   readarray -t stowPkgs < <(ls -l "$dotfiles" | grep '^d' | awk '{ print $9 }') 
}

abortedPkg () {
  if [ "$counterAbortedPkg" -gt 0 ]; then

    echo "Количество нераспакованных пакетов: $counterAbortedPkg"
    echo "Список находится в ~/.dotfiles/abortedPkg.txt"

  elif [ "$1" = "delete" ] && [ -e "$abortedPkgFile" ]; then

    rm -i "$abortedPkgFile"

  fi
}

startStow () {
    
  if [ -d "$dotfiles" ]; then
      echo "✅ Папка .dotfiles есть"
  else
      source "$dirArchIsoFiles"/library/cloneDotfiles.sh
  fi

  abortedPkg "delete"
  stowReadArrays

  select event in "Stow extract" "Stow update" "Stow add" "Stow adopt" "Back"; do 
    case "$event" in
      "Stow extract")
          source "$dirArchIsoFiles"/library/stow/stowPkgExtract.sh
          break 2 
          ;;

      "Stow update")
          source "$dirArchIsoFiles"/library/stow/stowUpdateNoFoldingPkg.sh
          break 2
          ;;

      "Stow add")
          source "$dirArchIsoFiles"/library/stow/stowAddPkg.sh
          break 2 
          ;; 

      "Stow adopt")
          source "$dirArchIsoFiles"/library/stow/stowRewriteAbortedPkg.sh 
          break 2
          ;;

      "Back")
         break
         ;;

      *)
          echo "Invalid option. Выбери один из предложенных вариантов!"
    esac
  done

  abortedPkg
}

startStow
