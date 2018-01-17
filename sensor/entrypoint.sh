#!/bin/bash
set -e
if [ -r /.firstboot ]; then
        if [ -z "$PCAP_INTERFACE" ]; then
                export PCAP_INTERFACE=any
        fi
        if [ -z "$PCAP_CAPTURE_SIZE" ]; then
                export PCAP_CAPTURE_SIZE=0
        fi
        if [ -z "$PCAP_FILE_SIZE" ]; then
                export PCAP_FILE_SIZE=1000
        fi
        if [ -z "$PCAP_FILE_ROTATE" ]; then
                export PCAP_FILE_ROTATE=100
        fi
        if [ -z "$PCAP_BPF_FILTER" ]; then
                export PCAP_BPF_FILTER=""
        fi
        if [ -z "$PCAP_SENSOR_NAME" ]; then
                # Generate random sensor name if none provided
                export PCAP_SENSOR_NAME="sensor-`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1`"
        fi
        if [ -z "$SCP_ARGUMENTS" ]; then
                export SCP_ARGUMENTS=""
        fi
        if [ -z "$SCP_TARGET" ]; then
                echo "[ERROR] No target specified for scp (\$SCP_TARGET)"
                exit 1
        fi

        # Generate a SSH keypair
        ssh-keygen -b 4096 -t rsa -q -N "" -f /root/.ssh/id_rsa
        if [ "$?" != "0" ]; then
                echo "[ERROR] SSH key generation failed"
                exit 1
        fi
        echo "Please use this key to allow PCAP files transfert via scp:"
        echo "--- Cut Here ---"
        cat /root/.ssh/id_rsa.pub
        echo "--- Cut Here ---"

        # Create the cronjob
        echo "*/5 * * * * root (/pcap_transfer.sh \"$SCP_ARGUMENTS\" \"$SCP_TARGET\" >>/var/log/cron.log 2>&1)" >/etc/cron.d/pcap
        chmod 0644 /etc/cron.d/pcap
        touch /var/log/cron.log

        # Create the supervisord.conf
        cat <<__CONFIG__ >/opt/supervisor.conf
[supervisord]
nodaemon=true

[group:pcap]
programs=pcap_tcpdump,pcap_cron

[program:pcap_tcpdump]
command=/usr/sbin/tcpdump -n -Z nobody -i $PCAP_INTERFACE -s $PCAP_CAPTURE_SIZE -G $PCAP_FILE_SIZE -W $PCAP_FILE_ROTATE $PCAP_BPF_FILTER -w /data/$PCAP_SENSOR_NAME-%%Y%%m%%d%
%H%%M.pcap
autorestart=true

[program:pcap_cron]
command=/usr/sbin/cron -f
autorestart=true
__CONFIG__
        chown nobody /data

	# Setup completed
	rm /.firstboot
fi

/usr/bin/supervisord -c /opt/supervisor.conf
