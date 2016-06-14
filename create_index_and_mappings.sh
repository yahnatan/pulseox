#!/bin/ash
INDEXNAME=$1
HOSTNAME_AND_PORT=$2

if [ -z $INDEXNAME ]; then
  echo "usage:  create_index_and_mappings.sh <indexname> <host:9200>"
  exit
fi

if [ -z $HOSTNAME_AND_PORT ]; then
  echo "usage:  create_index_and_mappings.sh <indexname> <host:9200>"
  exit
fi

curl -XPUT "http://$HOSTNAME_AND_PORT/$INDEXNAME" -d '
{
"mappings": {
  "rad8": {
    "date_detection": false,
    "properties": {
      "time": {
        "type" : "date", "format" : "MM-dd-yy HH:mm:ss z" 
      }
    }
  }
}}'

