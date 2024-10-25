data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

//This setup allows Terraform to use Helm to deploy and manage applications within the specified EKS cluster.


resource "helm_release" "metrics_server" {
  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"

  values = [file("${path.module}/values/metrics-server.yaml")]

  depends_on = [aws_eks_node_group.general]
}

/*
This ensures that the Helm release will only be deployed after the aws_eks_node_group.general resource (which represents an EKS node group) has been successfully created. 
This dependency makes sure that the nodes are ready before deploying the Metrics Server.



Values:  this section is telling Terraform to load the custom configuration from the metrics-server.yaml file located in the values directory of the current module, 
and use these settings when deploying the Metrics Server Helm chart
*/