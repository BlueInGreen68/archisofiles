#!/bin/bash

dirArchIsoFiles=~/archisofiles
dotfiles=~/.dotfiles
abortedPkgFile=~/.dotfiles/abortedPkg.txt
patternsHomeDir=~/archisofiles/patternsHomeDir.txt
counterAbortedPkg=0

setStatusE () {

  if [ "$1" = true ]; then
    set +e 
  else
    set -e
  fi

}

setStatusE false


openKeepass () {
  
  wget https://yadi.sk/d/o4TMFnHFobxTsw -O "$dirArchIsoFiles"/Passwords.kdbx

  setStatusE true

  keepassxc-cli clip "$dirArchIsoFiles"/Passwords.kdbx github 0 -a token-cli

}

cloneDotfiles () {

  while :
  do openKeepass
    
	  if [ $? -eq 0 ]; then
      setStatusE false
      break
	  fi

  echo -e "Пароль скопирован!\n"
  done

  cd
  git clone https://blueingreen68@github.com/blueingreen68/.dotfiles
  wl-copy -c

}

readArrays () {
   readarray -t stowPkgs < <(ls -l "$dotfiles" | grep '^d' | awk '{ print $9 }') 
}

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
    setStatusE false checkPkg
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

stowUpdateNoFoldingPkg () {

  for package in ${stowPkgs[@]}
    do
      packageFirstSymbol=${package:0:1}

      if [ "$packageFirstSymbol" = "_" ]; then
        stowNoFolding
      fi
  done
  
}

abortedPkg () {

  if [ "$counterAbortedPkg" -gt 0 ]; then
    echo "Количество нераспакованных пакетов: $counterAbortedPkg"
    echo "Список находится в ~/.dotfiles/abortedPkg.txt"
  elif [ "$1" = "delete" ] && [ -e "$abortedPkgFile" ]; then
    rm -i "$abortedPkgFile"
  fi

}

createStowPkgDir () {

  if [ "$typePackageDir" = "full" ]; then

    mkdir "$dotfiles"/"$namePackage"
    packageDir="$dotfiles"/"$namePackage"

  elif [ "$typePackageDir" = "noFolding" ]; then 

    mkdir "$dotfiles"/"_$namePackage" 
    packageDir="$dotfiles"/"_$namePackage"

  fi
}

selectFile () {
  
  echo "Выбери оригинальный файл или директорию для копирования:"

  select file in ${files[@]}; do 
      createStowPkgDir
      
      if [ -d "$file" ]; then

        packageFirstSymbol=${packageDir:30:1}

        if [ "$packageFirstSymbol" = "_" ]; then
          vifm --select "$file" --on-choose "cp -r %f $packageDir" 
        else
          cp -r "$file" "$packageDir" 
        fi
      
      elif [ -f "$file" ]; then

        cp -r "$file" "$packageDir"

      fi

      return
  done
}

selectDir () {

  if [ "$choiseDir" = "home" ]; then

      choiseDir="$HOME"
      readarray files -t < <(ls -lA -d $choiseDir/* | grep -v -f "$patternsHomeDir" | awk '{ print $9 }' | sed '/^[[:space:]]*$/d')

      if [ "$files" = "" ]; then
        echo "Массив files пустой! Выход..."
        exit
      fi

  elif [ "$choiseDir" = "config" ]; then 

      choiseDir="$XDG_CONFIG_HOME"
      readarray files -t < <(ls -lA -d $choiseDir/* | awk '{ print $9 }' | sed '/^[[:space:]]*$/d')
      
      if [ "$files" = "" ]; then
        echo "Массив files пустой! Выход..."
        exit
      fi
  fi

}

selectType () {

  echo "Выбери тип нового пакета:"
  echo -e " - full - это полная копия оригинального пакета;\n - noFolding - частичная копия"
  select choiseType in full noFolding; do 

      if [ "$choiseType" = "full" ]; then
          
          typePackageDir="full"

      elif [ "$choiseType" = "noFolding" ]; then

          typePackageDir="noFolding"

      fi
  
      return
  done

}


addPackage () {

  while :
  do
    read -r -p "Введи название нового пакета в ~/.dotfiles: " namePackage
    
	  if [ -d "$dotfiles"/"$namePackage" ]; then
      echo "Пакет уже существует! Выбери другое название."

      continue
    fi
  
  break
  done

  echo "Оригинальный файл для копии находится в home или .config директории?"
      select choiseDir in home config; do 
          case "$choiseDir" in
              home)
                selectDir "$choiseDir"              
                selectType 
                selectFile

                break 
                ;;

              config)
                selectDir "$choiseDir"              
                selectType
                selectFile

                break 
                ;;

              *)
                echo "Invalid option... Выход"
			          exit
			          ;;
          esac
      done

  echo "Готово!"
}

createDefaultDirs () {
  mkdir $HOME/{downloads,images,projects,torrents,video,shotcut,music}

  mkdir $HOME/video/{all-videos,translated-videos}
}

rewriteAbortedPackage () {
  select package in ${stowPkgs[@]}; do 

    setStatusE true
    
    packageFirstSymbol=${package:0:1}

    if [ "$packageFirstSymbol" = "_" ]; then

      stow -d "$dotfiles" --no-folding -nvt ~ "$package" | awk  '{ print $11 }' | sed '/^[[:space:]]*$/d'
      
      if [ $? -eq 1 ]; then

        setStatusE false
        read -r -p "Перезаписать оригинальный пакет?" answer

      fi

    else
        
      stow -d "$dotfiles" -nvt ~ "$package" | awk  '{ print $11 }' | sed '/^[[:space:]]*$/d'

      if [ $? -eq 1 ]; then
        
        setStatusE false
        read -r -p "Перезаписать оригинальный пакет?" answer
        
        select answer in Yes No; do

           if [ "$answer" = "Yes" ]; then

            stow -d "$dotfiles" --adopt -vt ~ "$package" 

          elif [ "$answer" = "No" ]; then

            echo "Выход..."
            exit

          fi

        done
      fi
    fi
    
   
    echo "Файл успешно перезаписан!"
  done
}

startSetup () {
  abortedPkg "delete"

  select event in Yay Stow StowUpdate AddPackage CreateDefaultDirs; do
      case $event in
		    Yay)
          source "$dirArchIsoFiles"/yaySetupPkg.sh

          break
			    ;;

        Stow)
          cloneDotfiles
          readArrays
          stowPkgExtract

			    break
			    ;;

        StowUpdate)
          readArrays
          stowUpdateNoFoldingPkg
          
          break 
          ;;

        AddPackage)
          addPackage

          break 
          ;;

        CreateDefaultDirs)
          createDefaultDirs

          break 
          ;;

        AdoptPackage)
          readArrays
          rewriteAbortedPackage 

          break
          ;;

        *)
			    echo "Invalid option... Выход"
			    exit
			    ;;
      esac
  done
 
  abortedPkg
}

# Установка
startSetup
