# Full Packet Capture for the Masses
This is a simple framework to implement Full Packet Capture in a distributed way.
The framework is based on two Docker containers:
- a Moloch server
- a sensor

Sensors can be easily deployed on hosts and have a very light footprint. The sensor collects traffic using tcpdump and uploads collected PCAP files to the central Moloch server via SCP.
