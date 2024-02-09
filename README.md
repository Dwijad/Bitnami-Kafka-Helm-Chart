## Configure Bitnami Helm Chart

A simplified configuration of Bitnami kafka helm chart to quickly create a cluster in Kubernetes. It simplifies configuring kafka cluster from scratch and avoids manually managing the complex service configuration from scratch.

### Get the chart

    $ helm repo add bitnami https://charts.bitnami.com/bitnami
    $ helm repo update
    $ helm pull bitnami/kafka
    $ tar xf kafka-26.8.5.tgz

### Configure
###
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEzNTQ5ODExMTQsLTQwNTEwNDkyOSwtMj
A4ODc0NjYxMiwtNzk3MDk2MjA5LC0zMzI0NTUzNjNdfQ==
-->