"Glue code" for reading stats off of a Massimo Rad 8 pulse oximeter and pushing them to elasticsearch

## Caveats:

These scripts are pretty rough (e.g. a few assumptions, unnecessarily writing data to disk, not very resilient) and are more intended to serve as an example.

## Connecting to your Massimo Rad 8 pulse ox

You will need a serial-to-USB cable. If you connect that cable between the Rad8 and your microcomputer, it should get mounted at /dev/ttyUSB0 (or similar).

```
$ cat /dev/ttyUSB0
02/22/16 22:47:45 SN=0000056661 SPO2=098% BPM=097 PI=03.60% SPCO=--.-% SPMET=--.-% DESAT=-- PIDELTA=+-- ALARM=0000 EXC=000800

02/22/16 22:47:46 SN=0000056661 SPO2=098% BPM=096 PI=03.95% SPCO=--.-% SPMET=--.-% DESAT=-- PIDELTA=+-- ALARM=0000 EXC=000800

02/22/16 22:47:47 SN=0000056661 SPO2=098% BPM=096 PI=04.25% SPCO=--.-% SPMET=--.-% DESAT=-- PIDELTA=+-- ALARM=0000 EXC=000800

02/22/16 22:47:48 SN=0000056661 SPO2=098% BPM=096 PI=03.19% SPCO=--.-% SPMET=--.-% DESAT=-- PIDELTA=+-- ALARM=0000 EXC=000800

02/22/16 22:47:49 SN=0000056661 SPO2=098% BPM=097 PI=02.41% SPCO=--.-% SPMET=--.-% DESAT=-- PIDELTA=+-- ALARM=0000 EXC=000800
```
If after hooking up the Rad8 to your computer, you don't see any output, see below for troubleshooting tips.

## How to use:

```
# set up your elasticsearch index (run this one time)
$ ./create_index_and_mappings.sh my-kids-medical-data server-running-elasticsearch:9200

# after you've plugged in your pulse ox via a serial-to-USB cable
$ ./read_pulse_ox.sh /dev/ttyUSB0 ~/data.out

# start piping data to elasticsearch
$ ./tail_log_file_and_curl.sh ~/data.out
```

## Tips/Troubleshooting:

- If, after hooking up the serial port of your Rad8 to your input device, you don't see any output from the pulseox at /dev/ttyUSB0 (or similar), you may need to change the setting on your Rad8 serial port output from the default value of ASCII 2 to ASCII 1. From the Masimo Rad8 User Manual (available online if you do a Google search):

    ```
    To access Level 3 parameters/measurements, hold down the Enter Button 
    and press the Down Button for 5 seconds. After entering menu Level 3, 
    use the Up or Down button to move between settings.
    ```

    The setting you're looking for is Serial Output (SEr), and you want to change it to ASCII 1 (AS1).

    ***IMPORTANT:*** your child's pulse oximeter is a life-saving device. If you change the wrong setting inadvertently, you could seriously compromise the safety of your child and/or make yourself totally liable for the consequences. Don't change settings unless you're confident you know what you're doing.

- You will want to make these scripts run automatically at startup. On my Onion Omega, I did this by adding the following to /etc/rc.local:

    ```
    # Put your custom commands here that should be executed once
    # the system init finished. By default this file does nothing.
    cd /root/pulseox
    /root/pulseox/read_pulse_ox.sh /dev/ttyUSB0 /root/pulseox/data.out &
    /root/pulseox/tail_log_file_and_curl.sh /root/pulseox/data.out 192.168.1.6:9200
    exit 0
    ```
- You might need to change /bin/bash to point to /bin/ash if, for example, you're using an Onion Omega.
- You may want to set up a cron job to periodically clear out the on-disk data file (to avoid filling up your disk eventually), e.g.

    ```
    0 * * * * echo "" > /root/pulseox/data.out
    ```
- Sometimes the USB port will cut out unexpectedly. This is due to some sort of current override feature which is part of the USB spec. One way to fix this is to run the following command (and then reset your connection to /dev/ttyUSB0):

    ```
    $ rmmod ehci_platform && modprobe ehci-platform
    ``` 

## Credit where credit is due:

Inspired by http://www.instructables.com/id/Pulse-Oximeter-Data-Capture-with-Raspberry-Pi/

View my setup at https://youtu.be/t2B6XVP6vvs

Questions? Comments? Please contact me!


