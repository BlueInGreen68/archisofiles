yaySetupPkg () {
  cd
  git clone https://aur.archlinux.org/yay
  
  cd $HOME/yay
  makepkg -isr

  cd 
  rm -rf $HOME/yay

	yay -S --needed - < "$dirArchIsoFiles"/pkglist.txt
}

yaySetupPkg
