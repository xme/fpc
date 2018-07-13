#!/bin/sh

MOLOCHDIR=/data/moloch

# set PATH
echo "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/data/moloch/bin\"" > /etc/environment

#source /etc/profile

if [ -r /.firstboot ]; then
	# Install the original config files
	mv /tmp/config.ini /data/moloch/etc
	mv /tmp/supervisor.conf /data/moloch/etc

	# set write permissions for moloch
	chmod a+rwx /data/moloch/raw /data/moloch/logs /data/moloch/data

	# wait for Elasticsearch
	echo "Giving ES time to start..."
	sleep 5
	until curl -sS 'http://elasticsearch:9200/_cluster/health?wait_for_status=yellow&timeout=5s'
	do
	    echo "Waiting for ES to start"
	    sleep 1
	done
	echo

	# intialize moloch
	echo INIT | /data/moloch/db/db.pl http://elasticsearch:9200 init
	/data/moloch/bin/moloch_add_user.sh admin "Admin User" THEPASSWORD --admin
	/data/moloch/bin/moloch_update_geo.sh

	rm /.firstboot
fi

echo "Starting viewer. Go with https to port 8005 of container."
/usr/bin/supervisord -c /data/moloch/etc/supervisor.conf
