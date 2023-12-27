#!/bin/bash 

createDefaultDirs () {
  mkdir $HOME/{downloads,images,projects,torrents,video,shotcut,music}
  mkdir $HOME/video/{all-videos,translated-videos}
}

createDefaultDirs
