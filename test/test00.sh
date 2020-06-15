#!/bin/bash
python3 ~/Sync/python/workspace/mdoc/mdoc.py parse test00.mdoc -m -v

if diff test00.md test00_ans.md; then
  echo "Test okey!"
  rm test00.md
else
  echo "Error: test is not okey"
fi
