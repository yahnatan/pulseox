#!/bin/bash

while read -r line
do
  ID=`echo $line | awk '{print $2$3}' | sed 's/-//g' | sed 's/://g' `
  curl -XPUT "http://127.0.0.1:9200/max-med-test/rad8/$ID" -d "$line"
done
