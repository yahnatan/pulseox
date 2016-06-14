#!/bin/ash
DEST_FILE=$1
if [ ! -f $DEST_FILE -o ! -w $DEST_FILE ]; then 
  echo "usage: read_pulse_ox <dest_file>"
  exit
fi
cat /dev/ttyUSB0 >> $DEST_FILE
