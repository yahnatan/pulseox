#!/bin/bash
INDEXNAME=$1

if [ -z $INDEXNAME ]; then
  echo "usage:  create_index_and_mappings.sh <indexname>"
  exit
fi

curl -XPUT "http://localhost:9200/$INDEXNAME" -d '
{
"mappings": {
  "rad8": {
    "date_detection": false,
    "properties": {
      "time": {
        "type" : "date", "format" : "MM-dd-yy HH:mm:ss"
      }
    }
  }
}}'

