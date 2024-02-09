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
The bitnami kafka helm chart comes with number of options. Kafka cluster can be configured with freshly minted Kraft/zookeeper service or a existing  zookeeper service.
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTkwMzMxOTkxNSwtNDA1MTA0OTI5LC0yMD
g4NzQ2NjEyLC03OTcwOTYyMDksLTMzMjQ1NTM2M119
-->