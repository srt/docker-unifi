FROM ubuntu:14.04
MAINTAINER Stefan Reuter <docker@reucon.com>

ENV DEBIAN_FRONTEND noninteractive
ENV VERSION 5.4.11

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init

RUN set -x \
    && chmod +x /usr/local/bin/dumb-init \
    && mkdir -p /var/log/supervisor /usr/lib/unifi/data \
    && touch /usr/lib/unifi/data/.unifidatadir \
    && echo deb http://www.ubnt.com/downloads/unifi/debian unifi5 ubiquiti > /etc/apt/sources.list.d/100-unifi.list \
    && echo deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen > /etc/apt/sources.list.d/100-mongo.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50 \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10 \
    && apt-get update -q -y \
    && apt-get install -q -y \
       mongodb-server \
       unifi

VOLUME /usr/lib/unifi/data

# unifi.http.port=8080 (port for UAP to inform controller)
# unifi.https.port=8443 (port for controller GUI / API, as seen in web browser)
# portal.http.port=8880 (port for HTTP portal redirect)
# portal.https.port=8843 (port for HTTPS portal redirect)
# unifi.db.port=27117 (local-bound port for DB server)
EXPOSE 8080 8443 8880 8843 27117 443 80
WORKDIR /usr/lib/unifi
ENTRYPOINT ["dumb-init"]
CMD ["java", "-Xmx256M", "-Djava.net.preferIPv4Stack=true", "-jar", "/usr/lib/unifi/lib/ace.jar", "start"]