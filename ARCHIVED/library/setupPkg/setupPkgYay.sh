#!/bin/bash 

setupPkgYay () {
  cd
  git clone https://aur.archlinux.org/yay
  
  cd $HOME/yay
  makepkg -isr

  cd 
  rm -rf $HOME/yay

  if [ "$1" = "pc" ]; then
    yay -S --needed - < "$dirArchIsoFiles"/pkglists/pkglist.txt
  elif [ "$1" = "notebook" ]; then
    yay -S --needed - < "$dirArchIsoFiles"/pkglists/pkglistnote.txt
  fi
}

select platform in "pc" "notebook"; do 

    if [ "$platform" = "" ]; then
      echo "Invalid option"
      break
    else
      setupPkgYay "$platform"
    fi

  echo "✅ Готово"
done
