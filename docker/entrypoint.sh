#!/usr/bin/env bash

set -e

#echo "entrypoint.sh \$1: $1"
if [ "$1" == "/opt/sonatype/start-nexus-repository-manager.sh" ]; then
    # SONATYPE_DIR=/opt/sonatype
    # NEXUS_HOME=${SONATYPE_DIR}/nexus
    # NEXUS_DATA=/nexus-data

    # Configure the repository manager itself to serve HTTPS directly
    if [ -f "${NEXUS_DATA}/keystore.jks" ]; then
        ln -s "${NEXUS_DATA}/keystore.jks" "${NEXUS_HOME}/etc/ssl/keystore.jks"
        sed -e "s|OBF.*|${JKS_PASSWORD}</Set>|g" \
            -i "${NEXUS_HOME}/etc/jetty/jetty-https.xml"
        sed -e "s|nexus-args=.*|nexus-args=\${jetty.etc}/jetty.xml,\${jetty.etc}/jetty-http.xml,\${jetty.etc}/jetty-requestlog.xml,\${jetty.etc}/jetty-https.xml,\${jetty.etc}/jetty-http-redirect-to-https.xml|g" \
            -i "${NEXUS_HOME}/etc/nexus-default.properties"
        grep -q "application-port-ssl" "${NEXUS_HOME}/etc/nexus-default.properties" || \
            sed -e "\|application-port|a\application-port-ssl=8443" -i "${NEXUS_HOME}/etc/nexus-default.properties"
    fi

    grep maxThreads ${NEXUS_HOME}/etc/jetty/jetty.xml

    bash /init_nexus3.sh &
    #exec su-exec nexus "$@"
    exec "$@"
else
    exec "$@"
fi
