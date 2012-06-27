#!/bin/bash
for i in $(seq 4 1 12) 
do
  svn diff --summarize -r{"2010-$i-01"}:{"2010-$((i+1))-01"} . | grep --color=auto zlib | wc -l
done
