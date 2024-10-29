#!/bin/bash

#############################################
# EKS Cluster Setup Script
#############################################
# This script sets up a complete EKS cluster with:
# - Managed node group
# - EBS CSI Driver for persistent storage
# - AWS Load Balancer Controller for ingress
# - IAM roles and policies for services
#
# Prerequisites:
# - AWS CLI configured with admin permissions
# - eksctl installed
# - kubectl installed
# - helm installed
#
# Usage:
# 1. Update the configuration variables below
# 2. Run: ./setup_eks_cluster.sh
# 3. Check README for troubleshooting
#############################################

#############################################
# Configuration Variables
#############################################
# Cluster Settings
CLUSTER_NAME=""           # Name of your EKS cluster example: "sample"
REGION=""             # AWS region for deployment example: "us-east-1"
ACCOUNT_ID=""          # Your AWS account ID example: "12345678"
VERSION=""                 # Kubernetes version example: "1.31"

# Node Group Settings
WORKER_NODE_TYPE=""  # Instance type for worker nodes example: "r6i.xlarge" 
WORKER_NODES=               # Initial number of nodes example: 2
WORKER_NODES_MIN=             # Minimum nodes for autoscaling example: 1
WORKER_NODES_MAX=             # Maximum nodes for autoscaling example: 5
NODE_GROUP_NAME="" # Name of the node group example: "standard-workers"

#############################################
# 1. Cluster Creation
#############################################
echo "Creating EKS cluster..."
eksctl create cluster \
    --name $CLUSTER_NAME \
    --region $REGION \
    --version $VERSION \
    --nodegroup-name $NODE_GROUP_NAME \
    --node-type $WORKER_NODE_TYPE \
    --nodes $WORKER_NODES \
    --nodes-min $WORKER_NODES_MIN \
    --nodes-max $WORKER_NODES_MAX \
    --managed                  # Use managed node groups

#############################################
# 2. IAM OIDC Provider Setup
#############################################
echo "Associating IAM OIDC provider..."
eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --approve

#############################################
# 3. EBS CSI Driver Setup
#############################################
# Create IAM role and service account
echo "Creating IAM service account for EBS CSI Driver..."
eksctl create iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster $CLUSTER_NAME \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --approve

# Install EBS CSI Driver addon
echo "Creating CSI driver addon..."
eksctl create addon \
    --name aws-ebs-csi-driver \
    --cluster $CLUSTER_NAME \
    --service-account-role-arn arn:aws:iam::${ACCOUNT_ID}:role/AmazonEKS_EBS_CSI_DriverRole \
    --force

#############################################
# 4. AWS Load Balancer Controller Setup
#############################################
# Create IAM policy
echo "Creating IAM policy for ALB..."
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://../iam-policy.json

# Create service account
echo "Creating IAM service account for ALB..."
eksctl create iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --approve

# Install ALB controller
echo "Installing ALB using Helm..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$CLUSTER_NAME \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller

#############################################
# 5. Verification Steps
#############################################
# Check ALB versions
echo "Searching for ALB Helm Chart..."
helm search repo eks/aws-load-balancer-controller --versions

# Verify ALB controller deployment
echo "Verifying ALB controller installation..."
kubectl get deployment -n kube-system aws-load-balancer-controller

echo "EKS cluster setup complete!"

#############################################
# 6. Kubeconfig Update
#############################################
# Update local kubeconfig to connect to the cluster
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION