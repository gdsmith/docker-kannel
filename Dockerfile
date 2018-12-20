FROM debian:jessie

RUN apt-get update && \
    apt-get install -y \
        kannel \
        kannel-extras \
        supervisor

RUN  set -xe && \
    mkdir /var/log/kannel/{gateway,smsbox,wapbox,smsc,sqlbox,smppbox} && \
    mkdir /var/spool/kannel && \
    chmod -R 755 /var/spool/kannel && \
    chmod -R 755 /var/log/kannel

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD kannel.conf /etc/kannel/kannel.conf

EXPOSE 13013 13000 2346 13015

VOLUME ["/var/spool/kannel", "/etc/kannel", "/var/log/kannel"]

CMD ["/usr/bin/supervisord"]
