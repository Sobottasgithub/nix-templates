#!/usr/bin/env bash

name="latex-template"

if [[ -z "$1" ]]; then
  name=$1
fi

if [ ! -d "./result" ]; then
  echo "./result not found! Creating folder..."
  mkdir build
fi

latexmk -pdf -shell-escape -pdflatex="pdflatex -interaction=nonstopmode" -jobname=$name -outdir=result main.tex
