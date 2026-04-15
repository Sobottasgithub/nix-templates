#!/usr/bin/env bash

name=$1

if [[ -z "$name" ]]; then
  name = "latex-template"
fi

if [ ! -d "./build" ]; then
  echo "./build not found! Creating folder..."
  mkdir build
fi

latexmk -pdf -shell-escape -pdflatex="pdflatex -interaction=nonstopmode" -jobname=$name -outdir=build main.tex
