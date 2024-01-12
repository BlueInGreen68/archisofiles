#!/bin/bash
# Скрипт для запуска cli программ с именованным заголовком из лаунчера

case "$1" in
  peaclock) 
    peaclock

    break
    ;;

  *)
    foot --title="$1" $1 

    break
    ;;
esac
