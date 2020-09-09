#!/bin/bash 
mdoc parse manual.mdoc --md && pandoc manual.md -o manual.pdf --template ./template --highlight-style=matlabHighlight.theme
