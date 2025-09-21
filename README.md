

## Architecture Overview

## Architectural Diagram
![Alt text](https://github.com/abdoulWaris/Projet_prestashop_terraform/blob/main/Documentation/architecture_aws_prestashop.drawio.png)

### 1. **VPC Module**
The VPC module creates the network infrastructure:
- **Public Subnets** for the web tier (accessible from the internet).
- **Private Subnets** for the application and database tiers (isolated).
- Includes NAT Gateway for outbound internet access from private subnets.

### 2. **Web Tier**
- EC2 instances for hosting the web application.
- Elastic Load Balancer (ELB) for distributing traffic across multiple instances.

### 3. **Application Tier**
- Auto Scaling Groups (ASG) manage application servers.
- Scales instances based on load to ensure high availability.

### 4. **Database Tier**
- Amazon RDS for managing relational databases.
- Configured for high availability and disaster recovery with Multi-AZ.

---

## Deployment Steps

### Prerequisites
- **Terraform** installed on your system.
- **AWS CLI** configured with appropriate IAM permissions.
- A **key pair** created in AWS for EC2 access.

### Step 1: Clone the Repository
Download the Terraform configuration files:
```bash
git clone <repository-url>
cd <repository-folder>
```

### Step 2: Initialize Terraform
Initialize Terraform to download provider plugins and modules:
```bash
terraform init
```
