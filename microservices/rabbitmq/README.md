helm repo add bitnami https://charts.bitnami.com/bitnami

export RABBITMQ_PASSWORD=crawler_pass

helm install rabbitmq \
  --set auth.password=$RABBITMQ_PASSWORD \
    bitnami/rabbitmq