#!/usr/bin/env bash
# run this in the directory to create the project in

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# heuristic to check if the current directory is the same as where this script is, this is not allowed
if [ -e ./config ]; then echo 'Create a new directory for this'; exit 1; fi
ln -s "$DIR" ./shared
mkdir config/
#ln -sr ./shared/config/* config/
cp -r ./shared/config/* config/
mkdir input
ln -s ./shared/instructions.md README.md
ln -s ./shared/startshell.bash .
ln -s ./shared/run.bash .

