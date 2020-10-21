#!/bin/bash 

#mdoc parse manual.mdoc --md && pandoc manual.md -o manual.pdf --template ./template

mdoc parse manual.mdoc -o manual.tex

xelatex manual.tex -pdf
