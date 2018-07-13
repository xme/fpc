# Full Packet Capture for the Masses
This is a simple framework to implement Full Packet Capture in a distributed way. The idea is to have the smaller footprint as possible on sensors.

The framework is based on two Docker containers:
- a Moloch server
- a sensor

The sensor collects traffic using tcpdump and uploads collected PCAP files to the central Moloch server via SCP.

SANSFire Edition:
Containers have been updated to use Socat and transfer PCAP data in realtime.
