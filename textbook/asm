#!/bin/sh

FILE=${1:?"Source file required: ./asm FILE"}
ROOT=$(echo $FILE | sed 's/\.\w*$//g')

yasm -g dwarf2 -f elf64 -l "$ROOT.lst" -o "$ROOT.o" "$FILE"
ld -g -o "$ROOT" "$ROOT.o"
