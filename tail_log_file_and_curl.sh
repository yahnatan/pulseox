#!/bin/bash
ACCESS_TOKEN="FILL_IN_YOUR_ACCESS_TOKEN_HERE"
APP_ID="FILL_IN_YOUR_APP_ID_HERE"

CURR_SPO2="100"
CURR_BPM="100"
tail -n0 -F "$1" | while read LINE; do
  # skip empty lines
  [ -z "$LINE" ] && continue

  ID=$(echo "$LINE" | sed 's/=/ /g' | awk '{print $1$2$4}' | sed 's/\///g' | sed 's/-//g' | sed 's/://g')
  #echo $ID
  JSON=$(echo "$LINE" | ./transform_pulse_ox_to_json_doc_for_es.sh)
  #echo $JSON
  curl --max-time 900 -X PUT "http://192.168.1.6:9200/max-medical/rad8/$ID" -d "$JSON" &

  SPO2_BPM=`echo $JSON | awk '{print $8" "$10}' | sed 's/,//g'`
  SPO2=`echo $SPO2_BPM | awk '{print $1}'`
  #echo "SPO2=_${SPO2}_"
  if [ "x$SPO2" != "x" ] && [ "x$SPO2" != "x$CURR_SPO2" ]; then
    curl --max-time 900 -X GET "https://graph.api.smartthings.com/api/token/$ACCESS_TOKEN/smartapps/installations/$APP_ID/spo2/$SPO2" &
    #echo "changing SPO2 _${SPO2}_ _${CURR_SPO2}_"
    CURR_SPO2=$SPO2
  fi

  BPM=`echo $SPO2_BPM | awk '{print $2}'`
  #echo "BPM=_${BPM}_"                                                                                                                                                          
  if [ "x$BPM" != "x" ] && [ "x$BPM" != "x$CURR_BPM" ]; then                                                                                                                    
    curl --max-time 900 -X GET "https://graph.api.smartthings.com/api/token/$ACCESS_TOKEN/smartapps/installations/$APP_ID/bpm/$BPM" &
    #echo "changing BPM _${BPM}_ _${CURR_BPM}_"                                                                                                                                      
    CURR_BPM=$BPM                   
  fi  
done
