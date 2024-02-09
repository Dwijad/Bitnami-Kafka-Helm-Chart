#!/bin/bash

set -e

openssl req -new -x509 -subj "/C=IN/ST=assam/L=guwahati/O=company/OU=unit/CN=ca" -keyout ca-key -out ca-cert -days 3650

keytool -noprompt -keystore ./kafka.truststore.jks -alias ca -import -file ca-cert -storepass password
#rm -f ca-cert

keytool -keystore ./kafka-broker-0.keystore.jks  -alias broker-0 -dname "CN=test-kafka-broker-0.test-kafka-broker-headless.default.svc.cluster.local,OU=unit,O=company,L=guwahati,S=assam,C=IN" -validity 3650 -genkey -keyalg RSA -storepass password
keytool -keystore ./kafka-broker-1.keystore.jks  -alias broker-1 -dname "CN=test-kafka-broker-1.test-kafka-broker-headless.default.svc.cluster.local,OU=unit,O=company,L=guwahati,S=assam,C=IN" -validity 3650 -genkey -keyalg RSA -storepass password
keytool -keystore ./kafka-broker-2.keystore.jks  -alias broker-2 -dname "CN=test-kafka-broker-2.test-kafka-broker-headless.default.svc.cluster.local,OU=unit,O=company,L=guwahati,S=assam,C=IN" -validity 3650 -genkey -keyalg RSA -storepass password


keytool -keystore ./kafka-broker-0.keystore.jks -alias broker-0 -certreq -file cert-file.broker-0 -storepass password
keytool -keystore ./kafka-broker-1.keystore.jks -alias broker-1 -certreq -file cert-file.broker-1 -storepass password
keytool -keystore ./kafka-broker-2.keystore.jks -alias broker-2 -certreq -file cert-file.broker-2 -storepass password


keytool -noprompt -keystore ./kafka.truststore.jks -export -alias ca -rfc -file ca-cert -storepass password

openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file.broker-0 -out cert-signed.broker-0 -days 3650 -CAcreateserial -extensions v3_req -extfile broker-0.conf
openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file.broker-1 -out cert-signed.broker-1 -days 3650 -CAcreateserial -extensions v3_req -extfile broker-1.conf
openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file.broker-2 -out cert-signed.broker-2 -days 3650 -CAcreateserial -extensions v3_req -extfile broker-2.conf


keytool -noprompt -keystore ./kafka-broker-0.keystore.jks -alias ca -import -file ca-cert -storepass password
keytool -noprompt -keystore ./kafka-broker-1.keystore.jks -alias ca -import -file ca-cert -storepass password
keytool -noprompt -keystore ./kafka-broker-2.keystore.jks -alias ca -import -file ca-cert -storepass password

keytool -noprompt -keystore ./kafka-broker-0.keystore.jks -alias broker-0 -import -file cert-signed.broker-0 -storepass password
keytool -noprompt -keystore ./kafka-broker-1.keystore.jks -alias broker-1 -import -file cert-signed.broker-1 -storepass password
keytool -noprompt -keystore ./kafka-broker-2.keystore.jks -alias broker-2 -import -file cert-signed.broker-2 -storepass password

