#!/bin/sh

yasm -f elf -g dwarf2  mul.asm
ld -m elf_i386 -o mul mul.o 
