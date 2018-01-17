FROM ubuntu:latest
MAINTAINER xavier@rootshell.be

RUN apt-get update && apt-get -y -q install tcpdump cron logrotate openssh-client supervisor
RUN rm -rf /var/lib/apt/lists/*

RUN touch /.firstboot

COPY entrypoint.sh /
COPY pcap_transfer.sh /
RUN chmod a+x /entrypoint.sh /pcap_transfer.sh

VOLUME  [ "/data" ]
ENTRYPOINT [ "/entrypoint.sh" ]
