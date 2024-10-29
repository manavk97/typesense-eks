# typesense-eks
Self-hosted elastic search database - Typesense


# EKS Cluster Setup Instructions

This README provides step-by-step instructions for setting up an Amazon EKS (Elastic Kubernetes Service) cluster using the `setup_eks_cluster.sh` script.

## Prerequisites

- AWS CLI installed and configured with appropriate credentials
- `eksctl` installed
- `kubectl` installed (ensure it supports kustomize)
- `helm` installed

## Steps

1. **Set Environment Variables**
   - Open `setup_eks_cluster.sh` and update the following variables:
     - `CLUSTER_NAME`: Set your desired cluster name
     - `REGION`: Set your desired AWS region
     - `ACCOUNT_ID`: Replace with your AWS account ID

2. **Create EKS Cluster**
   - Ensure you have the `1.cluster.yaml` file in the `development` directory
   - Modify the `1.cluster.yaml` file to match your specific requirements (e.g., node type, count, region)
   - The script will create the EKS cluster and node group based on this configuration

3. **Update EKS Cluster**
   - Ensure you have the `2.nodegroup.yaml` file in the `development` directory
   - Review and modify the `2.nodegroup.yaml` file to match your specific requirements (e.g., node group name, instance types, scaling configuration)
   - The script will update the cluster and node group configurations based on this file

4. **Associate IAM OIDC Provider**
   - This step associates an IAM OIDC provider with your cluster

5. **Set Up EBS CSI Driver**
   - Creates an IAM service account for the EBS CSI Driver
   - Creates the CSI driver addon

6. **Set Up AWS Load Balancer Controller**
   - Creates an IAM policy for the ALB
   - Creates an IAM service account for the ALB
   - Installs the AWS Load Balancer Controller using Helm

7. **Verify Installation**
   - The script will search for the ALB Helm chart
   - It will also verify that the AWS Load Balancer Controller is installed correctly

## Usage

1. Make the script executable:
   ```
   chmod +x setup_eks_cluster.sh
   ```

2. Run the script:
   ```
   ./setup_eks_cluster.sh
   ```

3. Follow the output to ensure each step completes successfully

## Troubleshooting

- If any step fails, review the error messages and ensure all prerequisites are met
- Check that your AWS credentials have the necessary permissions
- Verify that all required tools (eksctl, kubectl, helm) are installed and up to date

## Clean Up

To delete the EKS cluster and associated resources when no longer needed:

## Contributing

We welcome contributions to improve the typesense-eks project! Here's how you can contribute:

1. **Fork the Repository**
   - Create your own fork of the project
   - Clone it to your local machine

2. **Create a Branch**
   - Create a new branch for your feature or bugfix
   - Use a descriptive name (e.g., `feature/add-monitoring` or `fix/nodegroup-scaling`)

3. **Make Your Changes**
   - Follow existing code style and conventions
   - Add or update documentation as needed
   - Test your changes thoroughly

4. **Submit a Pull Request**
   - Push your changes to your fork
   - Create a Pull Request from your branch to our main branch
   - Provide a clear description of the changes
   - Reference any related issues

5. **Code Review**
   - Wait for maintainers to review your PR
   - Make any requested changes
   - Once approved, your PR will be merged

### Development Guidelines

- Follow infrastructure-as-code best practices
- Document any new configuration options
- Update the README for significant changes
- Test changes in a separate EKS cluster before submitting

### Reporting Issues

If you find a bug or have a feature request:
1. Check existing issues first
2. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Your environment details

For questions or discussions, please use the repository's Discussions section.