#!/bin/bash 

if [ "$1" = "pipx" ]; then
  source $HOME/"$dirArchIsoFiles"/setupPkgPipx.sh
elif [ "$1" = "yay" ]; then
  source $HOME/"$dirArchIsoFiles"/setupPkgYay.sh 
fi
