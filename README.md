"Glue code" for reading stats off of a Massimo Rad 8 pulse oximeter and pushing them to elasticsearch to view them in Grafana.

[![YouTube video showing my setup in action](https://img.youtube.com/vi/t2B6XVP6vvs/0.jpg)](https://www.youtube.com/watch?v=t2B6XVP6vvs)

https://youtu.be/t2B6XVP6vvs

## Caveats:

These scripts are pretty rough (e.g. a few assumptions, unnecessarily writing data to disk, not very resilient) and are more intended to serve as an example.

## Connecting to your Massimo Rad 8 pulse ox

You will need a serial-to-USB cable. I used a Sabrent CB-DB9P USB 2.0 to Serial (9-Pin) DB-9 RS-232 Converter Cable. Keep in mind when you buy: I have heard reports of the serial end being too bulky preventing a good connection to the pulse ox serial port.

If you connect that cable between the Rad8 and your microcomputer, it should get mounted at /dev/ttyUSB0 (or similar).

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
$ ./create_index_and_mappings.sh my-childs-med-data server-running-elasticsearch:9200

# after you've plugged in your pulse ox via a serial-to-USB cable
$ ./read_pulse_ox.sh /dev/ttyUSB0 ~/data.out

# start piping data to elasticsearch
$ ./tail_log_file_and_curl.sh ~/data.out
```
## Setting up Grafana:

Follow the instructions for setting up Grafana -- currently at http://docs.grafana.org/install/.

For your datasource, find/follow the instructions for elasticsearch.

Once you've set up Grafana, go to the Grafana URL in your browser (probably something like http://192.168.1.5:3000, where the 192.168.1.5 is the IP address of the computer running Grafana). Click log in.

Select Dashboards > Import and click the "Choose File" button under "Import File."

Load up the sample-grafana-dashboard.json file I included with this project.


***IMPORTANT:*** this dashboard is not an equivalent replacement for the Massimo Rad8 itself! The Rad 8 is a certified lifesaving medical device. Use this dashboard to extend visibility and tracking, but do not rely on it in the way you would depend on the Massimo itself, as it is not "failsafe" and could fail in any number of places (e.g the remote device reading the stats, the server hosting elasticsearch, elasticsearch itself, grafana, your web browser, or the web client).

***ADDITIONAL CAVEAT:*** the "current" SPO2 and HR values in my sample dashboard are intended to match the values on the Massimo Rad 8 itself. Thus, they average over an 8-second period. However, they are actually on a 30 second delay. This is because over time, the internal clock of the pulse ox gets slightly off. Every few weeks to months or so you may need to enter the settings of the pulse ox and update the clock. Otherwise, even if all your computing devices have their times synced up via an online time server, you may start to see a weird "delay" in the numbers posting.

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
    /root/pulseox/tail_log_file_and_curl.sh /dev/ttyUSB0 192.168.1.6:9200
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
- If data stops displaying properly in Grafana around the time of daylight savings time changes, going into the settings on your pulse ox (see above for Massimo Rad8 instructions) and changing the hour manually should bring things back into alignment.

## Understanding the Massimo's ALARM codes ##

From the Massimo Rad 8 User Manual (http://www.ontvep.ca/pdf/Masimo-Rad-8-User-Manual.pdf):

   ```
   Trend Data format
   The exceptions are displayed as a 3 digit, ASCII encoded, hexadecimal
   value. The binary bits of the hexadecimal value are encoded as follows:
   000 = Normal operation; no exceptions
   001 = No Sensor
   002 = Defective Sensor
   004 = Low Perfusion
   008 = Pulse Search
   010 = Interference
   020 = Sensor Off
   040 = Ambient Light
   080 = Unrecognized Sensor
   100 = reserved
   200 = reserved
   400 = Low Signal IQ
   800 = Masimo SET. This flag means the algorithm is running in full
   SET mode. It requires a SET sensor and needs to acquire some
   clean data for this flag to be set
   ```

Correlating the above exceptions to the actual ALARM or EXC codes from your Massimo Rad8 requires a little close reading and mathematical thinking. Let's look at some example data.

Here is a sampling of over 2 million ALARM data points from over two months of collection from my son's Massimo Rad8:

ALARM | # times appeared
-----------|------------
 000 | 2 Mil
 020 | 56 K
 032 | 3 K
 010 | 2K
 012 | 1K
 030 | 726
 03a | 623
 038 | 184
 018 | 10
 01a | 9
 014  | 8
 034 | 1

Based on these numbers, it makes sense that ALARM=000 means "Normal operation", aALARM=020 means "Sensor Off" (our most common alarm situation), and ALARM=010 would mean "Interference" (another seemingly common occurrence). However, values like 032, 03a, etc don't appear in the above table. What gives?

Re-reading the description above, I note that it says "the binary bits of the hexadecimal value are encoded." Notice as well that each of the hex values in the table from the manual correspond to a single bit in an 12-digit binary string:

ALARM | HEX | BINARY
-----------|--------|------------
Normal  | 000 | 0000 0000 0000
No sensor  | 001 | 0000 0000 0001
Defective   | 002 | 0000 0000 0010
Low Perf  | 004 | 0000 0000 0100
Pulse Search  | 008 | 0000 0000 1000
Interference  | 010 | 0000 0001 0000

And so on.

The power of this scheme is that any combination of alarms can be represented in a single hexadecimal number, because any of the hexadecimal values in their table can be summed with any other values to create a totally unique sum. That unique sum can then be decomposed back into only one possible set of sums. For example:

Example: | Sum | = | Code 1 | + | Code 2 | + | Code 3 | + | Code 4
-----|----|----|----|----|----|----|----|----|---
In HEX: | 03a | = | 020 | + | 010 | + | 008 | + | 002 
In binary: | 0011 1010 | = | 0010 0000 | + | 0001 0000 | + | 0000 1000 | + | 0000 0010 

(Note that I've dropped the leading 0000 from each of the binary values to keep the entries from wrapping. But check the math -- it works!)

Using this approach, the other alarms from my son's data can be decoded as follows:

ALARM | CODES | INTERPRETATION
-----------|------------|--------
032 | 020 + 010 + 002 | Sensor Off + Interference + Defective Sensor
012 | 010 + 002 | Interference + Defective Sensor
030 | 020 + 010 | Sensor Off + Interference
03a | 020 + 010 + 008 + 002 | Sensor Off + Interference + Pulse Search + Defective Sensor
038 | 020 + 010 + 008 | Sensor Off + Interference + Pulse Search

## Additional tips: ##

I am using https://github.com/rocketinventor/web-page-screensaver to bring the default medical monitoring dashboard up on the screen of the computer in my son's room. I also set one corner of the screen as a "hot corner" to activate the screensaver,so that any of my son's caregivers can quickly bring the Grafana monitoring dashboard back up.

Currently our setup is only visible within our home network. However, another parent told me about http://www.no-ip.com -- a free service which sjould let me access our server from outside my home network.

## Credit where credit is due:

Inspired by http://www.instructables.com/id/Pulse-Oximeter-Data-Capture-with-Raspberry-Pi/

Massimo alarm codes from nmenon at https://github.com/nmenon/masimo-datacapture/blob/master/masimo-capture.py#L249

View my setup at https://youtu.be/t2B6XVP6vvs

Questions? Comments? Please contact me!


