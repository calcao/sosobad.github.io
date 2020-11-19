#!/bin/bash


set -e

rm -f index.md

for f in "$search_dir" *
do
  if [[ "$f" = "gen_index.sh" || "$f" = "index.md" || "$f" = "pic" || "$f" = "" ]];
  then
     continue
  fi
  echo "+ [${f%.*}](./$f)" >> index.md
done
