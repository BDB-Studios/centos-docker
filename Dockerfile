FROM nimmis/centos
ARG  YUM_PACKAGES="python-setuptools wget dnsmasq unzip zip sudo git supervisor \
                   logrotate dpkg centos-release-scl scl-utils-build"
ARG RUBY_PACKAGES="rh-ruby23 rh-ruby23-ruby-devel rh-ruby23-rubygem-rake rh-ruby23-rubygem-bundler"
ARG SELINUX_PACKAGE="policycoreutils policycoreutils-python selinux-policy selinux-policy-targeted \
                     libselinux-utils setroubleshoot-server setools setools-console mcstrans"

RUN yum update -y; \
    yum clean all

RUN yum -y install epel-release; \
    yum clean all

RUN yum install -y ${YUM_PACKAGES}; \
    yum clean all;

RUN yum install -y ${RUBY_PACKAGES}; \
    yum clean all; \
    echo "source /opt/rh/rh-ruby23/enable" >> /etc/bashrc;

RUN yum install -y ${SELINUX_PACKAGE}; \
    yum clean all;

# Install gosu
ARG GOSU_VERSION="1.10"
RUN set -ex ;\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /tmp/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /tmp/gosu.asc /usr/bin/gosu; \
	rm -r "$GNUPGHOME" /tmp/gosu.asc; \
	chmod +x /usr/bin/gosu;

#Install confd templating system
ARG CONFD_VERSION="0.15.0"
ARG CONFD_URL="https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64"
RUN wget -O /usr/bin/confd ${CONFD_URL}; \
    chmod a+x /usr/bin/confd; \
    mkdir -p /etc/confd/conf.d; \
    mkdir -p /etc/confd/templates; \
    yum -y remove wget dpkg; \
    yum clean all; \
    rm -rf /var/cache/yum; \
    rm -rf /var/log/yum.log

ADD  docker/my_init.d /etc/my_init.d
RUN  chmod a+x /etc/my_init.d/*; \
     ln -s /etc/my_init.d/00_confd /etc/my_runonce/00_confd

LABEL os="centos", \
      version="7", \
      role="base"
