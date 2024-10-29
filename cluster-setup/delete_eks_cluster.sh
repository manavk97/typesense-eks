#!/bin/bash

# EKS Cluster Deletion Script
# This script removes an Amazon EKS cluster and its associated resources
# WARNING: This will delete all resources in the cluster including data

# Prerequisites Check and Setup
# Required tools:
# - eksctl : The official CLI for Amazon EKS
# - aws cli: The AWS command line interface
# - AWS credentials configured with appropriate permissions

# Configure AWS CLI with your credentials
# This will prompt for:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region
# - Output format
aws configure

# Cluster Configuration Variables
CLUSTER_NAME=""        # Name of the EKS cluster to delete example: "sample"
REGION=""          # AWS region where the cluster is deployed example: "us-east-1"

# Begin Cluster Deletion Process
echo "Deleting EKS cluster..."
eksctl delete cluster \
    --name $CLUSTER_NAME   # Specify cluster name
    --region $REGION      # Specify AWS region

# This command will:
# 1. Delete all kubernetes resources in the cluster
# 2. Delete all worker nodes
# 3. Delete the control plane
# 4. Remove associated VPC and networking components
# 5. Clean up IAM roles and policies