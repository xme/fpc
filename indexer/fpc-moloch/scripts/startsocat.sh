#!/bin/bash
/usr/bin/socat OPENSSL-LISTEN:8443,reuseaddr,pf=ip4,fork,cert=/etc/socat.pem,verify=0 \
	SYSTEM:"tcpdump -n -r - -s 0 -G 50 -W 100 -w /data/pcap/dump-%Y%m%d%H%M%S.pcap not port 8443"
