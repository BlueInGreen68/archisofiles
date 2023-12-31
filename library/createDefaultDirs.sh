#!/bin/bash 

createDefaultDirs () {
  mkdir --verbose $HOME/{downloads,images,projects,torrents,video,shotcut,music}
  mkdir --verbose $HOME/video/{all-videos,translated-videos}
  echo "✅ Папки в домашней директории созданы!"
}

createDefaultDirs
