#!/bin/bash 

selectAnswer () {
  echo "Перезаписать оригинальный пакет?: "
  select answer in Yes No; do
    case "$answer" in
      "Yes")
          if [ "$1" = "no-folding" ]; then
            stow -d "$dotfiles" --adopt --no-folding -vt ~ "$package" 
          else
            stow -d "$dotfiles" --adopt -vt ~ "$package" 
          fi
        
          git checkout .
          break
          ;;

      "No")
          echo "Выход..."
          exit

          ;;
      *)
          echo "Invalid option. Выбери один из предложенных вариантов!"
    esac
  done
}

stowRewriteAbortedPkg () {
  select package in ${stowPkgs[@]}; do 

    setStatusE true
    
    packageFirstSymbol=${package:0:1}

    if [ "$packageFirstSymbol" = "_" ]; then

      stow -d "$dotfiles" --no-folding -nvt ~ "$package" 
      
      if [ $? -eq 1 ]; then

        setStatusE false
        selectAnswer "no-folding"

      fi

    else
        
      stow -d "$dotfiles" -nvt ~ "$package"

      if [ $? -eq 1 ]; then
        
        setStatusE false
        selectAnswer

      fi
    fi
   
    echo "Файл успешно перезаписан!"
    return 
  done
}

stowRewriteAbortedPkg
