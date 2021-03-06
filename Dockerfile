# =============================================================================
# cetres/centos-apache-php
#
# CentOS-7, Apache 2.4, PHP 5.6
#
# =============================================================================
FROM centos:centos7
MAINTAINER Gustavo Oliveira <cetres@gmail.com>

# -----------------------------------------------------------------------------
# Import the RPM GPG keys for Repositories
# -----------------------------------------------------------------------------
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# -----------------------------------------------------------------------------
# Apache + (PHP 5.6 from https://webtatic.com)
# -----------------------------------------------------------------------------
RUN  yum --setopt=tsflags=nodocs -y update && \
     yum --setopt=tsflags=nodocs -y install \
        httpd \
        php56w \
        php56w-common \
        php56w-devel \
        php56w-mysql \
	php56w-mbstring \
	php56w-soap \
	php56w-gd \
        php56w-ldap \
        php56w-mssql \
        php56w-pear \
        php56w-pdo \
	php56w-intl \
	php56w-xml \
        php56w-pecl-xdebug \
        libaio

RUN yum clean all

# -----------------------------------------------------------------------------
# Install Oracle drivers
#
# Oracle clients need to be downloaded in oracle path
# -----------------------------------------------------------------------------
RUN mkdir -p /usr/lib/oracle/11.2/client64/lib/
ADD oracle/libclntsh.so.11.1.gz /usr/lib/oracle/11.2/client64/lib/
RUN gunzip /usr/lib/oracle/11.2/client64/lib/libclntsh.so.11.1.gz
ADD oracle/libnnz11.so.gz /usr/lib/oracle/11.2/client64/lib/
RUN gunzip /usr/lib/oracle/11.2/client64/lib/libnnz11.so.gz
ADD oracle/libocci.so.11.1.gz /usr/lib/oracle/11.2/client64/lib/
RUN gunzip /usr/lib/oracle/11.2/client64/lib/libocci.so.11.1.gz
RUN ln -s /usr/lib/oracle/11.2/client64/lib/libclntsh.so.11.1 /usr/lib/oracle/11.2/client64/lib/libclntsh.so
RUN ln -s /usr/lib/oracle/11.2/client64/lib/libocci.so.11.1 /usr/lib/oracle/11.2/client64/lib/libocci.so
RUN echo "/usr/lib/oracle/11.2/client64/lib" > /etc/ld.so.conf.d/oracle.conf
RUN ldconfig

ADD oracle/oci8.so /usr/lib64/php/modules/
RUN echo "extension=oci8.so" > /etc/php.d/oci8.ini

ADD oracle/pdo_oci.so /usr/lib64/php/modules/
RUN echo "extension=pdo_oci.so" > /etc/php.d/pdo_oci.ini

RUN sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf

# -----------------------------------------------------------------------------
# Set ports and env variable HOME
# -----------------------------------------------------------------------------
EXPOSE 8080
ENV HOME /var/www

# -----------------------------------------------------------------------------
# Start
# -----------------------------------------------------------------------------
CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
