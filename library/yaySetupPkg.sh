yaySetupPkg () {
  cd
  git clone https://aur.archlinux.org/yay
  
  cd $HOME/yay
  makepkg -isr

  cd 
  rm -rf $HOME/yay

  if [ "$1" = "pc" ]; then
    yay -S --needed - < "$dirArchIsoFiles"/pkglist.txt
  elif [ "$1" = "notebook" ]; then
    yay -S --needed - < "$dirArchIsoFiles"/pkglistnote.txt
  fi
}

select platform in "pc" "notebook"; do 
    yaySetupPkg "$platform"
done
