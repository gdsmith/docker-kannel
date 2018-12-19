FROM debian:jessie as main

RUN apt-get update && \
    apt-get -y remove ntpdate && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libhiredis-dev \
        libmysqlclient-dev \
        libpam0g-dev \
        libpcre3-dev \
        libpq-dev \
        libsqlite0-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        locales \
        openssl \
        supervisor

RUN locale-gen en_US && \
    locale-gen en_US.UTF-8

FROM main as build

RUN set -xe && \
    apt-get install -y --no-install-recommends \
        wget \
        subversion \
        cdbs \
        gnulib \
        dh-autoreconf \
        debhelper \
        sqlite \
        sqlite3 \
        freetds-dev \
        autoconf \
        automake1.11 \
        autotools-dev

ARG kannelRevision="r5272"

RUN set -xe && \
    cd /usr/local && \
    mkdir /usr/local/src/kannel && \
    cd /usr/local/src/kannel && \
    svn checkout -r $kannelRevision https://svn.kannel.org/gateway/trunk --trust-server-cert --non-interactive && \
    mv trunk gateway

RUN set -xe && \
    cd /usr/local/src/kannel/gateway && \
    ./bootstrap.sh && \
    ./configure \
        -enable-assertions \
        -enable-debug \
        -enable-localtime \
        -enable-pam \
        -enable-start-stop-daemon \
        -prefix=/usr/local/kannel \
        -with-defaults=speed \
        -with-mysql \
        -with-mysql-dir=/usr/lib/mysql/ && \
    make && make install && \

    cd /usr/local/src/kannel/gateway/addons/sqlbox && \
    ./bootstrap && \
    ./configure \
        -prefix=/usr/local/kannel \
        -with-kannel-dir=/usr/local/kannel && \
    make && make install && \

    cd /usr/local/src/kannel/gateway/addons/opensmppbox && \
    ./configure \
        -prefix=/usr/local/kannel \
        -with-kannel-dir=/usr/local/kannel && \
    make && make install

RUN set -xe && \
    mkdir -p /usr/local/kannel/lib/kannel/test && \
    cd /usr/local/src/kannel/gateway/test && \
    cp blacklist.txt /usr/local/kannel/lib/kannel/test/ && \
    cp bookmark.txt /usr/local/kannel/lib/kannel/test/ && \
    cp chartest.html /usr/local/kannel/lib/kannel/test/ && \
    cp decompile /usr/local/kannel/lib/kannel/test/ && \
    cp decompile.h /usr/local/kannel/lib/kannel/test/ && \
    cp dlr-receiver.py /usr/local/kannel/lib/kannel/test/ && \
    cp drive_smpp /usr/local/kannel/lib/kannel/test/ && \
    cp drive_smpp.conf /usr/local/kannel/lib/kannel/test/ && \
    cp drive_wapbox /usr/local/kannel/lib/kannel/test/ && \
    cp fakesmsc /usr/local/kannel/lib/kannel/test/ && \
    cp fakewap /usr/local/kannel/lib/kannel/test/ && \
    cp header_test /usr/local/kannel/lib/kannel/test/ && \
    cp hello.wml /usr/local/kannel/lib/kannel/test/ && \
    cp html-test-1 /usr/local/kannel/lib/kannel/test/ && \
    cp http2-test-urls /usr/local/kannel/lib/kannel/test/ && \
    cp iptestppg.txt /usr/local/kannel/lib/kannel/test/ && \
    cp mime-multipart.txt /usr/local/kannel/lib/kannel/test/ && \
    cp run-http2-tests.sh /usr/local/kannel/lib/kannel/test/ && \
    cp settings4.txt /usr/local/kannel/lib/kannel/test/ && \
    cp si.txt /usr/local/kannel/lib/kannel/test/ && \
    cp sl.txt /usr/local/kannel/lib/kannel/test/ && \
    cp smstestppg.txt /usr/local/kannel/lib/kannel/test/ && \
    cp test_boxc /usr/local/kannel/lib/kannel/test/ && \
    cp test_cfg /usr/local/kannel/lib/kannel/test/ && \
    cp test_charset /usr/local/kannel/lib/kannel/test/ && \
    cp test_cimd2 /usr/local/kannel/lib/kannel/test/ && \
    cp test_conn /usr/local/kannel/lib/kannel/test/ && \
    cp test_date /usr/local/kannel/lib/kannel/test/ && \
    cp test_dbpool /usr/local/kannel/lib/kannel/test/ && \
    cp test_dict /usr/local/kannel/lib/kannel/test/ && \
    cp test_file_traversal /usr/local/kannel/lib/kannel/test/ && \
    cp test_hash /usr/local/kannel/lib/kannel/test/ && \
    cp test_headers /usr/local/kannel/lib/kannel/test/ && \
    cp test_hmac /usr/local/kannel/lib/kannel/test/ && \
    cp test_http /usr/local/kannel/lib/kannel/test/ && \
    cp test_http_server /usr/local/kannel/lib/kannel/test/ && \
    cp test_list /usr/local/kannel/lib/kannel/test/ && \
    cp test_mem /usr/local/kannel/lib/kannel/test/ && \
    cp test_mime /usr/local/kannel/lib/kannel/test/ && \
    cp test_mime_multipart /usr/local/kannel/lib/kannel/test/ && \
    cp test_msg /usr/local/kannel/lib/kannel/test/ && \
    cp test_octstr_dump /usr/local/kannel/lib/kannel/test/ && \
    cp test_octstr_format /usr/local/kannel/lib/kannel/test/ && \
    cp test_octstr_immutables /usr/local/kannel/lib/kannel/test/ && \
    cp test_ota /usr/local/kannel/lib/kannel/test/ && \
    cp test_pap /usr/local/kannel/lib/kannel/test/ && \
    cp test_pcre /usr/local/kannel/lib/kannel/test/ && \
    cp test_pdu /usr/local/kannel/lib/kannel/test/ && \
    cp test_ppg /usr/local/kannel/lib/kannel/test/ && \
    cp test_prioqueue /usr/local/kannel/lib/kannel/test/ && \
    cp test_radius_acct /usr/local/kannel/lib/kannel/test/ && \
    cp test_radius_pdu /usr/local/kannel/lib/kannel/test/ && \
    cp test_regex /usr/local/kannel/lib/kannel/test/ && \
    cp test_si /usr/local/kannel/lib/kannel/test/ && \
    cp test_sl /usr/local/kannel/lib/kannel/test/ && \
    cp test_smsc /usr/local/kannel/lib/kannel/test/ && \
    cp test_store_dump /usr/local/kannel/lib/kannel/test/ && \
    cp test_udp /usr/local/kannel/lib/kannel/test/ && \
    cp test_urltrans /usr/local/kannel/lib/kannel/test/ && \
    cp test_uuid /usr/local/kannel/lib/kannel/test/ && \
    cp test_wakeup /usr/local/kannel/lib/kannel/test/ && \
    cp test_xmlrpc /usr/local/kannel/lib/kannel/test/ && \
    cp testcase.wml /usr/local/kannel/lib/kannel/test/ && \
    cp timestamp /usr/local/kannel/lib/kannel/test/ && \
    cp udpfeed /usr/local/kannel/lib/kannel/test/ && \
    cp wapproxy /usr/local/kannel/lib/kannel/test/ && \
    cp whitelist.txt /usr/local/kannel/lib/kannel/test/ && \
    cp wml_tester /usr/local/kannel/lib/kannel/test/

FROM main

RUN  set -xe && \
    mkdir /etc/kannel && \
    mkdir /var/log/kannel && \
    mkdir /var/log/kannel/{gateway,smsbox,wapbox,smsc,sqlbox,smppbox} && \
    mkdir /var/spool/kannel && \
    chmod -R 755 /var/spool/kannel && \
    chmod -R 755 /var/log/kannel

COPY --from=build /usr/local/kannel /usr/local/kannel
COPY --from=build /usr/local/src/kannel/gateway/gw/smskannel.conf /etc/kannel/kannel.conf
COPY --from=build /usr/local/src/kannel/gateway/debian/kannel.default /etc/default/kannel
COPY --from=build /usr/local/src/kannel/gateway/addons/sqlbox/example/sqlbox.conf.example /etc/kannel/sqlbox.conf
COPY --from=build /usr/local/src/kannel/gateway/addons/opensmppbox/example/opensmppbox.conf.example /etc/kannel/opensmppbox.conf
COPY --from=build /usr/local/src/kannel/gateway/addons/opensmppbox/example/smpplogins.txt.example /etc/kannel/smpplogins.txt

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD kannel.conf /etc/kannel/kannel.conf
ADD opensmppbox.conf /etc/kannel/opensmppbox.conf

EXPOSE 13013 13000 2346 13015

VOLUME ["/var/spool/kannel", "/etc/kannel", "/var/log/kannel"]

CMD ["/usr/bin/supervisord"]
