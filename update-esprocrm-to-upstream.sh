#!/bin/bash
cd ~/espocrm
git fetch upstream
git checkout master
git merge upstream/master
