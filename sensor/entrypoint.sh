#!/bin/bash
#
# Start the FPC sensor (tcpdump + socat)
#
if [ -z "$PCAP_INTERFACE" ]; then
	export PCAP_INTERFACE=any
fi

if [ -z "$PCAP_SNAPLEN" ]; then
	export PCAP_SNAPLEN=0
fi

if [ -z "$PCAP_BPF_FILTER" ]; then
	export PCAP_BPF_FILTER=""
fi

# Generate a self-signed certificate for Socat
openssl genrsa -out /sensor.key 1024
openssl req -new \
        -key /sensor.key \
        -x509 \
        -days 365 \
        -subj "/C=BE/ST=Brussels/L=Brussels/O=SOC/CN=fpc-sensor" \
        -out /sensor.crt
cat /sensor.key /sensor.crt >/sensor.pem
chmod 600 /sensor.key /sensor.pem

while true
do
        echo "Sniffing packets on $PCAP_INTERFACE..."
        /usr/sbin/tcpdump -n -Z nobody -i $PCAP_INTERFACE -s $PCAP_SNAPLEN -w - $PCAP_BPF_FILTER \
		| /usr/bin/socat - OPENSSL:$INDEXER,cert=/sensor.pem,verify=0,forever,retry=10,interval=5
        echo "Restarting..."
done
