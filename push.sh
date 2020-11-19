#!/bin/bash


set -e

rm -f index.md

for f in "$search_dir" *
do
  if [[ "$f" = "push.sh" || "$f" = "index.md" || "$f" = "pic" || "$f" = "" ]];
  then
     continue
  fi
  echo "+ [${f%.*}](./$f)" >> index.md
done

git status


git add .


git commit -m "$(date +%s)"


git push
