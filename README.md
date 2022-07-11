## Architecture Choice

Redis in Redis Sentinel flavor is opted due to the small dataset use-case where the dataset can be fitted into RAM. Opting for Sentinel also gives us it's fault tolerance attributes like automatic leader/master re-election in the case of failure.

In the event of a heavy write/big dataset use-case, Redis Cluster maybe in favor instead due it's multi-master and auto-sharding capability. However, what comes with it is the additional operational complexity of managing sharded datasets.

For better isolation and reduced cognitive load, AWS ElastiCache may also be considered, this also reduces the blast radius whenever a Kubernetes cluster maintenance is performed.

## Prerequisites

```sh
make install
```

This installs all the necessary tools. Additionally AWS credentials is necessary to run the following examples.

## Setting up secret

Zero-trust approach to secret by letting IaC provision the secret to be used by the Redis DB. In this case AWS SecretsManager is used as the secret store.

```sh
cd terraform
terraform apply
```

## Installing redis

With AWS credentials loaded, run the following to render the K8S manifest.

> Note: The Pod template has a soft antiAffinity across hostnames meaning, K8S will try it's best to ensure no single replica will be running on the same node

```sh
kustomize build manifest/redis/base \
  | argocd-vault-plugin generate - \
  | kubectl apply -f -
```

Explanations by line:

1. Renders the redis helm chart into manifest
2. Pipes the manifest to replace placeholder secrets with remote values stored in SecretsManager
3. Pipes the final manifest to be applied to the Kubernetes cluster

## Connecting to DB

```yaml
containers:
  - name: app
    image: app
    environments:
      - envFrom:
        - name: REDIS_HOST
          value: shopping-cart-redis.redis.cluster.local
        - name: REDIS_READ_PORT
          value: "6379"
        - name: REDIS_SENTINEL_PORT
          value: "26379"
        - name: REDIS_PASSWORD
          valueFrom:
            secretKeyRef:
              key: db-password
              name: shopping-cart-redis # this secret can be imported to the target app namespace by using kustomize component
```

On the app level, READ operations can be performed on `6379` port and it will be balanced across 3 replicas. WRITE operations requires us to query SENTINEL on port `26379` to get the address of the current leader/master.

```redis
SENTINEL get-master-addr-by-name <MasterSet e.g: shopping-cart-redis>
```

Once an address is retrieved, write operation should be performed on the elected leader/master returned by SENTINEL.