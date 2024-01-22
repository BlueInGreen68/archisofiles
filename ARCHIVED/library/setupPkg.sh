#!/bin/bash 

if [ "$1" = "pipx" ]; then
  source "$dirArchIsoFiles"/library/setupPkgPipx.sh
elif [ "$1" = "yay" ]; then
  source "$dirArchIsoFiles"/library/setupPkgYay.sh 
fi
