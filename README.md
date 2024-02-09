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

<!--stackedit_data:
eyJoaXN0b3J5IjpbLTYwNDcxMDIwMiwtOTAzMzE5OTE1LC00MD
UxMDQ5MjksLTIwODg3NDY2MTIsLTc5NzA5NjIwOSwtMzMyNDU1
MzYzXX0=
-->