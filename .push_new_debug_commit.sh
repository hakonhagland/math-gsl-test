#! /bin/bash

git status
git add .
datestr=$(LC_ALL=en_US.UTF-8 date)
git commit -m "DEBUG: $datestr"
git push origin master
