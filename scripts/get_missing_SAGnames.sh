#!/bin/bash

ls ../../data/Proteins/*.faa > SAGnames.txt
sed -i "s/_proteins.faa//g" SAGnames.txt
sed -i "s/..\/..\/data\/Proteins\///g" SAGnames.txt

ls $1 | xargs -n 1 basename > ProcessedNames.txt
sed -ir "s/_.*//g" ProcessedNames.txt

diff -y ProcessedNames.txt SAGnames.txt

