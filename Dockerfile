FROM debian:jessie

ENV VERSION="1.5.0"

RUN apt-get update && \
    apt-get -y remove ntpdate && \
    apt-get install -y \
        autoconf \
        automake1.11 \
        autotools-dev \
        apt-utils \
        bison \
        build-essential \
        checkinstall \
        curl \
        cvs \
        debhelper \
        docbook \
        docbook-xsl \
        flex \
        g++ \
        gcc \
        git-core \
        intltool \
        libc6-dev \
        libmysql++-dev \
        libmysqlclient-dev \
        libncurses5-dev \
        libpam0g-dev \
        libpcre3 \
        libpcre3-dev \
        libssl-dev \
        libtool \
        libtool-bin \
        libxml2-dev \
        locales \
        m4 \
        nano \
        ntp \
        openssl \
        pkg-config \
        supervisor \
        tex-common \
        texi2html \
        texinfo \
        unzip \
        wget

RUN locale-gen en_US && \
	locale-gen en_US.UTF-8

RUN cd /usr/local && \
    mkdir /usr/local/src/kannel && \
    cd /usr/local/src/kannel && \
    wget --no-check-certificate http://www.kannel.org/download/${VERSION}/gateway-${VERSION}.tar.bz2 && \
    tar -xvf gateway-${VERSION}.tar.bz2 && \
    cd /usr/local/src/kannel/gateway-${VERSION} && \
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
    touch .depend && \
    make depend && \
    make && \
    make bindir=/usr/local/kannel install && \
    make bindir=/usr/local/kannel install-test && \
    cd /usr/local/src/kannel/gateway-${VERSION}/addons/sqlbox && \
    ./bootstrap && \
    ./configure \
        -prefix=/usr/local/kannel \
        -with-kannel-dir=/usr/local/kannel && \
    make && make bindir=/usr/local/kannel/sqlbox install && \
    cd /usr/local/src/kannel/gateway-${VERSION}/addons/opensmppbox && \
    ./configure \
        -prefix=/usr/local/kannel \
        -with-kannel-dir=/usr/local/kannel && \
    make && make bindir=/usr/local/kannel/smppbox install && \
    mkdir /etc/kannel && \
    mkdir /var/log/kannel && \
    mkdir /var/log/kannel/{gateway,smsbox,wapbox,smsc,sqlbox,smppbox} && \
    mkdir /var/spool/kannel && \
    chmod -R 755 /var/spool/kannel && \
    chmod -R 755 /var/log/kannel && \
    cp /usr/local/src/kannel/gateway-${VERSION}/gw/smskannel.conf /etc/kannel/kannel.conf && \
    cp /usr/local/src/kannel/gateway-${VERSION}/debian/kannel.default /etc/default/kannel && \
    cp /usr/local/src/kannel/gateway-${VERSION}/addons/sqlbox/example/sqlbox.conf.example /etc/kannel/sqlbox.conf && \
    cp /usr/local/src/kannel/gateway-${VERSION}/addons/opensmppbox/example/opensmppbox.conf.example /etc/kannel/opensmppbox.conf && \
    cp /usr/local/src/kannel/gateway-${VERSION}/addons/opensmppbox/example/smpplogins.txt.example /etc/kannel/smpplogins.txt && \
    rm -rf /usr/local/src/kannel/gateway-${VERSION} && \
    apt-get -y clean

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD kannel.conf /etc/kannel/kannel.conf
ADD opensmppbox.conf /etc/kannel/opensmppbox.conf

EXPOSE 13013 13000 2346 13015

VOLUME ["/var/spool/kannel", "/etc/kannel", "/var/log/kannel"]

CMD ["/usr/bin/supervisord"]
