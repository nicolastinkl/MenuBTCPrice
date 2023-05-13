#!/bin/bash

git add .
date +%F > timefile
currentTime=$(<timefile)
git commit -m "Commit code. Update time: $currentTime "
git push


# this url is a very sample commant


