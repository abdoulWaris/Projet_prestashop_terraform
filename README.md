# Taylor Shift's Ticket Shop - Infrastructure

> Infrastructure scalable pour la vente de billets de concert utilisant HCL, AWS ECR, ECS, EC2 et Dockerhub

## 🎯 Vue d'Ensemble

Ce projet déploie une infrastructure hautement scalable capable de gérer des pics de trafic massifs lors de la vente de billets de concert. L'architecture utilise Amazon ECS (Kubernetes) avec auto-scaling automatique et une approche multi-environnements (staging/production).

### Architecture Technique
- **Infrastructure as Code** : Terraform en HCL
- **Container Orchestration** : DockerHub, Aws ECS & Aws EC2
- **Application** : PrestaShop (e-commerce)
- **Base de données** : Amazon RDS MySQL avec read replicas
- **CDN** : CloudFront pour la performance globale
- **Auto-scaling** : HPA, VPA et Cluster Autoscaler

## 📋 Prérequis

### Versions Requises
| Outil | Version Minimum | Version Recommandée |
|-------|----------------|-------------------|
| Node.js | 20.0.0 | 20.x.x (LTS) |
| npm | 9.0.0 | Latest |
| AWS CLI | 2.13.0 | Latest |
| kubectl | 1.28.0 | Latest |
| Helm | 3.12.0 | Latest |

### Compte AWS
- **Compte AWS actif** avec droits administrateur
- **AWS CLI configuré** avec credentials
- **Région AWS** : `eu-west-1` (recommandée pour la France)

## 🚀 Installation

### 1. Installation des Outils

#### Sur Ubuntu/Debian
```bash
# Node.js 20 (via NodeSource)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Apache Benchmark (pour les tests)
sudo apt-get install apache2-utils
```

#### Sur macOS
```bash
# Via Homebrew
brew install node@20 awscli kubectl helm eksctl

# Apache Benchmark
brew install httpd
```

### 2. Configuration AWS

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
```

### 3. Installation du Projet

```bash
# Clonage du repository
git clone https://github.com/votre-organisation/taylor-shift-infrastructure.git
cd taylor-shift-infrastructure

# Installation des dépendances
npm install

# Installation de CDKTF CLI
npm install -g cdktf-cli@latest

# Vérification de l'installation
cdktf --version
node --version
```

## ⚙️ Configuration

### 1. Variables d'Environnement

Créez un fichier `.env` à la racine du projet :

```bash
# .env
AWS_REGION=eu-west-1
AWS_ACCOUNT_ID=123456789012

# Staging Environment
STAGING_DOMAIN=staging-tickets.taylorshift.com
STAGING_DB_PASSWORD=SecurePassword123!

# Production Environment  
PRODUCTION_DOMAIN=tickets.taylorshift.com
PRODUCTION_DB_PASSWORD=SuperSecurePassword456!

# Shared Services
ECR_REPOSITORY_URL=123456789012.dkr.ecr.eu-west-1.amazonaws.com/prestashop
ROUTE53_ZONE_ID=Z1234567890ABC
```

### 2. Configuration CDKTF

Le fichier `cdktf.json` est déjà configuré :

```json
{
  "language": "typescript",
  "app": "npm run compile && node dist/main.js",
  "projectId": "taylor-shift-infrastructure",
  "sendCrashReports": "false",
  "terraformProviders": [
    "aws@~> 5.0",
    "kubernetes@~> 2.23",
    "helm@~> 2.11"
  ],
  "terraformModules": [],
  "context": {
    "excludeStackIdFromLogicalIds": "true",
    "allowSepCharsInLogicalIds": "true"
  }
}
```

### 3. Construction de l'Image PrestaShop

```bash
# Construction et push vers ECR
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $ECR_REPOSITORY_URL

docker build -t prestashop-optimized ./docker/
docker tag prestashop-optimized:latest $ECR_REPOSITORY_URL:latest
docker push $ECR_REPOSITORY_URL:latest
```

## 🏗️ Déploiement

### 1. Déploiement de l'Infrastructure

#### Services Partagés (Une seule fois)
```bash
# Synthèse et planification
npm run build
cdktf plan shared

# Déploiement
cdktf deploy shared
```

#### Environnement Staging
```bash
# Planification
cdktf plan staging

# Déploiement
cdktf deploy staging

# Configuration kubectl pour staging
aws eks update-kubeconfig --region eu-west-1 --name taylor-shift-staging
```

#### Environnement Production  
```bash
# Planification
cdktf plan production

# Déploiement (nécessite approbation)
cdktf deploy production

# Configuration kubectl pour production
aws eks update-kubeconfig --region eu-west-1 --name taylor-shift-production
```

### 2. Déploiement des Applications Kubernetes

#### Staging
```bash
# Switch vers le contexte staging
kubectl config use-context arn:aws:eks:eu-west-1:ACCOUNT:cluster/taylor-shift-staging

# Déploiement des manifests
kubectl apply -k kubernetes/overlays/staging/

# Vérification
kubectl get pods -n prestashop-staging
kubectl get services -n prestashop-staging
```

#### Production
```bash
# Switch vers le contexte production  
kubectl config use-context arn:aws:eks:eu-west-1:ACCOUNT:cluster/taylor-shift-production

# Déploiement des manifests
kubectl apply -k kubernetes/overlays/production/

# Vérification
kubectl get pods -n prestashop-production
kubectl get services -n prestashop-production
```

## 📊 Monitoring et Vérification

### 1. État des Clusters

```bash
# Vérification des nodes
kubectl get nodes
kubectl top nodes

# Vérification des pods
kubectl get pods --all-namespaces
kubectl top pods --all-namespaces

# Services et ingress
kubectl get services,ingress --all-namespaces
```

### 2. Auto-scaling

```bash
# HPA status
kubectl get hpa -n prestashop-production

# VPA status  
kubectl get vpa -n prestashop-production

# Cluster autoscaler logs
kubectl logs -f deployment/cluster-autoscaler -n kube-system
```

### 3. Base de Données

```bash
# Connexion à RDS (depuis un pod)
kubectl run mysql-client --image=mysql:8.0 -it --rm --restart=Never -- \
  mysql -h YOUR_RDS_ENDPOINT -u admin -p

# Status des read replicas
aws rds describe-db-instances --region eu-west-1
```

## 🧪 Tests de Performance

### 1. Tests de Base

```bash
# Test simple sur staging
ab -n 1000 -c 10 https://staging-tickets.taylorshift.com/

# Test de montée en charge
ab -n 10000 -c 100 https://staging-tickets.taylorshift.com/
```

### 2. Tests de Production

```bash
# Test de validation (faible charge)
ab -n 5000 -c 50 https://tickets.taylorshift.com/

# Test de charge élevée (pendant maintenance uniquement)
ab -n 50000 -c 500 https://tickets.taylorshift.com/

# Surveillance pendant les tests
kubectl top pods -n prestashop-production --sort-by=cpu
kubectl get hpa -n prestashop-production -w
```

### 3. Métriques Attendues

#### Staging
- **Response Time** : < 500ms (95e percentile)
- **Throughput** : 500+ requests/seconde
- **Error Rate** : < 1%

#### Production
- **Response Time** : < 200ms (95e percentile)  
- **Throughput** : 5000+ requests/seconde
- **Error Rate** : < 0.1%

## 💰 Gestion des Coûts

### 1. Surveillance des Coûts

```bash
# Estimation des coûts EC2
aws ec2 describe-instances --region eu-west-1 --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name]' --output table

# Coûts RDS
aws rds describe-db-instances --region eu-west-1 --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceClass,Engine]' --output table

# Utilisation EKS
kubectl top nodes
kubectl top pods --all-namespaces | head -20
```

### 2. Optimisations

#### Staging (Coûts Réduits)
- **Instances** : t3.medium (burstable)
- **Auto-scaling** : 1-3 pods maximum
- **RDS** : db.t3.micro, single-AZ
- **Backup** : 1 jour de rétention

#### Production (Performance Optimisée)
- **Instances** : c5.large+ (compute optimized)
- **Spot Instances** : 60% d'économies sur une partie
- **Auto-scaling** : 2-50 pods selon charge
- **RDS** : Multi-AZ avec read replicas

### 3. Coûts Estimés

| Environnement | Configuration | Coût Mensuel | Coût Pic |
|---------------|--------------|--------------|----------|
| **Staging** | Base | ~172€ | ~250€ |
| **Production** | Base | ~774€ | ~1,884€ |
| **Total** | Base | ~946€ | ~2,134€ |

## 🔧 Commandes Utiles

### Infrastructure

```bash
# Voir l'état Terraform
cdktf list
cdktf diff staging
cdktf diff production

# Destruction (ATTENTION !)
cdktf destroy staging
cdktf destroy production
```

### Kubernetes

```bash
# Logs des applications
kubectl logs -f deployment/prestashop -n prestashop-production

# Scaling manuel temporaire
kubectl scale deployment prestashop --replicas=10 -n prestashop-production

# Port-forward pour debug
kubectl port-forward svc/prestashop 8080:80 -n prestashop-staging

# Exécution de commandes dans un pod
kubectl exec -it deployment/prestashop -n prestashop-production -- /bin/bash
```

### Base de Données

```bash
# Backup manuel RDS
aws rds create-db-snapshot \
  --db-instance-identifier taylor-shift-production \
  --db-snapshot-identifier manual-backup-$(date +%Y%m%d)

# Restore depuis backup
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier taylor-shift-restored \
  --db-snapshot-identifier manual-backup-20241125
```

## 🚨 Dépannage

### 1. Problèmes Courants

#### Pods en état Pending
```bash
# Vérifier les resources disponibles
kubectl describe pod POD_NAME -n NAMESPACE
kubectl get events -n NAMESPACE --sort-by='.lastTimestamp'

# Vérifier les nodes
kubectl get nodes
kubectl describe nodes
```

#### Connexion Base de Données
```bash
# Tester la connectivité
kubectl run mysql-test --image=mysql:8.0 -it --rm -- \
  mysql -h RDS_ENDPOINT -u admin -p -e "SELECT VERSION();"

# Vérifier les security groups
aws ec2 describe-security-groups --region eu-west-1
```

#### Performance Dégradée
```bash
# Vérifier les métriques
kubectl top nodes
kubectl top pods --all-namespaces --sort-by=cpu

# Logs des auto-scalers  
kubectl logs deployment/cluster-autoscaler -n kube-system
kubectl logs deployment/metrics-server -n kube-system
```

### 2. Contacts et Support

- **AWS Support** : Console AWS → Support Center
- **Kubernetes Docs** : https://kubernetes.io/docs/
- **CDKTF Docs** : https://developer.hashicorp.com/terraform/cdktf

### 3. Rollback d'Urgence

```bash
# Rollback Kubernetes
kubectl rollout undo deployment/prestashop -n prestashop-production
kubectl rollout status deployment/prestashop -n prestashop-production

# Rollback Infrastructure (si nécessaire)
cdktf plan production  # Vérifier les changements
# Puis modifier le code et redéployer
```

## 📚 Documentation Additionnelle

- [Architecture Détaillée](./docs/architecture.md)
- [Analyse des Coûts](./docs/cost-analysis.md)
- [Runbook Opérationnel](./docs/runbook.md)
- [Tests de Charge](./docs/load-testing.md)

## 🔐 Sécurité

### Bonnes Pratiques
- **Secrets** : Utilisation d'AWS Secrets Manager
- **Network** : Security groups restrictifs
- **RBAC** : Permissions Kubernetes granulaires
- **SSL/TLS** : Certificats automatiques via ACM
- **WAF** : Protection contre les attaques DDoS

### Compliance
- **Encryption** : EBS et RDS chiffrés
- **Backups** : Automatisés avec rétention configurable
- **Logging** : CloudTrail activé pour audit
- **Monitoring** : CloudWatch pour alertes

---

## ⚡ Quick Start

Pour un déploiement rapide en cas d'urgence :

```bash
# 1. Installation rapide
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs aws-cli
npm install -g cdktf-cli

# 2. Configuration
aws configure
git clone REPO_URL && cd taylor-shift-infrastructure
npm install && cp .env.example .env

# 3. Déploiement
npm run quick-deploy:staging

# 4. Vérification
kubectl get pods --all-namespaces
curl https://staging-tickets.taylorshift.com/
```

**🎉 L'infrastructure est maintenant prête pour gérer les pics de trafic de Taylor Shift !**