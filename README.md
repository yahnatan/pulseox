"Glue code" for reading stats off of a Massimo Rad 8 pulse oximeter and pushing them to elasticsearch

Caveat: these scripts are pretty rough (e.g. a few assumptions, unnecesarily writing data to disk, not very resilient). I hope to clean them up later.

How to use:

# set up your elasticsearch index (run this one time)
$ ./create_index_and_mappings.sh my-kids-medical-data server-running-elasticsearch:9200

# after you've plugged in your pulse ox via a serial-to-USB cable
$ ./read_pulse_ox.sh /dev/ttyUSB0 ~/data.out

# start piping data to elasticsearch
$ ./tail_log_file_and_curl.sh ~/data.out

Troubleshooting:

- You might need to change /bin/bash to point to /bin/ash if, for example, you're using an Onion Omega.
- Sometimes the USB port will cut out unexpectedly. This is due to some sort of current override feature which is part of the USB spec. One way to fix this is to run the following command (and then reset your connection to /dev/ttyUSB0):

$ rmmod ehci_platform && modprobe ehci-platform

Credit where credit is due:

Inspired by http://www.instructables.com/id/Pulse-Oximeter-Data-Capture-with-Raspberry-Pi/

View my setup at https://youtu.be/t2B6XVP6vvs

Questions? Comments? Please contact me!


