# Terraform Demo Project 1

This project demonstrates infrastructure provisioning on AWS using Terraform with CI/CD integration through Jenkins.

## Project Structure

terraform-demo-project-1/
│── modules/
│   ├── vpc/
│   ├── ec2/
│   ├── security-groups/
│   ├── eks/
│
├── environments/
│   ├── dev/
│   ├── prod/
│
├── Jenkinsfile
│
├── terraform/
│
├── .gitignore
├── README.md

## Features

1. **AWS Infrastructure Provisioning**
   - VPCs, Subnets, Security Groups, EC2 Instances, EKS Clusters
   - Environment-specific configurations

2. **Docker Container Deployment**
   - Automatic Docker container deployment on EC2 instances

3. **Kubernetes Support**
   - EKS cluster provisioning with node groups
   - Network and security configuration

4. **Terraform State Management**
   - Remote state in S3 with locking via DynamoDB
   - State separation per environment

5. **CI/CD Integration**
   - Automated infrastructure provisioning with Jenkins
   - Pipeline stages for planning, approval, and application

## Getting Started

### Prerequisites

- AWS Account
- AWS CLI configured with appropriate permissions
- Terraform v1.0+ installed
- Jenkins with AWS and Terraform plugins

### Deployment Steps

1. **Set up the backend infrastructure**

   ```bash
   cd terraform
   terraform init
   terraform apply

2. **Deploy Development Environment**

    cd environments/dev
    terraform init
    terraform plan
    terraform apply

3. **Deploy Production Environment**

    cd environments/dev
    terraform init
    terraform plan
    terraform apply

4. **CI/CD**

    The Jenkins pipeline supports the following operations:

    Terraform Plan: Preview changes before applying
    Terraform Apply: Apply infrastructure changes
    Terraform Destroy: Remove infrastructure
    Docker Container Deployment: Automatic deployment on EC2
    EKS Configuration: Configure Kubernetes access

    To use the pipeline:

    Navigate to Jenkins dashboard
    Create a new pipeline job using the Jenkinsfile
    Run the pipeline with your desired parameters

5. **Modules**

    VPC Module
    Creates VPC, subnets, Internet Gateway, NAT Gateway, and routing tables.
    Security Groups Module
    Defines security groups for web servers, databases, and EKS clusters.
    EC2 Module
    Provisions EC2 instances with Docker support.
    EKS Module
    Creates Kubernetes clusters with node groups and IAM roles.

6. **Environment Configuartions**

    Development (dev)
    Optimized for development with:

    Single NAT Gateway
    Smaller instance types
    Public access for testing

    Production (prod)
    Optimized for production with:

    Multiple NAT Gateways for high availability
    Larger instance types
    Restricted access and increased security

7. **Contributing**

    Fork the repository
    Create your feature branch (git checkout -b feature/amazing-feature)
    Commit your changes (git commit -m 'Add some amazing feature')
    Push to the branch (git push origin feature/amazing-feature)
    Open a Pull Request

8. ## 10. Finally, let's create a `.gitignore` file to exclude Terraform state files and other unnecessary files:

### .gitignore: