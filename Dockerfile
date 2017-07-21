FROM debian:9
MAINTAINER Stefan Reuter <docker@reucon.com>

ENV DEBIAN_FRONTEND noninteractive

# See https://www.ubnt.com/download/unifi/
ENV DUMB_INIT_VERSION 1.2.0

ADD https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 /usr/local/bin/dumb-init

RUN set -x \
    && chmod +x /usr/local/bin/dumb-init \
    && mkdir -p /var/log/supervisor /usr/lib/unifi/data \
    && touch /usr/lib/unifi/data/.unifidatadir \
    && apt-get update -q -y \
    && apt-get install -q -y \
       gnupg2 \
    && echo deb http://www.ubnt.com/downloads/unifi/debian unifi5 ubiquiti > /etc/apt/sources.list.d/100-unifi.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50 \
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
