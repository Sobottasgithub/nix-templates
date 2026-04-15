#!/usr/bin/env bash

name=$1

if [[ -z "$name" ]]; then
  name = "latex-template"
fi

latexmk -pdf -shell-escape -pdflatex="pdflatex -interaction=nonstopmode" -jobname=$name  main.tex
