# Complete DevOps Pipeline Guide: From Scratch to Production

**Goal:** Build a complete CI/CD pipeline for a Spring Boot application using Git, Docker, Kubernetes, GKE, and GitHub Actions.

**Timeline:** ~4-5 hours (doing this yourself from scratch)

**Required Tools:**
- Java 21 JDK
- Maven 3.9+
- Docker (29.2.0+)
- Git
- GitHub account
- kubectl (Kubernetes CLI)
- Minikube (local Kubernetes)
- GCP account with $10-50 free trial credit
- Docker Hub account

---

## Step 1: Create Spring Boot Project from Scratch

### 1.1 Generate Spring Boot Project

**Option A: Using Spring Initializr (Web)**
1. Go to https://start.spring.io/
2. Configure:
   - Project: Maven
   - Language: Java
   - Spring Boot: 4.0.4 (or latest 4.x)
   - Group: `com.example`
   - Artifact: `demo`
   - Name: `demo`
   - Description: `Spring Boot DevOps Pipeline Demo`
   - Package name: `com.example.demo`
   - Packaging: Jar
   - Java: 21
3. Add Dependencies: **Spring Web**
4. Click "Generate" → Download ZIP
5. Unzip and open in your IDE

**Option B: Using Maven Command**
```bash
mvn archetype:generate \
  -DgroupId=com.example \
  -DartifactId=demo \
  -Dversion=1.0.0 \
  -DpackageName=com.example.demo \
  -Dinteractive=false \
  -DarchetypeArtifactId=maven-archetype-quickstart

# Then add Spring Boot dependencies manually
```

### 1.2 Create REST Controller

Create file: `src/main/java/com/example/demo/controller/DemoController.java`

```java
package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class DemoController {

    @GetMapping("/status")
    public Map<String, String> status() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("message", "System is running");
        return response;
    }

    @GetMapping("/hello")
    public String hello() {
        return "Hello from Production-Ready GKE!";
    }
}
```

### 1.3 Update application.properties

File: `src/main/resources/application.properties`

```properties
spring.application.name=demo
server.port=8080

# Logging
logging.level.root=INFO
logging.level.com.example.demo=DEBUG
```

### 1.4 Update pom.xml (if needed)

Ensure these properties:

```xml
<properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <java.version>21</java.version>
    <maven.compiler.source>21</maven.compiler.source>
    <maven.compiler.target>21</maven.compiler.target>
</properties>

<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

### 1.5 Test Locally

```bash
# Navigate to project directory
cd demo

# Build project
mvn clean package

# Run application
mvn spring-boot:run

# In another terminal, test endpoints
curl http://localhost:8080/api/status
# Expected: {"status":"UP","message":"System is running"}

curl http://localhost:8080/api/hello
# Expected: "Hello from Production-Ready GKE!"

# Stop with Ctrl+C
```

✅ **Result:** Spring Boot app running locally on port 8080

---

## Step 2: Git & GitHub Setup

### 2.1 Create Local Git Repository

```bash
cd demo

# Initialize git
git init

# Check git status
git status
```

### 2.2 Create `.gitignore`

Create file: `.gitignore`

```
# Maven
target/
*.jar
*.war
*.ear
*.class

# IDE
.idea/
.vscode/
*.swp
*.swo
*~
.DS_Store

# Environment files
.env
.env.local
.env.*.local

# Logs
logs/
*.log

# Build artifacts
bin/
out/

# Docker and Kubernetes
*.tar
*.tar.gz
.docker/config.json

# OS
Thumbs.db
```

### 2.3 Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `spring-boot-devops-pipeline`
3. Description: `Complete CI/CD pipeline for Spring Boot using Docker, Kubernetes, and GitHub Actions`
4. Public (for learning)
5. Initialize with README (optional)
6. Click "Create repository"

### 2.4 Connect Local to GitHub

```bash
# Add remote
git remote add origin https://github.com/YOUR_USERNAME/spring-boot-devops-pipeline.git

# Verify
git remote -v
# Should show: origin  https://github.com/YOUR_USERNAME/spring-boot-devops-pipeline.git (fetch/push)
```

### 2.5 First Commit to Main

```bash
# Add all files
git add .

# Commit
git commit -m "Initial commit: Spring Boot REST API with endpoints"

# Rename branch to main (if needed)
git branch -M main

# Push to main
git push -u origin main
```

### 2.6 Create Develop Branch

```bash
# Create develop branch from main
git checkout -b develop

# Push develop to GitHub
git push -u origin develop

# Verify branches on GitHub
# Go to https://github.com/YOUR_USERNAME/spring-boot-devops-pipeline
# You should see main and develop branches
```

✅ **Result:** Repository with main (production) and develop (staging) branches

---

## Step 3: Containerization with Docker

### 3.1 Create Dockerfile

Create file: `Dockerfile` (in project root)

```dockerfile
# Stage 1: Build application
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /build

# Copy pom.xml first for caching
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build application
RUN mvn clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Copy JAR from builder
COPY --from=builder /build/target/*.jar app.jar

# Change ownership to appuser
RUN chown appuser:appuser /app/app.jar

# Switch to non-root user
USER appuser

# Health check (runs every 30 seconds)
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/api/status || exit 1

# Pre-stop hook (graceful shutdown - 15 seconds)
STOPSIGNAL SIGTERM
RUN echo '#!/bin/sh\nsleep 15' > /app/preStop.sh && chmod +x /app/preStop.sh

# Expose port
EXPOSE 8080

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 3.2 Create `.dockerignore`

Create file: `.dockerignore`

```
.git
.gitignore
.DS_Store
.idea
.vscode
*.swp
*.swo
*~
target/
*.log
.env
.env.*
README.md
HELP.md
node_modules
.docker
```

### 3.3 Build Docker Image

```bash
# Build image
docker build -t demo:1.0.0 .

# Verify image created
docker images | grep demo
# Should show: demo  1.0.0  <image-id>  <created>  <size>

# Check image size (should be ~250MB)
docker images --format "table {{.Repository}}\t{{.Size}}" | grep demo
```

### 3.4 Test Docker Image Locally

```bash
# Run container
docker run -d --name demo-test -p 8080:8080 demo:1.0.0

# Wait 5 seconds for startup
sleep 5

# Test endpoints
curl http://localhost:8080/api/status
curl http://localhost:8080/api/hello

# View logs
docker logs demo-test

# Stop container
docker stop demo-test

# Remove container
docker rm demo-test
```

✅ **Result:** Docker image built (250MB) and verified working

---

## Step 4: Push to Docker Hub

### 4.1 Docker Hub Setup

1. Go to https://hub.docker.com
2. Sign up or login
3. Create new Repository:
   - Name: `demo`
   - Description: `Spring Boot DevOps Pipeline Demo`
   - Visibility: Public
   - Click "Create"

### 4.2 Tag and Push Image

```bash
# Login to Docker Hub (use your Docker Hub username, NOT email)
docker login
# Enter username and password (or access token)

# Tag image with Docker Hub username
docker tag demo:1.0.0 YOUR_USERNAME/demo:1.0.0
docker tag demo:1.0.0 YOUR_USERNAME/demo:latest

# Verify tags
docker images | grep YOUR_USERNAME/demo

# Push tags to Docker Hub
docker push YOUR_USERNAME/demo:1.0.0
docker push YOUR_USERNAME/demo:latest

# Verify on Docker Hub web interface
# Go to https://hub.docker.com/r/YOUR_USERNAME/demo
# You should see both tags
```

### 4.3 Test Pull from Docker Hub

```bash
# Remove local images
docker rmi YOUR_USERNAME/demo:1.0.0
docker rmi YOUR_USERNAME/demo:latest

# Pull from Docker Hub (proves it's publicly available)
docker pull YOUR_USERNAME/demo:1.0.0

# Run pulled image
docker run -d --name demo-hub-test -p 8080:8080 YOUR_USERNAME/demo:1.0.0

# Test
curl http://localhost:8080/api/status

# Cleanup
docker stop demo-hub-test && docker rm demo-hub-test
```

✅ **Result:** Image publicly available on Docker Hub

---

## Step 5: Kubernetes Basics

### 5.1 Kubernetes Concept Overview

**What is Kubernetes?**
- Orchestration platform for containerized applications
- Automates: deployment, scaling, networking, storage
- Ensures: high availability, self-healing, load balancing

**Key Objects:**
- **Pod:** Smallest deployable unit (one or more containers)
- **Deployment:** Manages multiple pod replicas
- **Service:** Exposes pods to network
- **ConfigMap:** Configuration key-value pairs
- **Secret:** Sensitive data (passwords, tokens)

**Local vs Cloud:**
- Minikube: Single-node local cluster (learning/testing)
- GKE: Multi-node managed cluster (production)

### 5.2 Create Kubernetes Manifests

Create directory: `kubernetes/`

**File 1: `kubernetes/namespace.yaml`**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: demo-app
```

**File 2: `kubernetes/configmap.yaml`**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config
  namespace: demo-app
data:
  SPRING_PROFILES_ACTIVE: "production"
  SERVER_PORT: "8080"
  LOGGING_LEVEL_ROOT: "INFO"
  APP_NAME: "demo"
  APP_VERSION: "1.0.0"
```

**File 3: `kubernetes/deployment.yaml`**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
  namespace: demo-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: demo
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: demo
    spec:
      # Pod disruption budget (prevents accidental termination)
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - demo
              topologyKey: kubernetes.io/hostname
      
      containers:
      - name: demo
        image: YOUR_USERNAME/demo:1.0.0
        imagePullPolicy: Always
        
        ports:
        - name: http
          containerPort: 8080
          protocol: TCP
        
        # Environment variables from ConfigMap
        envFrom:
        - configMapRef:
            name: demo-config
        
        # Resource management
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        
        # Liveness probe (restart if unhealthy)
        livenessProbe:
          httpGet:
            path: /api/status
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        
        # Readiness probe (ready to receive traffic)
        readinessProbe:
          httpGet:
            path: /api/status
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
        
        # Graceful shutdown
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 15"]
```

**File 4: `kubernetes/service.yaml`**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo
  namespace: demo-app
  labels:
    app: demo
spec:
  type: LoadBalancer
  selector:
    app: demo
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 8080
```

### 5.3 Install kubectl

```bash
# macOS
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify
kubectl version --client
```

### 5.4 Install and Start Minikube

```bash
# Install Minikube (macOS)
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-darwin-amd64
chmod +x minikube-darwin-amd64
sudo mv minikube-darwin-amd64 /usr/local/bin/minikube

# Start Minikube
minikube start --driver=docker --memory=4096 --cpus=2

# Verify
kubectl cluster-info
kubectl get nodes
```

✅ **Result:** Kubernetes cluster running locally

---

## Step 6: Deploy to Minikube (Local Testing)

### 6.1 Create Namespace

```bash
# Create namespace
kubectl apply -f kubernetes/namespace.yaml

# Verify
kubectl get namespaces
```

### 6.2 Deploy Application

```bash
# Deploy all resources
kubectl apply -f kubernetes/

# Verify resources
kubectl get all -n demo-app
```

### 6.3 Monitor Pods

```bash
# Watch pod creation (in real-time)
kubectl get pods -n demo-app -w

# Once all 3 pods are Running/Ready (1/1), press Ctrl+C

# Get detailed pod info
kubectl describe pod -n demo-app

# Check pod logs
kubectl logs -n demo-app -l app=demo --tail=50

# Execute command inside pod
kubectl exec -n demo-app -it <pod-name> -- sh
```

### 6.4 Access Application

```bash
# Port forward (in background)
kubectl port-forward -n demo-app svc/demo 8080:80 &

# Test endpoints
curl http://localhost:8080/api/status
curl http://localhost:8080/api/hello

# Alternative: Get service (note: EXTERNAL-IP will be <pending> in Minikube)
kubectl get svc -n demo-app

# Use NodePort if available
kubectl get svc -n demo-app -o wide
```

### 6.5 Test Auto-Healing

```bash
# Delete a pod
kubectl delete pod -n demo-app <pod-name>

# Watch new pod auto-create
kubectl get pods -n demo-app -w

# Kubernetes auto-heals! New pod replaces deleted one
```

✅ **Result:** Application deployed locally with 3 replicas, auto-healing verified

---

## Step 7: Deploy to Google Kubernetes Engine (GKE)

### 7.1 Set Up GCP Project

```bash
# Install gcloud CLI (macOS)
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init

# Authenticate
gcloud auth login

# Create new project
gcloud projects create devops-pipeline-demo --name="DevOps Pipeline Demo"
gcloud config set project devops-pipeline-demo

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
```

### 7.2 Create GKE Cluster

```bash
# Create cluster (3 nodes, standard machine type)
gcloud container clusters create demo-cluster \
  --zone=us-central1-a \
  --num-nodes=3 \
  --machine-type=n1-standard-1 \
  --enable-autoscaling \
  --min-nodes=3 \
  --max-nodes=10

# This takes 3-5 minutes. Wait for completion.

# Verify cluster created
gcloud container clusters list
```

### 7.3 Configure kubectl for GKE

```bash
# Get credentials for GKE cluster
gcloud container clusters get-credentials demo-cluster --zone=us-central1-a

# Verify connection to GKE
kubectl cluster-info
kubectl get nodes
# Should show 3 nodes vs 1 in Minikube
```

### 7.4 Deploy to GKE

```bash
# Apply same Kubernetes manifests
kubectl apply -f kubernetes/

# Monitor deployment (takes 2-3 minutes)
kubectl get pods -n demo-app -w

# Once all 3 pods Running, check service
kubectl get svc -n demo-app
# Now EXTERNAL-IP should have a real IP (not <pending>)
```

### 7.5 Test GKE Deployment

```bash
# Get external IP
EXTERNAL_IP=$(kubectl get svc -n demo-app demo -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo $EXTERNAL_IP

# Test endpoints via public IP
curl http://$EXTERNAL_IP/api/status
curl http://$EXTERNAL_IP/api/hello

# Should work from anywhere!
```

### 7.6 Cleanup GKE Cluster (Optional)

```bash
# When done learning, delete cluster to avoid charges
gcloud container clusters delete demo-cluster --zone=us-central1-a
```

✅ **Result:** Application running on GKE with real external IP

---

## Step 8: Complete GitHub Actions CI/CD Pipeline

### 8.1 Update `.github/workflows/ci-cd.yml`

Replace the entire file with:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'src/**'
      - 'pom.xml'
      - 'Dockerfile'
      - '.github/workflows/ci-cd.yml'
  pull_request:
    branches: [ main ]

env:
  REGISTRY: docker.io
  IMAGE_NAME: YOUR_USERNAME/demo

jobs:
  # Job 1: Build and Test
  build:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.image.outputs.tag }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      with:
        fetch-depth: 0  # Full history for versioning
    
    - name: Set up JDK 21
      uses: actions/setup-java@v3
      with:
        java-version: '21'
        distribution: 'temurin'
        cache: maven
    
    - name: Build with Maven
      run: mvn clean package
    
    - name: Run tests
      run: mvn test
    
    - name: Generate image tag
      id: image
      run: |
        VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
        echo "tag=$VERSION" >> $GITHUB_OUTPUT
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Log in to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: |
          ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ steps.image.outputs.tag }}
          ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
        cache-from: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache
        cache-to: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache,mode=max

  # Job 2: Deploy to GKE (only on main branch)
  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Set up gcloud
      uses: google-github-actions/setup-gcloud@v1
      with:
        project_id: ${{ secrets.GCP_PROJECT_ID }}
        service_account_key: ${{ secrets.GKE_SA_KEY }}
        cli_version: latest
    
    - name: Get GKE credentials
      run: |
        gcloud container clusters get-credentials demo-cluster \
          --zone=us-central1-a \
          --project=${{ secrets.GCP_PROJECT_ID }}
    
    - name: Update deployment image
      run: |
        kubectl set image deployment/demo demo=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ needs.build.outputs.image-tag }} \
          -n demo-app \
          --record
    
    - name: Wait for rollout
      run: |
        kubectl rollout status deployment/demo \
          -n demo-app \
          --timeout=5m
    
    - name: Verify deployment
      run: |
        echo "Deployment successful!"
        kubectl get pods -n demo-app
        kubectl get svc -n demo-app
```

### 8.2 Set Up GitHub Secrets

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Create new secrets:

**Secret 1: DOCKER_USERNAME**
- Value: Your Docker Hub username

**Secret 2: DOCKER_PASSWORD**
- Value: Your Docker Hub access token (NOT password!)
  - Create at https://hub.docker.com/settings/security
  - Generate new access token with read/write permissions

**Secret 3: GCP_PROJECT_ID**
- Value: Your GCP project ID (from `gcloud config get-value project`)

**Secret 4: GKE_SA_KEY**
- Create GCP Service Account:
  ```bash
  gcloud iam service-accounts create github-actions \
    --display-name="GitHub Actions"
  
  gcloud projects add-iam-policy-binding devops-pipeline-demo \
    --member=serviceAccount:github-actions@devops-pipeline-demo.iam.gserviceaccount.com \
    --role=roles/container.developer
  
  gcloud iam service-accounts keys create key.json \
    --iam-account=github-actions@devops-pipeline-demo.iam.gserviceaccount.com
  
  cat key.json
  ```
- Value: Entire JSON output from `key.json` file

### 8.3 Update pom.xml Version (Optional)

Add version tag for automatic versioning:

```xml
<version>1.0.0</version>
```

This will be used by CI/CD for image tagging.

### 8.4 Test CI/CD Pipeline

```bash
# Make a small change to code
echo "# Updated" >> README.md

# Commit and push
git add .
git commit -m "Test CI/CD pipeline trigger"
git push origin develop

# or to trigger deployment:
git push origin main
```

**Monitor pipeline:**
1. Go to GitHub repo
2. Click "Actions" tab
3. Watch workflow execute
4. See logs in real-time

**What happens:**
- ✅ Build: Maven compiles and tests
- ✅ Docker: Builds image and pushes to Docker Hub
- ✅ Deploy (if main): Updates GKE with new image
- ✅ Rollout: Kubernetes deploys pods automatically

### 8.5 Verify GKE Auto-Update

```bash
# After successful GitHub Actions run:
kubectl get deployment demo -n demo-app -o yaml

# Should show new image: YOUR_USERNAME/demo:1.0.0

# Check pod logs
kubectl logs -n demo-app -l app=demo --tail=20
```

✅ **Result:** Complete CI/CD pipeline from code commit to production deployment

---

## Step 9: Production Best Practices

### 9.1 Environment Management

Create separate ConfigMaps for environments:

**`kubernetes/configmap-dev.yaml`**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config-dev
  namespace: demo-app
data:
  SPRING_PROFILES_ACTIVE: "dev"
  LOGGING_LEVEL_ROOT: "DEBUG"
```

**`kubernetes/configmap-prod.yaml`**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config-prod
  namespace: demo-app
data:
  SPRING_PROFILES_ACTIVE: "production"
  LOGGING_LEVEL_ROOT: "WARN"
```

### 9.2 Secrets Management

```bash
# Create Kubernetes secret
kubectl create secret generic demo-secrets \
  -n demo-app \
  --from-literal=db-password=your-secure-password \
  --from-literal=api-key=your-api-key

# Use in deployment
envFrom:
- secretRef:
    name: demo-secrets
```

### 9.3 HorizontalPodAutoscaler

Create file: `kubernetes/hpa.yaml`

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: demo-hpa
  namespace: demo-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: demo
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

Deploy:
```bash
kubectl apply -f kubernetes/hpa.yaml
```

### 9.4 Monitoring with Prometheus

```bash
# Add Prometheus annotations to deployment
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  prometheus.io/path: "/actuator/prometheus"
```

### 9.5 Logging Stack

For production logging:
- **ELK Stack:** Elasticsearch + Logstash + Kibana
- **GCP Cloud Logging:** View in GCP Console

```bash
# See GKE logs in GCP
gcloud logging read "resource.type=k8s_container AND resource.labels.namespace_name=demo-app" --limit 50
```

✅ **Result:** Production-grade deployment with autoscaling, secrets, and monitoring

---

## Step 10: Full Architecture Review

### 10.1 End-to-End Flow Diagram

```
Developer
    ↓
Local Development (Java 21 + Spring Boot)
    ↓
Git Commit & Push to GitHub (main/develop)
    ↓
GitHub Actions Triggered
    ├─ Step 1: Build (Maven clean package)
    ├─ Step 2: Test (Maven test)
    ├─ Step 3: Build Docker Image
    ├─ Step 4: Push to Docker Hub
    └─ Step 5: Deploy to GKE (if main branch)
    ↓
GKE Cluster
    ├─ Pull latest image from Docker Hub
    ├─ Create 3 Pod replicas
    ├─ Run Liveness & Readiness probes
    ├─ LoadBalancer Service exposes public IP
    └─ HPA scales based on CPU/Memory
    ↓
Public Internet (via external IP)
    └─ Users access application via public IP
```

### 10.2 File Structure Overview

```
demo/
├── src/
│   ├── main/
│   │   ├── java/com/example/demo/
│   │   │   ├── DemoApplication.java
│   │   │   └── controller/DemoController.java
│   │   └── resources/
│   │       ├── application.properties
│   │       ├── application-dev.properties
│   │       └── application-prod.properties
│   └── test/
├── kubernetes/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── hpa.yaml
│   └── README.md
├── .github/
│   └── workflows/
│       └── ci-cd.yml (Complete CI/CD pipeline)
├── Dockerfile
├── .dockerignore
├── .gitignore
├── pom.xml
├── README.md
├── COMPLETE_DEVOPS_PIPELINE_STEPS.md (This file)
└── [Other documentation files]
```

### 10.3 Troubleshooting Guide

**Issue: Pods stay in Pending**
```bash
kubectl describe pod -n demo-app <pod-name>
# Check Events section for root cause
```

**Issue: ImagePullBackOff**
```bash
# Ensure image exists in Docker Hub
docker images | grep YOUR_USERNAME/demo

# If missing, rebuild and push
docker build -t YOUR_USERNAME/demo:1.0.0 .
docker push YOUR_USERNAME/demo:1.0.0
```

**Issue: Readiness probe failing**
```bash
# Check if /api/status returns 200
curl -i http://localhost:8080/api/status

# Check pod logs
kubectl logs -n demo-app <pod-name>
```

**Issue: GitHub Actions fails**
- Check "Actions" tab on GitHub
- Click on failed workflow
- View logs for detailed error message
- Verify all secrets are set correctly

### 10.4 Demo Commands

```bash
# View all resources
kubectl get all -n demo-app

# Get external IP
kubectl get svc -n demo-app demo -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Test endpoints
curl http://EXTERNAL_IP/api/status
curl http://EXTERNAL_IP/api/hello

# View real-time logs
kubectl logs -f -n demo-app -l app=demo

# Watch pod scaling (after HPA configured)
kubectl get hpa -n demo-app -w

# Scale manually
kubectl scale deployment demo -n demo-app --replicas=5

# View pod details
kubectl describe pod -n demo-app <pod-name>

# Execute command in pod
kubectl exec -n demo-app <pod-name> -- curl localhost:8080/api/status

# Update image version
kubectl set image deployment/demo demo=YOUR_USERNAME/demo:1.1.0 -n demo-app --record

# Rollback to previous version
kubectl rollout undo deployment/demo -n demo-app

# Check rollout history
kubectl rollout history deployment/demo -n demo-app
```

### 10.5 Production Checklist

- ✅ Spring Boot application with REST endpoints
- ✅ Docker multi-stage build (optimized)
- ✅ Kubernetes manifests (deployment, service, configmap)
- ✅ Local testing with Minikube
- ✅ Cloud testing with GKE
- ✅ GitHub repository with branching strategy
- ✅ GitHub Actions CI/CD pipeline
- ✅ Secrets management
- ✅ Health checks (liveness & readiness)
- ✅ Resource limits and requests
- ✅ Graceful shutdown
- ✅ Non-root container user
- ✅ HorizontalPodAutoscaler
- ✅ Monitoring and logging

✅ **Result:** Complete, production-grade DevOps pipeline

---

## Quick Reference Commands

```bash
# Local Development
mvn spring-boot:run
mvn clean package
mvn test

# Docker
docker build -t demo:1.0.0 .
docker run -p 8080:8080 demo:1.0.0
docker push YOUR_USERNAME/demo:1.0.0

# Minikube
minikube start
kubectl apply -f kubernetes/
kubectl delete -f kubernetes/

# GKE
gcloud container clusters create demo-cluster --zone=us-central1-a
kubectl apply -f kubernetes/
gcloud container clusters delete demo-cluster --zone=us-central1-a

# Kubernetes Universal
kubectl get pods -n demo-app
kubectl get svc -n demo-app
kubectl logs -n demo-app <pod-name>
kubectl exec -n demo-app <pod-name> -- sh
kubectl describe pod -n demo-app <pod-name>
kubectl delete pod -n demo-app <pod-name>
kubectl port-forward -n demo-app svc/demo 8080:80

# Git
git add .
git commit -m "message"
git push origin main
git push origin develop
git checkout -b feature/branch-name
```

---

## Summary

You now have a **complete, production-grade DevOps pipeline** with:

1. ✅ Spring Boot REST API
2. ✅ Git branching strategy
3. ✅ Docker containerization
4. ✅ Docker Hub registry
5. ✅ Kubernetes (local + cloud)
6. ✅ GKE deployment
7. ✅ GitHub Actions CI/CD
8. ✅ Production best practices

**Total Build Time:** ~4-5 hours (completely from scratch)

**Cost:** ~$5-10 for GKE usage during learning (uses free trial credits first)

**Next Steps:**
- Add database persistence
- Implement API authentication
- Add monitoring dashboard
- Set up log aggregation
- Configure DNS and SSL certificates

Good luck! 🚀
