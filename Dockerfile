FROM debian:9
MAINTAINER Stefan Reuter <docker@reucon.com>

ENV DEBIAN_FRONTEND noninteractive

RUN set -xe \
    && mkdir -p /var/log/supervisor /usr/lib/unifi/data \
    && touch /usr/lib/unifi/data/.unifidatadir \
    && apt-get update -q -y \
    && apt-get install -q -y \
       gnupg2 \
    && echo deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti > /etc/apt/sources.list.d/100-unifi.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50 \
    && apt-get update -q -y \
    && apt-get install -q -y \
       dumb-init \
       mongodb-server \
       unifi \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

VOLUME /usr/lib/unifi/data

# unifi.http.port=8080 (port for UAP to inform controller)
# unifi.https.port=8443 (port for controller GUI / API, as seen in web browser)
# portal.http.port=8880 (port for HTTP portal redirect)
# portal.https.port=8843 (port for HTTPS portal redirect)
# unifi.db.port=27117 (local-bound port for DB server)
EXPOSE 8080 8443 8880 8843 27117 443 80
WORKDIR /usr/lib/unifi
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["java", "-Xmx256M", "-Djava.net.preferIPv4Stack=true", "-jar", "/usr/lib/unifi/lib/ace.jar", "start"]
