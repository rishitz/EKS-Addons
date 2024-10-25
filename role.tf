# data "aws_caller_identity" "current" {}

# /*
# "Principal": { ... }:

# Principal: This defines the entity that is allowed to assume the role.
# "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root":
# The "AWS" key indicates that the principal is an AWS account or IAM entity.
# "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root": This ARN (Amazon Resource Name) specifies that the root user of the current AWS account (as identified by data.aws_caller_identity.current.account_id) is the principal. This means that any IAM user or role in this account can assume this role.

# //all users in that aws account will get access to that role.

# */
# resource "aws_iam_role" "eks_read" {
#   name = "${local.env}-${local.eks_name}-eks-admin"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"  
#       }
#     }
#   ]
# }
# POLICY
# }

# //Policy to readOnly access
# resource "aws_iam_policy" "eks_read" {
#   name = "AmazonEKSReadOnlyPolicy"

#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "eks:DescribeCluster",
#                 "eks:ListClusters"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": "iam:PassRole",
#             "Resource": "*",
#             "Condition": {
#                 "StringEquals": {
#                     "iam:PassedToService": "eks.amazonaws.com"
#                 }
#             }
#         }

#     ]
# }

# POLICY
# }


# resource "aws_iam_role_policy_attachment" "eks_admin" {
#   role       = aws_iam_role.eks_read.name
#   policy_arn = aws_iam_policy.eks_read.arn
# }

# //create iam user that assume this role
# resource "aws_iam_user" "manager" {
#   name = "qa-user1"
# }

# //policy that allow assuming the eks read only role
# resource "aws_iam_policy" "eks_assume_read" {
#   name = "AmazonEKSAssumeAdminPolicy"

#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "sts:AssumeRole"
#             ],
#             "Resource": "${aws_iam_role.eks_read.arn}"
#         }
#     ]
# }
# POLICY
# }

# //Attach this policy to that user:
# resource "aws_iam_user_policy_attachment" "manager" {
#   user       = aws_iam_user.manager.name
#   policy_arn = aws_iam_policy.eks_assume_read.arn
# }

# //Use aws eks api to bind that iam role pod-reader rbac group
# //its added to the access entry that specify that any user that assume this role so it gives the permission to bind that aws role to k8 's rbac group.
# resource "aws_eks_access_entry" "manager" {
#   cluster_name      = aws_eks_cluster.eks.name
#   principal_arn     = aws_iam_role.eks_read.arn
#   kubernetes_groups = ["pod-readers-group"]
# }