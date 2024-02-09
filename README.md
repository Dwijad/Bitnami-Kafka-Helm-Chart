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


    tls:
      type: JKS
      existingSecret: "kafka-jks"
      keystorePassword: "password"
      truststorePassword: "password"
      jksKeystoreKey: kafka.keystore.jks
      jksTruststoreKey: kafka.truststore.jks

<!--stackedit_data:
eyJoaXN0b3J5IjpbLTExNzYyOTkxNzksOTQzMjAyODg0LC02MD
Q3MTAyMDIsLTkwMzMxOTkxNSwtNDA1MTA0OTI5LC0yMDg4NzQ2
NjEyLC03OTcwOTYyMDksLTMzMjQ1NTM2M119
-->