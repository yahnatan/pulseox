#!/bin/bash
LOGFILE=$1

if [ -z $LOGFILE ]; then
  echo "usage:  tail_log_file_and_curl.sh <logfile>"
  exit
fi

while sleep 1; do tail -n 3 $LOGFILE | ./transform_pulse_ox_to_json_doc_for_es.sh | ./curl_docs_to_es.sh && echo ""; done;

