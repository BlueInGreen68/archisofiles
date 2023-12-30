#!/bin/bash 

setupPkgPipx () {
  readarray -t pipxPkg < <(cat $HOME/"$dirArchIsoFiles"/pkglists/pipxpkglist.txt)

  for pkg in ${pipxPkg[@]}; do
    pipx install "$pkg" 
  done
}

setupPkgPipx
