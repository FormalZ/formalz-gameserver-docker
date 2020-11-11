#!/usr/bin/env bash

#!/bin/bash
set -eo pipefail
[[ "${DEBUG}" == "true" ]] && set -x

old_ifs=$IFS
IFS=","
count=0;
hosts=""
for h in $FORMALZ_TRUSTED_PROXY_IPS; do
  separator=""
  if [[ $count -gt 0 ]]; then
    separator=","
  fi
  hosts="${hosts}${separator}\"${h}\""
  ((count=count+1))
done
IFS=$old_ifs

cat<<EOF > /app/settings.json
{
  "haskellTargetURL": "${FORMALZ_FCHECKER_URL}",
  "haskellPort"  : ${FORMALZ_FCHECKER_PORT},
  "haskellMethod": "${FORMALZ_FCHECKER_METHOD}",
  "haskellTimeout": ${FORMALZ_FCHECKER_TIMEOUT},

  "trustedProxyIps": [${hosts}],
  "workerThreadNumber": ${FORMALZ_WORKER_THREAD_NUMBER},

  "databaseDriver": "${FORMALZ_DB_DRIVER}",
  "databaseUsername": "${FORMALZ_DB_USERNAME}",
  "databasePassword": "${FORMALZ_DB_PASSWORD}",
  "databaseURLPrefix": "jdbc:mysql://",
  "databaseHostURL": "${FORMALZ_DB_HOST}",
  "databaseName": "${FORMALZ_DB_DATABASE}",
  "databaseUseSSL": false,
  "databaseURL": "${FORMALZ_DB_JDBC_URL}",
  "databaseMinPoolSize": ${FORMALZ_DB_MIN_POOL_SIZE},
  "databaseMaxPoolSize": ${FORMALZ_DB_MAX_POOL_SIZE},

  "connectionPort": ${FORMALZ_GAMESERVER_PORT},

  "tlsEnabled": ${FORMALZ_GAMESERVER_TLS_ENABLED},
  "serverStoreType": "JKS",
  "serverKeyStore": "${FORMALZ_GAMESERVER_KEY_STORE_PATH}",
  "serverStorePassword": "${FORMALZ_GAMESERVER_KEY_STORE_PASSWORD}",
  "serverKeyPassword": "${FORMALZ_GAMESERVER_KEY_PASSWORD}",

  "maxSessionCreatedDifference": ${FORMALZ_GAMESERVER_MAX_SESSION_CREATED_DIFFERENCE},
  "sessionWaitTime": ${FORMALZ_GAMESERVER_WAIT_TIME},

  "analyticsEnabled": ${FORMALZ_ANALYTICS_ENABLED},
  "analyticsServerHost": "${FORMALZ_ANALYTICS_SERVER_HOST}",
  "analyticsServerPort": ${FORMALZ_ANALYTICS_SERVER_PORT},
  "analyticsServerSecureConnection": ${FORMALZ_ANALYTICS_SERVER_SECURE}
}
EOF