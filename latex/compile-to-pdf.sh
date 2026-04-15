#!/usr/bin/env bash

name="latex-template"

if [[ -z "$1" ]]; then
  name=$1
fi

if [ ! -d "./build" ]; then
  echo "./build not found! Creating folder..."
  mkdir build
fi

latexmk -pdf -shell-escape -pdflatex="pdflatex -interaction=nonstopmode" -jobname=$name -outdir=build main.tex
