#!/bin/bash
PULSE_OX_TTY=$1
DEST_FILE=$2
if [ -z "$PULSE_OX_TTY" -o -z "$DEST_FILE" ]; then 
  echo "usage: read_pulse_ox <pulse_ox_tty_dev> <dest_file>"
  exit
fi
sudo cat $PULSE_OX_TTY >> $DEST_FILE
