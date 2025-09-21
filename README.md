# Taylor Shift's Ticket Shop - Infrastructure

> Infrastructure scalable pour la vente de billets de concert utilisant HCL, AWS et DockerHub

## 🎯 Vue d'Ensemble

Ce projet déploie une infrastructure hautement scalable capable de gérer des pics de trafic massifs lors de la vente de billets de concert. L'architecture utilise Amazon cloud avec auto-scaling automatique et une approche multi-environnements (staging/production).

### Architecture Technique
- **Infrastructure as Code** : Terraform HCL
- **Container Orchestration** : Aws ECS et dockerHub
- **Application** : PrestaShop (e-commerce)
- **Base de données** : Amazon RDS MySQL avec read replicas
- **DNS** : Avec Amazon route 53
- **Auto-scaling** : Load Balancing, Internet gateway et auto-scaling

## Architecture Overview

## Architectural Diagram
![Alt text](https://github.com/abdoulWaris/Projet_prestashop_terraform/blob/main/Documentation/architecture_aws_prestashop.drawio.png)


### 1. **VPC Module**
Le module VPC se charge du reséau de l'infrastructure:
- **Sous-réseau public** Pour la partie Web (accessible depuis internet).
- **Sous-réseau privée** Pour la partie application et base de donnée (isolée).
- 2 Sous-réseaux publics (10.0.0.0/24 et 10.0.1.0/24) pour la passerelle NAT et l'ALB.
- 4 Sous-réseaux privés dont 2 pour l'application (10.0.2.0/24, 10.0.3.0/24) et 2 pou la base de données (10.0.4.0/24, 10.0.5.0/24).
- Inclus la passerelle NAT pour l'accès Internet sortant depuis des sous-réseaux privés.

### 2. **Web Tier**
- EC2 instances pour l'hébergement de application.
- Elastic Load Balancer (ELB) pour distribuer le traffic à travers multiples instances.

### 3. **Application Tier**
- Auto Scaling Groups (ASG) pour manager les serveurs.
- Établit des instances en fonction de la charge pour assurer une haute disponibilité.

### 4. **Database Tier**
- Amazon RDS pour la gestion des bases de données relationnelles.
- Configuré pour une haute disponibilité et une récupération après sinistre avec Multi-AZ.

### Autres 
- Amazon ECR (Registry de Conteneurs Élastique) : Pour stocker des images Docker.
- Amazon ECS (Service de Conteneurs Élastiques) : Pour exécuter des conteneurs Docker.
- Amazon S3 : Pour stocker les fichiers d'environnement. 
- Amazon DynamoDB : Pour verrouiller l'état de Terraform.
- Rôles IAM : Pour garantir un accès sécurisé aux services.
---

## Deployment Steps

## 📋 Prérequis
Pour ce projet nous avons travaillé sur une distribution windows 10 ainsi toute les étapes si dessous mentionnées prennent en compte l'environnement
### Versions Requises
| Outil | Version Minimum | Version Recommandée |
|-------|----------------|-------------------|
| Node.js | 20.0.0 | 20.x.x (LTS) |
| npm | 9.0.0 | Latest |
| AWS CLI | 2.13.0 | Latest |

### Compte AWS
- **Compte AWS actif** avec un accès IAM configuré || droits administrateur 
- **AWS CLI configuré** avec credentials
- **Région AWS** : `eu-west-1` (recommandée pour la France)

## 🚀 Installation

## Installation et configuration des Outils

### 1. Configuration AWS

```bash
# Configuration des credentials AWS
aws configure
# AWS Access Key ID: [Votre Access Key]
# AWS Secret Access Key: [Votre Secret Key]
# Default region name: eu-west-1
# Default output format: json

# Vérification
aws sts get-caller-identity
aws eks list-clusters --region eu-west-1
#Nb: Il se pourrait que vous devriez faire les installation en mode admin
Ou 
export AWS_ACCESS_KEY_ID=AKIAxxxxxx
export AWS_SECRET_ACCESS_KEY=abcd1234xxxxxx
export AWS_DEFAULT_REGION=us-east-1
# Ces variables ne durent que pour la session courante du terminal
```
### 2. Clone the Repository
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
