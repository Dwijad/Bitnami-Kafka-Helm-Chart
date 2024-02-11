## Configure Bitnami Helm Chart

A simplified configuration of Bitnami kafka helm chart to quickly create a cluster in Kubernetes. It simplifies configuring kafka cluster  and avoids manually managing the complex service configuration from scratch.

### Get the chart

    $ helm repo add bitnami https://charts.bitnami.com/bitnami
    $ helm repo update
    $ helm pull bitnami/kafka
    $ tar xf kafka-26.8.5.tgz

### SSL

Create SSL certificates if the broker is intended to listen on SSL.  This [shell script](https://github.com/Dwijad/Bitnami-Kafka-Helm-Chart/blob/main/certs/generate_ssl_cert.sh) along with other configuration file will automate the process of creating SSL certs.  

    $ mkdir -p kafka/certs && cd kafka/certs
    $ Get/Place generate_ssl_cert.sh, broker-{n}.conf in kafka/certs

Edit `broker-{n}.conf` files to reflect the release name in DNS of each broker where n is the broker number.

    ...
    ...
    [ alt_names ]
    DNS.1 = {release_name}-kafka.default.svc.cluster.local
    DNS.2 = {release_name}-kafka-broker-0.test-kafka-broker-headless.default.svc.cluster.local

Generate SSL certificates. 

    $ ./generate_ssl_cert.sh

Another certification generation [shell script](https://github.com/confluentinc/confluent-platform-security-tools/blob/master/kafka-generate-ssl.sh) from confluent. 
 
### Configure chart
#### Zookeeper
The bitnami kafka helm chart comes with number of options. Kafka cluster can be configured with freshly minted Kraft/zookeeper service or with a existing  zookeeper service.

A Kafka cluster where a fresh zookeeper service is desired can be configured with the following parameters in `values.yaml` 

    kraft:
      enabled: false <--- Disabled Kraft
      existingClusterIdSecret: ""
      clusterId: ""
      controllerQuorumVoters: ""
    
    zookeeperChrootPath: ""
    zookeeper:
      enabled: true <--- Zookeeper enabled
      replicaCount: 3 <--- Zookeeper Replica count
      auth:
        client:
          enabled: false
          clientUser: ""
          clientPassword: ""
          serverUsers: ""
          serverPasswords: ""
      persistence:
        enabled: true <--- Enabled Persistence for zookeeper metadata
        storageClass: ""
        accessModes:
          - ReadWriteOnce
        size: 1Gi
    
    externalZookeeper:
      servers: []

#### Listener

Configure listener properties for client, external, interbroker and controller. If Kraft is disabled, controller listener properties does not need to be configured.

    listeners: <--- Listener section
      client: <--- Client
        containerPort: 9092
        protocol: SASL_SSL
        name: CLIENT
        sslClientAuth: "required"
    
      external: <--- External
        containerPort: 9095
        protocol: SASL_SSL
        name: EXTERNAL
        sslClientAuth: ""
    
      interbroker: <--- Interbroker
        containerPort: 9093
        protocol: PLAINTEXT
        name: INTERNAL
        sslClientAuth: ""
    
      controller: <--- Controller
        containerPort: 9094
        protocol: SASL_PLAINTEXT
        name: CONTROLLER
        sslClientAuth: ""

#### SASL

Configure SASL authentication for interbroker, client and controller communication in SASL section.

    sasl:
      enabledMechanisms: PLAIN,SCRAM-SHA-256,SCRAM-SHA-512
      interBrokerMechanism: PLAIN
      controllerMechanism: PLAIN
      interbroker:
        user: broker
        password: "password"
      controller:
        user: controller
        password: "password"
      client:
        users:
        - user1
        passwords: "password"

#### SSL

Kafka broker with SSL supports can be configured in `tls` section.

    tls:
      type: JKS <--- TLS type
      existingSecret: "kafka-jks"
      keystorePassword: "password"
      truststorePassword: "password"
      jksKeystoreKey: kafka-broker-0.keystore.jks
      jksTruststoreKey: kafka.truststore.jks

Make sure to create Kubernetes secret out of these JKS keystore and truststore certificates.

    $ kubectl create secret generic kafka-jks --from-file=kafka-broker-0.keystore.jks=./kafka-broker-0.keystore.jks --from-file=kafka-broker-1.keystore.jks=./kafka-broker-1.keystore.jks   --from-file=kafka-broker-2.keystore.jks=./kafka-broker-2.keystore.jks   --from-file=kafka.truststore.jks=./kafka.truststore.jks

#### Broker

Broker only statefulset parameters. 

    broker:
      replicaCount: 3 <--- Replica count
      minId: 100 <--- Min broker ID 
      zookeeperMigrationMode: false
      config: ""
      existingConfigmap: ""
      extraConfig: ""
      secretConfig: ""
      existingSecretConfig: ""
      heapOpts: -Xmx512m -Xms512m <--- Kafka Heap option
      command: []
      args: []
      extraEnvVars: []
      extraEnvVarsCM: ""
      extraEnvVarsSecret: ""
      extraContainerPorts: []
      livenessProbe: <--- Liveness probe
        enabled: true
        initialDelaySeconds: 10
        timeoutSeconds: 5
        failureThreshold: 3
        periodSeconds: 10
        successThreshold: 1
      readinessProbe: <--- Readiness probe
        enabled: true
        initialDelaySeconds: 5
        failureThreshold: 6
        timeoutSeconds: 5
        periodSeconds: 10
        successThreshold: 1
      startupProbe: <--- Startup probe
        enabled: false
        initialDelaySeconds: 30
        periodSeconds: 10
        timeoutSeconds: 1
        failureThreshold: 15
        successThreshold: 1
      customLivenessProbe: {}
      customReadinessProbe: {}
      customStartupProbe: {}
      lifecycleHooks: {}
      initContainerResources:
        limits: {}
        requests: {}
      resources:
        limits: {}
        requests: {}
      podSecurityContext: <--- Pod security context
        enabled: true
        fsGroup: 1001
        seccompProfile:
          type: "RuntimeDefault"
      containerSecurityContext: <--- Container security
        enabled: true
        runAsUser: 1001
        runAsNonRoot: true
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop: ["ALL"]
      hostAliases: []
      hostNetwork: false
      hostIPC: false
      podLabels: {}
      podAnnotations: {}
      podAffinityPreset: ""
      podAntiAffinityPreset: soft
      nodeAffinityPreset:
        type: ""
        key: ""
        values: []
      affinity: {}
      nodeSelector: {}
      tolerations: []
      topologySpreadConstraints: []
      terminationGracePeriodSeconds: ""
      podManagementPolicy: Parallel
      minReadySeconds: 0
      priorityClassName: ""
      runtimeClassName: ""
      enableServiceLinks: true
      schedulerName: ""
      updateStrategy:
        type: RollingUpdate
      extraVolumes: []
      extraVolumeMounts: []
      sidecars: []
      initContainers: []
      pdb:
        create: false
        minAvailable: ""
        maxUnavailable: 1
      persistence: <--- Data persistence
        enabled: true
        existingClaim: ""
        storageClass: ""
        accessModes:
          - ReadWriteOnce
        size: 1Gi
        annotations: {}
        labels: {}
        selector: {}
        mountPath: /bitnami/kafka
      logPersistence: <--- Log persistence
        enabled: false
        existingClaim: ""
        storageClass: ""
        accessModes:
          - ReadWriteOnce
        size: 1Gi
        annotations: {}
        selector: {}
        mountPath: /opt/bitnami/kafka/logs

#### External access
Configure external access of Kafka broker  through NodePort.

    externalAccess:
      enabled: true <--- External access 
      autoDiscovery:
        enabled: true
        image:
          registry: docker.io
          repository: bitnami/kubectl
          tag: 1.25.8-debian-11-r2
          pullPolicy: IfNotPresent
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 100m
            memory: 128Mi
      broker:
        service:
          type: NodePort <--- External access service
          ports:
            external: 9095 <--- External access port
          nodePorts:
            - 31090 
            - 31091
            - 31092
          #externalIPs:
            #- 192.168.49.2
            #- 192.168.49.2
            #- 192.168.49.2
#### Service
Configure Service for broker 

    service:
      type: LoadBalancer <--- Broker service type
      ports:
        client: 9092
        controller: 9093
        interbroker: 9094
        external: 9095
      extraPorts: []
      nodePorts:
        client: ""
        external: ""
      sessionAffinity: None
      sessionAffinityConfig: {}
      clusterIP: ""
      loadBalancerIP: ""
      loadBalancerSourceRanges: []
      externalTrafficPolicy: Cluster
      annotations: {}
      headless:
        controller:
          annotations: {}
          labels: {}
        broker:
          annotations: {}
          labels: {}
#### Auth

TLS configuration for client and interbroker communication.

    auth: <--- TLS authentication section
      interBrokerProtocol: tls
      clientProtocol: tls
      tls:
        type: jks
        existingSecrets:
          - "kafka-jks"
        password: "password"

#### Service account
Enable ServiceAccount for Kafka pods

    serviceAccount:
      create: true <--- Enable creation of ServiceAccount
      name: ""
      automountServiceAccountToken: true
      annotations: {}
    rbac:
      create: true 

#### Kafka metrics

Kafka exporter, to expose Kafka metrics. By default, it uses port 9308
JMX exporter, to expose JMX metrics. By default, it uses port 5556.

    metrics:
      kafka:
        enabled: true <--- Enables kafka metrics
        image:
          registry: docker.io
          repository: bitnami/kafka-exporter
          tag: 1.7.0-debian-11-r134
          digest: ""
          pullPolicy: IfNotPresent
          pullSecrets: []
        certificatesSecret: "kafka-exporter" <--- Secret name
        tlsCert: ca-cert <--- tls cert name in the secret
        tlsKey: ca-key <--- tls key name in the secret
        tlsCaSecret: "kafka-exporter" <--- CA secret
        tlsCaCert: "tls-ca-cert" <--- tls CA cert name in the secret
        extraFlags: 
          tls.insecure-skip-tls-verify: ""
        command: []
    
Convert kafka broker's JKS keystore file into PEM format and then extract CA cert and private key. Create a secret based on these cert and key and configure them in metrics:kafka section as described above.

    # Convert JKS into PEM      
    $ keytool -importkeystore -srckeystore kafka-broker-0.keystore.jks -destkeystore kafka-broker-0.p12 -srcstoretype jks -deststoretype pkcs12
    # Extract tls cert/ca cert and private keys
    $ openssl pkcs12 -in kafka-broker-0.p12 -out kafka-broker-0.pem    
    # Extract tls cert 
    $ keytool -exportcert -alias broker-0 -keystore kafka-broker-0.keystore.jks -rfc -file kafka-broker-0-cert.pem
    # Extract private key
    $ openssl pkey -in kafka-broker-0.pem -out kafka-broker-0-key.pem
    # Create secret
    $ kubectl create secret generic kafka-exporter --from-file=ca-cert=kafka-broker-0-cert.pem --from-file=ca-key=kafka-broker-0-key.pem --from-file=tls-ca-cert=kafka-broker-0-ca-cert.pem

#### JMX

    jmx:
        enabled: false
        kafkaJmxPort: 5555 <--- Kafka JMX port
        image:
          registry: docker.io
          repository: bitnami/jmx-exporter
          tag: 0.20.0-debian-11-r2
          digest: ""
          pullPolicy: IfNotPresent
          pullSecrets: []
        containerSecurityContext:
          enabled: true
          runAsUser: 1001
          runAsNonRoot: true
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop: ["ALL"]
        containerPorts:
          metrics: 5556
        resources:
          limits: {}
          requests: {}
        service:
          ports:
            metrics: 5556
          clusterIP: ""
          sessionAffinity: None
          annotations:
            prometheus.io/scrape: "true"
            prometheus.io/port: "{{ .Values.metrics.jmx.service.ports.metrics }}"
            prometheus.io/path: "/"
        whitelistObjectNames:
          - kafka.controller:*
          - kafka.server:*
          - java.lang:*
          - kafka.network:*
          - kafka.log:*
        config: |-
          jmxUrl: service:jmx:rmi:///jndi/rmi://127.0.0.1:{{ .Values.metrics.jmx.kafkaJmxPort }}/jmxrmi
          lowercaseOutputName: true
          lowercaseOutputLabelNames: true
          ssl: false
          {{- if .Values.metrics.jmx.whitelistObjectNames }}
          whitelistObjectNames: ["{{ join "\",\"" .Values.metrics.jmx.whitelistObjectNames }}"]
          {{- end }}
        existingConfigmap: ""
        extraRules: ""
      serviceMonitor:
        enabled: true <--- Enables service monitor for Prometheus
        namespace: ""
        interval: ""
        scrapeTimeout: ""
        labels: {}
        selector: {}
        relabelings: []
        metricRelabelings: []
        honorLabels: false
        jobLabel: ""
    
      prometheusRule:
        enabled: false
        namespace: ""
        labels: {}
        groups: []
    

<!--stackedit_data:
eyJoaXN0b3J5IjpbMTY0NjgwMjUzNCwtMTE0NTE3MTEwNCwtNj
IyNTc5MjM3LDE0MzI5Njc2MTEsLTk5MTkyODg5NywtMjEwNzIx
NTIxNSwtNTk3OTgyNTE3LC03Mzk2ODUzMTgsNDYyNDU0NTU1LC
03NTQ1NjA2MTcsLTE5MjAxMTkwMTAsNDQzNjIyODUxLC0xMjA3
NDMzNzI3LDEwNDUwNDIzMTIsNDQ1NTI3OTA1LDk0NTEzMzQwMS
wxOTc3NTEzNTIxLC0xNjA2Mjk5NjUsOTQzMjAyODg0LC02MDQ3
MTAyMDJdfQ==
-->