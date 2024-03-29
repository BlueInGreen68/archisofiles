#!/bin/bash

dirArchIsoFiles=$HOME/archisofiles
dotfiles=$HOME/.dotfiles
abortedPkgFile=$HOME/.dotfiles/abortedPkg.txt
patternsHomeDir=$HOME/archisofiles/patternsHomeDir.txt
counterAbortedPkg=0

setStatusE () {

  if [ "$1" = true ]; then
    set +e 
  else
    set -e
  fi

}

startSetup () {
  select event in "Setup packages" "Dotfiles setup" "Create default home dirs"; do
      case $event in
		    "Setup packages")

          select installer in "yay" "pipx"; do 
              source "$dirArchIsoFiles"/library/setupPkg.sh "$installer"
              break
          done

          break
			    ;;

        "Dotfiles setup")
          sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply blueingreen68
			    ;;

        "Create default home dirs")
          source "$dirArchIsoFiles"/library/createDefaultDirs.sh

          break 
          ;;

        *)
			    echo "Invalid option... Выход"
			    exit
			    ;;
      esac
  done
}

setStatusE false
startSetup
