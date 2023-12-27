#!/bin/bash 

checkPkg () {
  counterAbortedPkg=$((counterAbortedPkg+1))

  if [ "$counterAbortedPkg" -eq 1 ]; then echo -e "$(date +%d-%m-%Y::%T) \n" >> "$dotfiles"/abortedPkg.txt
  fi
  
  echo "Название пакета: $package" >> "$dotfiles"/abortedPkg.txt 
  stow -d "$dotfiles" -nvt ~ "$package" 2>&1 | awk  '{ print $11 }' | sed '/^[[:space:]]*$/d' >> "$dotfiles"/abortedPkg.txt 
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

stowPkgExtract
