#!/bin/bash

cat "$1" | while read LINE; do
  ID=$(echo "$LINE" | sed 's/=/ /g' | awk '{print $1$2$4}' | sed 's/\///g' | sed 's/-//g' | sed 's/://g')
  #echo $ID
  JSON=$(echo "$LINE" | ./transform_pulse_ox_to_json_doc_for_es.sh)
  #echo $JSON
  curl --max-time 900 -X PUT "http://192.168.1.6:9200/max-med-test/rad8/$ID" -d "$JSON"
done
