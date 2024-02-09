## Configure Bitnami Helm Chart

A simplified configuration of Bitnami kafka helm chart to quickly create a cluster in Kubernetes. It simplifies configuring kafka cluster from scratch and avoids manually managing the complex service configuration from scratch.

### Get the chart

    $ helm repo add bitnami https://charts.bitnami.com/bitnami
    $ helm repo update
    $ helm pull bitnami/kafka
    $ tar xf kafka-26.8.5.tgz
    $ cd kafka

### Configure
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
        enabled: true <--- Enabled Persistence
        storageClass: ""
        accessModes:
          - ReadWriteOnce
        size: 1Gi
    
    externalZookeeper:
      servers: []

#### Listener

Configure listener properties for client, external, interbroker and controller. If Kraft is disabled, controller listener properties does not need to be configured.

    listeners:
      client:
        containerPort: 9092
        protocol: SASL_SSL
        name: CLIENT
        sslClientAuth: "required"
    
      external:
        containerPort: 9095
        protocol: SASL_SSL
        name: EXTERNAL
        sslClientAuth: ""
    
      interbroker:
        containerPort: 9093
        protocol: PLAINTEXT
        name: INTERNAL
        sslClientAuth: ""
    
      controller:
        containerPort: 9094
        protocol: SASL_PLAINTEXT
        name: CONTROLLER
        sslClientAuth: ""

#### SASL
SASL authentication for interbroker, client and controller communication can be controlled in SASL section.

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
      type: JKS
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
External access

    externalAccess:
      enabled: true
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
          type: NodePort
          ports:
            external: 9095
          nodePorts:
            - 31090
            - 31091
            - 31092
          #externalIPs:
            #- 192.168.49.2
            #- 192.168.49.2
            #- 192.168.49.2
#### Service
Service

    service:
      type: LoadBalancer
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

    auth:
      interBrokerProtocol: tls
      clientProtocol: tls
      tls:
        type: jks
        existingSecrets:
          - "kafka-jks"
        password: "password"

#### Service account

    serviceAccount:
      create: true
      name: ""
      automountServiceAccountToken: true
      annotations: {}
    rbac:
      create: true 

<!--stackedit_data:
eyJoaXN0b3J5IjpbMTkzNDg5MzU4OSwxOTc3NTEzNTIxLC0xNj
A2Mjk5NjUsOTQzMjAyODg0LC02MDQ3MTAyMDIsLTkwMzMxOTkx
NSwtNDA1MTA0OTI5LC0yMDg4NzQ2NjEyLC03OTcwOTYyMDksLT
MzMjQ1NTM2M119
-->