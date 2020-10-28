#!/bin/bash 

#mdoc parse manual.mdoc --md && pandoc manual.md -o manual.pdf --template ./template

mdoc parse manual.mdoc.tex -o manual.tex

xelatex manual.tex -pdf
