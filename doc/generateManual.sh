#!/bin/bash 

#mdoc parse manual.mdoc --md && pandoc manual.md -o manual.pdf --template ./template

mdoc parse manual.tex -o manual

xelatex manualDef.tex -pdf

mv manualDef.pdf manual.pdf


