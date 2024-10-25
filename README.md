## Description

This repo contains terraform code for eks cluster that add Cluster autoscaler, Load balancer, EBS and EFS csi drivers.

### Use Aws secret manager for handle EKS secrets:

## Installed Secrets Store CSI driver:

```
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver
```

## Installing the AWS Provider
To install the Secrets Manager and Config Provider use the YAML file in the deployment directory:
```
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml
```


## Create policy 

```
"Version": "2012-10-17",
    "Statement": [ {
        "Effect": "Allow",
        "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        "Resource": ["arn:*:secretsmanager:*:*:secret:MySecret-??????"]
    } ]
```
## Create the IAM OIDC provider for the cluster if you have not already done so:Create the IAM OIDC provider for the cluster if you have not already done so:

```
eksctl utils associate-iam-oidc-provider --region="$REGION" --cluster="$CLUSTERNAME" --approve # Only run this once
```


## Create the service account to be used by the pod and associate the above IAM policy with that service account.

```
eksctl create iamserviceaccount --name nginx-deployment-sa --region="$REGION" --cluster "$CLUSTERNAME" --attach-policy-arn "$POLICY_ARN" --approve --override-existing-serviceaccounts
```

## Create SecretProvideClass:

```
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: db-aws-secrets
spec:
  provider: aws                             # accepted provider options: akeyless or azure or vault or gcp
  parameters:                                 # provider-specific parameters
    objects: |
        - objectName: "<aws-secret-manager-name>"
          objectType: "secretsmanager
```

## Create a pod deployment that mount the secrets as a volume:

```
spec:
serviceAccount: <Name of SA>
volumes:
  - name: db-cred
    csi:
      driver: secrets-store.csi.k8s.io
      readOnly: true
      volumeAttributes:
        secretProviderClass: "db-aws-secrets"
containers:
- name: nginx
  image: nginx
  volumeMounts:
    - name: db-cred
      mountPath: /tmp

```

## Rotate Secrets:
Sync up the latest secrets from aws secret manager

```
helm show valuee <chart-name> >> values.yaml
enableSecretRotation: true
```