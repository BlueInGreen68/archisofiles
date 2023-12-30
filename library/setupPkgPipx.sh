#!/bin/bash 

setupPkgPipx () {
  readarray -t pipxPkg < <(cat "$dirArchIsoFiles"/pkglists/pipxpkglist.txt)

  for pkg in ${pipxPkg[@]}; do
    pipx install "$pkg" 
  done

  pipx ensurepath

  echo "✅ Готово"
}

setupPkgPipx
