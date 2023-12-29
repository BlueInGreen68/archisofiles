#!/bin/bash 

if [ "$1" = "pipx" ]; then
  source $HOME/bin/setupPkgPipx.sh
elif [ "$1" = "yay" ]; then
  source $HOME/bin/setupPkgYay.sh 
fi
