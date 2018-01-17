#!/bin/bash

SCP_ARGUMENTS=$1
SCP_TARGET=$2
find /data -name "*.pcap" -mmin +5 -print | while read PCAP_FILE
do
        scp -q $SCP_ARGUMENTS $PCAP_FILE $SCP_TARGET && rm $PCAP_FILE && echo "Successfully exported $PCAP_FILE"
done
