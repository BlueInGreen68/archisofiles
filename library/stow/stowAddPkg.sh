#!/bin/bash

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

stowCreatePkgDir () {

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
      stowCreatePkgDir
      
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

stowAddPkg () {
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

    if [ "$choiseDir" = "home" ] || [ "$choiseDir" = "config" ]; then
      selectDir "$choiseDir"              
      selectType 
      selectFile
    else 
      echo "Invalid option. Выбери один из предложенных вариантов!"
    fi

  done

  cd "$dotfiles"
  git add "$packageName"

  echo "Пакет добавлен!"
}

stowAddPkg
