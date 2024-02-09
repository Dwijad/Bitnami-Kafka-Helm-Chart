#!/usr/bin/env bash
############### Parameters ###############
PASSWORD='password'
VALIDITY=730
KAFKA_BROKER_COUNT=3
###############  Existing certs Cleanup ###############
rm -rf ./certs && mkdir certs
cd certs
 
###############  Creating sslconfig file for CA ###############
cat > "openssl.cnf" << EOF
[req]
default_bits = 4096
encrypt_key  = no # Change to encrypt the private key using des3 or similar
default_md   = sha256
prompt       = no
utf8         = yes
# Specify the DN here so we aren't prompted (along with prompt = no above).
distinguished_name = req_distinguished_name
# Extensions for SAN IP and SAN DNS
req_extensions = v3_req
# Be sure to update the subject to match your organization.
[req_distinguished_name]
C  = IN
ST = KA
L  = Bengaluru
O  = Organization
OU = OrganizationUnit/emailAddress=my@email.com
CN = Kafka-Security-CA
# Allow client and server auth. You may want to only allow server auth.
# Link to SAN names.
[v3_req]
basicConstraints     = CA:TRUE
subjectKeyIdentifier = hash
keyUsage             = digitalSignature, keyEncipherment
extendedKeyUsage     = clientAuth, serverAuth
EOF
###############  Creating CA with above config  ###############
openssl req -new -x509 -keyout ca.key -out ca.crt -days $VALIDITY -config openssl.cnf
 
#################################################
########### Server Certificates #################
#################################################
 
 
###############  Generate certificates for each broker  ###############
for i in `seq 0 $(( $KAFKA_BROKER_COUNT-1))`; do
echo Generating for kafka $i
 
###############  Create certificate and store in keystore  ###############
keytool -keystore mtls-kafka-$i.keystore.jks -alias mtls-kafka-$i -validity $VALIDITY -genkey -keyalg RSA -ext SAN=dns:mtls-kafka-$i.mtls-kafka-headless.axplatform.svc.cluster.local,dns:mtls-kafka.mtls-kafka-headless.axplatform.svc.cluster.local,dns:mtls-kafka-$i.mtls-kafka-headless,dns:mtls-kafka-$i.mtls-kafka-headless.axplatform,dns:mtls-kafka-$i.mtls-kafka-headless,dns:mtls-kafka -storepass ${PASSWORD} -noprompt -dname "CN=mtls-kafka-$i.mtls-kafka-headless, OU=OrganizationUnit, O=Organization, L=Bengaluru, S=Karnataka, C=IN"
 
###############  Create certificate signing request(CSR)  ###############
keytool -keystore mtls-kafka-$i.keystore.jks -alias mtls-kafka-$i -certreq -file ca-request-mtls-kafka-$i -storepass ${PASSWORD} -noprompt
 
###############  Create ssl config file with DNS names anf other params  ###############
cat > ext$i.cnf << EOF
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = mtls-kafka-$i.mtls-kafka-headless.axplatform.svc.cluster.local
DNS.2 = mtls-kafka-$i.mtls-kafka-headless
DNS.3 = mtls-kafka-$i.mtls-kafka-headless.axplatform
DNS.4 = mtls-kafka.mtls-kafka-headless
DNS.5 = mtls-kafka
EOF
 
###############  Sign CSR with CA  ###############
openssl x509 -req -CA ca.crt -CAkey ca.key -in ca-request-mtls-kafka-$i -out ca-signed-mtls-kafka-$i -days $VALIDITY -CAcreateserial -extfile ext$i.cnf
 
###############  Import CA certificate in keystore   ###############
keytool -keystore mtls-kafka-$i.keystore.jks -alias ca.crt -import -file ca.crt -storepass ${PASSWORD} -noprompt
 
###############  Import Signed certificate in keystore   ###############
keytool -keystore mtls-kafka-$i.keystore.jks -alias mtls-kafka-$i -import -file ca-signed-mtls-kafka-$i -storepass ${PASSWORD} -noprompt
done
 
###############  Import CA certificate in truststore   ###############
keytool -keystore kafka.server.truststore.jks -alias CARoot -import -file ca.crt -storepass $PASSWORD -keypass $PASSWORD -noprompt
 
#################################################
########### Client Certificates #################
#################################################
 
###############  Create certificate and store in keystore  ###############
keytool -keystore mtls-kafka-client.keystore.jks -alias mtls-kafka-client -validity $VALIDITY -genkey -keyalg RSA -ext SAN=dns:mtls-kafka-client -storepass ${PASSWORD} -noprompt -dname "CN=mtls-kafka-client, OU=OrganizationUnit, O=Organization, L=Bengaluru, S=Karnataka, C=IN"
 
###############  Create certificate signing request(CSR)  ###############
keytool -keystore mtls-kafka-client.keystore.jks -alias mtls-kafka-client -certreq -file ca-request-mtls-kafka-client -storepass ${PASSWORD} -noprompt
 
###############  Create ssl config file with DNS names anf other params  ###############
cat > extclient.cnf << EOF
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = mtls-kafka-client
EOF
 
###############  Sign CSR with CA  ###############
openssl x509 -req -CA ca.crt -CAkey ca.key -in ca-request-mtls-kafka-client -out ca-signed-mtls-kafka-client -days $VALIDITY -CAcreateserial -extfile extclient.cnf
 
###############  Import CA certificate in keystore   ###############
keytool -keystore mtls-kafka-client.keystore.jks -alias ca.crt -import -file ca.crt -storepass ${PASSWORD} -noprompt
 
###############  Import Signed certificate in keystore   ###############
keytool -keystore mtls-kafka-client.keystore.jks -alias mtls-kafka-client -import -file ca-signed-mtls-kafka-client -storepass ${PASSWORD} -noprompt
 
###############  Import CA certificate in truststore   ###############
keytool -keystore kafka.client.truststore.jks -alias CARoot -import -file ca.crt -storepass $PASSWORD -keypass $PASSWORD -noprompt
