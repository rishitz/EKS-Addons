resource "aws_eks_addon" "pod_identity" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.0-eksbuild.1"
}

// Its a Daemonset agent that will run on every single nodes in your eks cluster.
/*

CLS needs a permission to interact with aws and adje=ust desired size , so we need to authorize
The eks-pod-identity-agent add-on is a component of the AWS Identity and Access Management (IAM) service that allows pods to assume IAM roles and access AWS resources.
 By installing this add-on, you're enabling pod identity management for your EKS cluster.


Check latest addon_version: aws eks describe-addon-versions --region us-east-2 --addon-name eks-pod-identity-agent
*/