#!/bin/bash 

source "$dirArchIsoFiles"/stowPkgExtract.sh

stowUpdateNoFoldingPkg () {

  for package in ${stowPkgs[@]}
    do
      packageFirstSymbol=${package:0:1}

      if [ "$packageFirstSymbol" = "_" ]; then
        stowNoFolding
      fi
  done
  
}

stowUpdateNoFoldingPkg
