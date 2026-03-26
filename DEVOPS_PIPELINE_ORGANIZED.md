# 🚀 Complete DevOps Pipeline Guide: From Scratch to Production

---

## 📚 Table of Contents

| Step | Component | Topics | Duration | Difficulty |
|------|-----------|--------|----------|-----------|
| **1** | 🟢 Spring Boot Setup | Project creation, REST API | 30 min | Easy |
| **2** | 🟢 Git & GitHub | Repository, branching | 20 min | Easy |
| **3** | 🔵 Docker | Containerization | 45 min | Medium |
| **4** | 🔵 Docker Hub | Registry, versioning | 20 min | Medium |
| **5** | 🟣 Kubernetes | Concepts, manifests | 30 min | Hard |
| **6** | 🟣 Minikube Testing | Local deployment | 45 min | Hard |
| **7** | 🔴 GKE Deployment | Cloud deployment | 45 min | Hard |
| **8** | 🔴 CI/CD Pipeline | GitHub Actions | 60 min | Hard |
| **9** | 🔴 Production Features | Autoscaling, monitoring | 30 min | Hard |
| **10** | 📊 Architecture Review | End-to-end flow | 20 min | Medium |

**Total Time:** ~4-5 hours | **Total Cost:** Free (with GCP trial)

---

## ✅ Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Java 21 JDK** - `java -version`
- [ ] **Maven 3.9+** - `mvn -version`
- [ ] **Docker** - `docker --version`
- [ ] **Git** - `git --version`
- [ ] **GitHub Account** - Free account at github.com
- [ ] **Docker Hub Account** - Free account at hub.docker.com
- [ ] **GCP Account** - Free trial at cloud.google.com ($300 credit)
- [ ] **Text Editor/IDE** - VS Code, IntelliJ, or similar

**Don't have these?** Install them first before proceeding.

---

# PHASE 1: LOCAL DEVELOPMENT (Steps 1-3)
## 🟢 Build & Test Locally

---

## Step 1️⃣: Create Spring Boot Project from Scratch

**⏱️ Duration:** 30 minutes  
**📊 Difficulty:** Easy  
**🎯 Goal:** Create a working Spring Boot REST API

### What You'll Create:
- Spring Boot application (Java 21)
- Two REST endpoints
- Local testing capability

---

### 1.1 Generate Spring Boot Project

#### **Option A: Web UI (Recommended for Beginners)**

1. Open https://start.spring.io/ in your browser
2. Configure these settings:

| Setting | Value |
|---------|-------|
| **Project** | Maven |
| **Language** | Java |
| **Spring Boot** | 4.0.4 (or latest 4.x) |
| **Group** | `com.example` |
| **Artifact** | `demo` |
| **Name** | `demo` |
| **Package name** | `com.example.demo` |
| **Packaging** | Jar |
| **Java** | 21 |

3. Click "ADD DEPENDENCIES" → Search for **Spring Web** → Click it
4. Click "GENERATE" button
5. Download the ZIP file
6. Unzip it: `unzip demo.zip`
7. Open in your IDE

#### **Option B: Maven Command Line**

```bash
mvn archetype:generate \
  -DgroupId=com.example \
  -DartifactId=demo \
  -Dversion=1.0.0 \
  -DpackageName=com.example.demo \
  -Dinteractive=false \
  -DarchetypeArtifactId=maven-archetype-quickstart
```

---

### 1.2 Create REST Controller

**File Path:** `src/main/java/com/example/demo/controller/DemoController.java`

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

**What this does:**
- `/api/status` → Returns JSON showing if app is running (used by Kubernetes health checks)
- `/api/hello` → Returns a simple greeting message

---

### 1.3 Configure Application Properties

**File Path:** `src/main/resources/application.properties`

```properties
# Application name
spring.application.name=demo

# Server port (Kubernetes will forward to this)
server.port=8080

# Logging configuration
logging.level.root=INFO
logging.level.com.example.demo=DEBUG
```

---

### 1.4 Update pom.xml (Verify Settings)

Open `pom.xml` and ensure these properties exist:

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

---

### 1.5 Test Application Locally

```bash
# Navigate to project
cd demo

# Build
mvn clean package

# Run
mvn spring-boot:run
```

**Expected Output:**
```
Tomcat started on port(s): 8080 (http)
Started DemoApplication in X.XXX seconds
```

---

### 1.6 Verify Endpoints

Open a new terminal and test:

```bash
# Test /api/status endpoint
curl http://localhost:8080/api/status

# Expected Response:
# {"status":"UP","message":"System is running"}

# Test /api/hello endpoint
curl http://localhost:8080/api/hello

# Expected Response:
# "Hello from Production-Ready GKE!"
```

Stop the app with `Ctrl+C`

---

### ✨ Key Takeaways - Step 1

- ✅ Created Spring Boot REST API
- ✅ Two working endpoints
- ✅ Tested locally on port 8080
- ✅ Ready for containerization

---

---

## Step 2️⃣: Git & GitHub Setup

**⏱️ Duration:** 20 minutes  
**📊 Difficulty:** Easy  
**🎯 Goal:** Set up version control and branching strategy

### What You'll Create:
- Local Git repository
- GitHub remote repository
- main and develop branches

---

### 2.1 Create .gitignore

**File Path:** `.gitignore` (in project root)

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

# Docker
*.tar
*.tar.gz
.docker/config.json

# OS
Thumbs.db
```

---

### 2.2 Initialize Local Git Repository

```bash
cd demo

# Initialize
git init

# Check status
git status

# Should show: "On branch master" and untracked files
```

---

### 2.3 Create GitHub Repository

1. Go to https://github.com/new
2. Fill in:
   - **Repository name:** `spring-boot-devops-pipeline`
   - **Description:** `Complete CI/CD pipeline for Spring Boot using Docker, Kubernetes, and GitHub Actions`
   - **Visibility:** Public
   - **Initialize with README:** NO (we'll create our own)
3. Click "Create repository"

---

### 2.4 Connect Local Git to GitHub

```bash
# Add remote
git remote add origin https://github.com/YOUR_USERNAME/spring-boot-devops-pipeline.git

# Verify connection
git remote -v

# Should show:
# origin  https://github.com/YOUR_USERNAME/spring-boot-devops-pipeline.git (fetch)
# origin  https://github.com/YOUR_USERNAME/spring-boot-devops-pipeline.git (push)
```

---

### 2.5 First Commit to Main Branch

```bash
# Stage all files
git add .

# Commit
git commit -m "Initial commit: Spring Boot REST API with endpoints"

# Rename branch to main (if on master)
git branch -M main

# Push to GitHub
git push -u origin main

# Verify on GitHub:
# Go to https://github.com/YOUR_USERNAME/spring-boot-devops-pipeline
# Should see main branch with files
```

---

### 2.6 Create Develop Branch

```bash
# Create develop branch from main
git checkout -b develop

# Push to GitHub
git push -u origin develop

# Verify in GitHub
# Should see both main and develop branches
```

---

### 📊 Git Flow Branching Strategy

```
                    feature/*
                       ↓
[Feature Branch] → [develop] → [Pull Request] → [main] → [Production]
                       ↓
                   hotfix/*
```

**When to use each branch:**
- **main:** Production-ready code only (latest stable release)
- **develop:** Integration branch for features (staging environment)
- **feature/*:** New features (e.g., `feature/new-endpoint`)
- **hotfix/*:** Emergency fixes (e.g., `hotfix/security-patch`)

---

### ✨ Key Takeaways - Step 2

- ✅ Local Git repository initialized
- ✅ GitHub repository created
- ✅ main and develop branches set up
- ✅ Branching strategy understood

---

---

## Step 3️⃣: Containerization with Docker

**⏱️ Duration:** 45 minutes  
**📊 Difficulty:** Medium  
**🎯 Goal:** Create optimized Docker container

### What You'll Create:
- Multi-stage Dockerfile
- .dockerignore file
- ~250MB optimized image

---

### Why Docker?

| Before Docker | After Docker |
|---|---|
| "Works on my machine" | Works everywhere |
| Different OS/Java versions issues | Same environment guaranteed |
| Manual dependency management | Dependencies bundled |
| Slow deployment | Fast deployment |

---

### 3.1 Create Dockerfile

**File Path:** `Dockerfile` (in project root)

```dockerfile
# ===== STAGE 1: BUILD =====
# Use Maven with Java 21 to compile application
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /build

# Copy pom.xml first (for Docker layer caching)
COPY pom.xml .

# Download dependencies (cached if pom.xml doesn't change)
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build JAR
RUN mvn clean package -DskipTests

# ===== STAGE 2: RUNTIME =====
# Use lightweight Alpine JRE (only 150MB vs 400MB full JDK)
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Create non-root user (security best practice)
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Copy JAR from builder stage
COPY --from=builder /build/target/*.jar app.jar

# Set ownership
RUN chown appuser:appuser /app/app.jar

# Use non-root user
USER appuser

# Health check (runs every 30 seconds)
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/api/status || exit 1

# Expose port
EXPOSE 8080

# Start application
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**Why multi-stage?**
- Stage 1 (builder): Compiles code (needs Maven, 500MB)
- Stage 2 (runtime): Runs app (only needs JRE, 150MB)
- **Result:** Final image ~250MB (vs 500MB with single stage)

---

### 3.2 Create .dockerignore

**File Path:** `.dockerignore` (in project root)

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
kubernetes/
.github/
```

This prevents unnecessary files from being copied into the image.

---

### 3.3 Build Docker Image

```bash
# Build image
docker build -t demo:1.0.0 .

# This will take 2-3 minutes on first build

# Verify image created
docker images | grep demo

# Output should show:
# REPOSITORY    TAG      IMAGE ID      CREATED       SIZE
# demo          1.0.0    abc123def456  2 minutes ago  250MB
```

**What happens:**
1. Downloads base images
2. Installs Maven and dependencies
3. Compiles Java code
4. Creates lightweight runtime image
5. Total: ~2-3 minutes

---

### 3.4 Test Docker Image Locally

```bash
# Run container
docker run -d --name demo-test -p 8080:8080 demo:1.0.0

# Wait for startup (check logs)
docker logs demo-test

# Wait until you see: "Tomcat started on port(s): 8080"

# Wait 5 seconds
sleep 5

# Test endpoints
curl http://localhost:8080/api/status
curl http://localhost:8080/api/hello

# Expected: Same responses as local run

# View container logs
docker logs demo-test

# Stop and remove
docker stop demo-test
docker rm demo-test
```

---

### 📊 Image Size Breakdown

```
alpine:latest           = ~7MB
eclipse-temurin:21-jre  = 150MB
spring-boot-app.jar     = 20MB
─────────────────────────────
TOTAL                   = 177MB

+ Docker metadata       = ~250MB total
```

**Optimization achieved:** 68% smaller than unoptimized (~750MB)

---

### ✨ Key Takeaways - Step 3

- ✅ Multi-stage Dockerfile created
- ✅ Image size optimized (~250MB)
- ✅ Non-root user for security
- ✅ Health checks configured
- ✅ Image tested and verified

---

---

# PHASE 2: REGISTRY & DEPLOYMENT (Steps 4-7)
## 🔵 Push to Registry & Deploy Locally

---

## Step 4️⃣: Push to Docker Hub (Registry)

**⏱️ Duration:** 20 minutes  
**📊 Difficulty:** Medium  
**🎯 Goal:** Make image publicly available

### What You'll Create:
- Docker Hub repository
- Semantic versioning strategy
- Public image for Kubernetes

---

### Why Docker Hub?

- 🌐 Central registry for container images
- 🔒 Version control (1.0.0, 1.0.1, etc.)
- 🚀 Used by Kubernetes to pull images
- 🎯 Production deployments reference specific versions

---

### 4.1 Docker Hub Setup

1. Go to https://hub.docker.com
2. Sign up (free) or login
3. Click "Create Repository"
4. Fill in:
   - **Name:** `demo`
   - **Description:** `Spring Boot DevOps Pipeline`
   - **Visibility:** Public
5. Click "Create"

---

### 4.2 Login to Docker Hub from Terminal

```bash
# Login (use your Docker Hub username, NOT email)
docker login

# Enter username when prompted
# Enter password (or access token)

# Verify login successful
docker ps  # Should work without errors
```

---

### 4.3 Tag Image for Docker Hub

```bash
# Format: docker tag <local-image> <docker-hub-username>/<repo>:<tag>

# Tag with version
docker tag demo:1.0.0 YOUR_USERNAME/demo:1.0.0

# Tag as latest
docker tag demo:1.0.0 YOUR_USERNAME/demo:latest

# Verify tags
docker images | grep YOUR_USERNAME/demo

# Output:
# YOUR_USERNAME/demo  1.0.0  abc123  2 min ago  250MB
# YOUR_USERNAME/demo  latest abc123  2 min ago  250MB
```

---

### 4.4 Push to Docker Hub

```bash
# Push version tag
docker push YOUR_USERNAME/demo:1.0.0

# Push latest tag
docker push YOUR_USERNAME/demo:latest

# Wait for upload (progress bar shows upload status)

# Verify on Docker Hub web:
# Go to https://hub.docker.com/r/YOUR_USERNAME/demo
# Should see both tags listed
```

---

### 4.5 Test Pull from Docker Hub

```bash
# Remove local images to test pull
docker rmi YOUR_USERNAME/demo:1.0.0
docker rmi YOUR_USERNAME/demo:latest

# Pull from Docker Hub
docker pull YOUR_USERNAME/demo:1.0.0

# Run pulled image
docker run -d --name demo-hub-test -p 8080:8080 YOUR_USERNAME/demo:1.0.0

# Test endpoints
curl http://localhost:8080/api/status

# Cleanup
docker stop demo-hub-test && docker rm demo-hub-test
```

---

### 📊 Semantic Versioning Strategy

```
MAJOR.MINOR.PATCH
  ↓      ↓     ↓
  1      0     0
  │      │     └─ Patch: Bug fixes (1.0.1, 1.0.2)
  │      └─────── Minor: New features (1.1.0, 1.2.0)
  └──────────── Major: Breaking changes (2.0.0)

Examples:
1.0.0 → First release
1.0.1 → Bug fix
1.1.0 → New feature (API endpoint)
2.0.0 → Major change (database schema)
```

---

### ✨ Key Takeaways - Step 4

- ✅ Docker Hub repository created
- ✅ Image pushed with semantic versioning
- ✅ Image publicly available
- ✅ Pull from registry verified

---

---

## Step 5️⃣: Kubernetes Basics & Manifests

**⏱️ Duration:** 30 minutes  
**📊 Difficulty:** Hard (but important!)  
**🎯 Goal:** Understand Kubernetes and create manifests

### What You'll Create:
- Kubernetes YAML manifests
- Deployment (3 replicas)
- Service (LoadBalancer)
- ConfigMap (configuration)

---

### Why Kubernetes?

| Feature | Benefit |
|---------|---------|
| **Auto-scaling** | Automatically create more pods if traffic increases |
| **Self-healing** | Restart failed pods automatically |
| **Load balancing** | Distribute traffic across pods |
| **Rolling updates** | Deploy new versions without downtime |
| **Resource management** | Set CPU/memory limits |
| **Multi-cloud** | Same manifests work on any cloud |

---

### Kubernetes Architecture

```
KUBERNETES CLUSTER
│
├─ Node 1
│  ├─ Pod 1 (Container)
│  └─ Pod 2 (Container)
│
├─ Node 2
│  ├─ Pod 3 (Container)
│  └─ Pod 4 (Container)
│
└─ Services (Load Balancer)
   └─ Routes traffic to pods
```

---

### Key Kubernetes Objects

| Object | Purpose | Example |
|--------|---------|---------|
| **Pod** | Smallest unit, wraps container | One demo container |
| **Deployment** | Manages pod replicas | Keep 3 pods running always |
| **Service** | Exposes pods to network | LoadBalancer on port 80 |
| **ConfigMap** | Configuration data | SPRING_PROFILES_ACTIVE=prod |
| **Secret** | Sensitive data | Database passwords |

---

### 5.1 Create kubernetes/ Directory

```bash
# Create directory
mkdir kubernetes
cd kubernetes
```

---

### 5.2 Create ConfigMap Manifest

**File Path:** `kubernetes/configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config
  namespace: default
data:
  # Spring Boot configuration
  SPRING_PROFILES_ACTIVE: "production"
  SERVER_PORT: "8080"
  LOGGING_LEVEL_ROOT: "INFO"
  
  # Application metadata
  APP_NAME: "demo"
  APP_VERSION: "1.0.0"
```

**What this does:**
- Stores configuration key-value pairs
- Spring Boot automatically reads these as environment variables
- No need to rebuild image for configuration changes

---

### 5.3 Create Deployment Manifest

**File Path:** `kubernetes/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
spec:
  # Keep 3 pods running always
  replicas: 3
  
  # Find pods with label app=demo
  selector:
    matchLabels:
      app: demo
  
  # Rolling update strategy: deploy new version gradually
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1              # Create 1 new pod at a time
      maxUnavailable: 0        # Keep all pods available
  
  # Pod template
  template:
    metadata:
      labels:
        app: demo
    
    spec:
      containers:
      - name: demo
        # Reference Docker Hub image
        image: YOUR_USERNAME/demo:1.0.0
        imagePullPolicy: Always  # Always pull latest from registry
        
        # Container port
        ports:
        - name: http
          containerPort: 8080
        
        # Environment variables from ConfigMap
        envFrom:
        - configMapRef:
            name: demo-config
        
        # Resource limits (prevent pods from consuming all resources)
        resources:
          requests:
            cpu: 100m              # Minimum required
            memory: 256Mi
          limits:
            cpu: 500m              # Maximum allowed
            memory: 512Mi
        
        # Liveness probe: Restart if unhealthy
        livenessProbe:
          httpGet:
            path: /api/status
            port: 8080
          initialDelaySeconds: 30  # Wait 30s before first check
          periodSeconds: 10        # Check every 10s
          failureThreshold: 3      # Restart after 3 failures
        
        # Readiness probe: Ready to receive traffic?
        readinessProbe:
          httpGet:
            path: /api/status
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 5
          failureThreshold: 2      # Remove from load balancer after 2 failures
        
        # Graceful shutdown (15 seconds to finish requests)
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 15"]
```

**Key concepts:**
- **replicas: 3** → 3 identical pods run simultaneously
- **imagePullPolicy: Always** → Always pull latest from Docker Hub
- **livenessProbe** → Kubernetes restarts unhealthy pods
- **readinessProbe** → Kubernetes removes pods not ready for traffic
- **resources.limits** → Prevent pod from consuming too much CPU/memory

---

### 5.4 Create Service Manifest

**File Path:** `kubernetes/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo
spec:
  # Expose as LoadBalancer (gets public IP in cloud)
  type: LoadBalancer
  
  # Route to pods with label app=demo
  selector:
    app: demo
  
  # Port mapping
  ports:
  - name: http
    protocol: TCP
    port: 80           # External port (public internet)
    targetPort: 8080   # Internal port (pod port)
```

**What this does:**
- Public users access port 80 (standard HTTP)
- Kubernetes routes to port 8080 inside pod
- LoadBalancer automatically distributes traffic to 3 pods

---

### ✨ Key Takeaways - Step 5

- ✅ Kubernetes concepts understood
- ✅ ConfigMap created (configuration)
- ✅ Deployment created (3 replicas, health checks)
- ✅ Service created (load balancing)

---

---

## Step 6️⃣: Deploy to Minikube (Local Testing)

**⏱️ Duration:** 45 minutes  
**📊 Difficulty:** Hard  
**🎯 Goal:** Deploy to local Kubernetes cluster

### What You'll Learn:
- Installing kubectl and Minikube
- Deploying manifests
- Viewing pods and logs
- Testing endpoints

---

### Why Test Locally First?

- ✨ Faster iteration (5 min vs 10 min for cloud)
- 💰 Free (no cloud charges)
- 🔧 Easier debugging
- 🎓 Safe learning environment

---

### 6.1 Install kubectl (Kubernetes CLI)

```bash
# macOS
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify
kubectl version --client
# Should output: version.Info{GitVersion:"v1.xx.x", ...}
```

---

### 6.2 Install and Start Minikube

```bash
# Install Minikube (macOS)
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-darwin-amd64
chmod +x minikube-darwin-amd64
sudo mv minikube-darwin-amd64 /usr/local/bin/minikube

# Start Minikube cluster
minikube start --driver=docker --memory=4096 --cpus=2

# Takes 1-2 minutes...

# Verify cluster running
kubectl cluster-info
kubectl get nodes
# Should show: minikube  Ready  worker  2m
```

---

### 6.3 Create Deployment

```bash
# Navigate to project root
cd /path/to/demo

# Create resources from manifests
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
```

**What happens:**
1. ConfigMap created with environment variables
2. Deployment created: Kubernetes starts 3 pods
3. Service created: Load balancer routes traffic

---

### 6.4 Monitor Pod Creation

```bash
# Watch pods in real-time
kubectl get pods -w

# Output while creating:
# NAME                    READY   STATUS              RESTARTS   AGE
# demo-6f8d7c9b8-7k9vx   0/1     ContainerCreating   0          10s
# demo-6f8d7c9b8-8b2q4   0/1     ContainerCreating   0          10s
# demo-6f8d7c9b8-9c3r5   0/1     ContainerCreating   0          10s

# After ~30 seconds, all show:
# demo-6f8d7c9b8-7k9vx   1/1     Running             0          30s
# demo-6f8d7c9b8-8b2q4   1/1     Running             0          30s
# demo-6f8d7c9b8-9c3r5   1/1     Running             0          30s

# Press Ctrl+C to stop watching
```

---

### 6.5 Check Pod Details

```bash
# View all resources
kubectl get all

# Get detailed pod info
kubectl describe pod <pod-name>

# View pod logs (what stdout from app)
kubectl logs <pod-name>

# Follow logs in real-time
kubectl logs <pod-name> -f
```

---

### 6.6 Access Application

```bash
# Port-forward (exposes pod on localhost)
kubectl port-forward svc/demo 8080:80 &

# Wait 2 seconds
sleep 2

# Test endpoints
curl http://localhost:8080/api/status
# {"status":"UP","message":"System is running"}

curl http://localhost:8080/api/hello
# "Hello from Production-Ready GKE!"

# View service details
kubectl get svc
# Note: EXTERNAL-IP shows <pending> in Minikube (expected)
# This is normal - Minikube has no cloud provider for IP allocation
```

---

### 6.7 Test Auto-Healing

```bash
# Delete a pod
kubectl delete pod <pod-name>

# Watch pod get replaced
kubectl get pods -w

# New pod automatically created with same name
# Kubernetes ensures 3 replicas always running
```

---

### 6.8 View Service Status

```bash
# Check service details
kubectl describe svc demo

# Output shows:
# Endpoints: 10.244.0.4:8080, 10.244.0.5:8080, 10.244.0.6:8080
# (3 pods behind load balancer)
```

---

### ✨ Key Takeaways - Step 6

- ✅ kubectl installed and configured
- ✅ Minikube cluster running locally
- ✅ 3 pods deployed and running
- ✅ Endpoints tested and working
- ✅ Auto-healing verified
- ✅ Load balancing functional

---

---

## Step 7️⃣: Deploy to Google Kubernetes Engine (GKE)

**⏱️ Duration:** 45 minutes  
**📊 Difficulty:** Hard  
**🎯 Goal:** Deploy to production-like cloud environment

### What You'll Learn:
- Setting up GCP project
- Creating GKE cluster
- Deploying same manifests
- Getting real external IP

---

### Why GKE?

| Feature | Benefit |
|---------|---------|
| **Managed** | Google manages control plane, you just deploy |
| **Auto-scaling** | Automatically adds/removes nodes |
| **Multi-zone** | High availability |
| **Integrated with GCP** | Monitoring, logging, security built-in |
| **Production-ready** | Used by many companies |

---

### Minikube vs GKE

| Feature | Minikube | GKE |
|---------|----------|-----|
| **Nodes** | 1 local | 3+ cloud |
| **External IP** | `<pending>` | Real IP |
| **Cost** | Free | ~$10/month |
| **Latency** | Local | Internet |
| **Reliability** | Local | Highly available |

---

### 7.1 Set Up GCP Project

```bash
# Install gcloud CLI (if not already)
# Instructions: https://cloud.google.com/sdk/docs/install

# Initialize
gcloud init

# Login
gcloud auth login

# Create project
gcloud projects create devops-demo-PROJECT --name="DevOps Demo"

# Set as active project
gcloud config set project devops-demo-PROJECT

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
```

---

### 7.2 Create GKE Cluster

```bash
# Create cluster (takes 3-5 minutes)
gcloud container clusters create demo-cluster \
  --zone=us-central1-a \
  --num-nodes=3 \
  --machine-type=n1-standard-1 \
  --enable-autoscaling \
  --min-nodes=3 \
  --max-nodes=10

# Monitor creation:
gcloud container clusters list

# When READY shows True, proceed ↓
```

---

### 7.3 Configure kubectl for GKE

```bash
# Get credentials (kubectl can now access GKE)
gcloud container clusters get-credentials demo-cluster \
  --zone=us-central1-a

# Verify connection
kubectl cluster-info

# Should show: Kubernetes master is running at https://...
```

---

### 7.4 Deploy Same Manifests to GKE

```bash
# Navigate to project
cd /path/to/demo

# Deploy (same manifests as Minikube!)
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

# Watch pods create
kubectl get pods -w

# After 2-3 minutes, all show Running (1/1)
```

---

### 7.5 Get External IP

```bash
# Check service status
kubectl get svc

# Output:
# NAME    TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)        AGE
# demo    LoadBalancer   10.0.0.1        34.67.89.123   80:30123/TCP   2m

# Now EXTERNAL-IP shows real IP (not <pending>!)
# This is the difference from Minikube

# Save external IP
EXTERNAL_IP=$(kubectl get svc demo -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo $EXTERNAL_IP
```

---

### 7.6 Test GKE Deployment

```bash
# Test via public IP (works from anywhere!)
curl http://34.67.89.123/api/status
# {"status":"UP","message":"System is running"}

curl http://34.67.89.123/api/hello
# "Hello from Production-Ready GKE!"

# You can also share this URL with others
# Application is publicly accessible!
```

---

### 7.7 Cleanup (To Avoid Charges)

```bash
# When done learning, delete cluster
gcloud container clusters delete demo-cluster --zone=us-central1-a

# Delete project (optional)
gcloud projects delete devops-demo-PROJECT
```

---

### ✨ Key Takeaways - Step 7

- ✅ GCP project created
- ✅ GKE cluster deployed
- ✅ Same manifests deployed
- ✅ Real external IP obtained
- ✅ Publicly accessible application

---

---

# PHASE 3: AUTOMATION & PRODUCTION (Steps 8-10)
## 🔴 CI/CD Pipeline & Best Practices

---

## Step 8️⃣: Complete GitHub Actions CI/CD Pipeline

**⏱️ Duration:** 60 minutes  
**📊 Difficulty:** Hard  
**🎯 Goal:** Automate: build → test → push → deploy

### What You'll Create:
- GitHub Actions workflow
- Docker build step
- Docker push step
- GKE auto-deploy step

---

### What is GitHub Actions?

```
Developer pushes code
        ↓
GitHub Actions triggers automatically
        ↓
Runs workflow steps:
  1. Build Java with Maven
  2. Run tests
  3. Build Docker image
  4. Push to Docker Hub
  5. Deploy to GKE
        ↓
Application automatically updated!
```

---

### 8.1 Update GitHub Actions Workflow

**File Path:** `.github/workflows/ci-cd.yml`

Replace entire file:

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
  # Job 1: Build application
  build:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.image.outputs.tag }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
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
    
    - name: Get version
      id: image
      run: |
        VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
        echo "tag=$VERSION" >> $GITHUB_OUTPUT

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: |
          ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ steps.image.outputs.tag }}
          ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest

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
    
    - name: Get GKE credentials
      run: |
        gcloud container clusters get-credentials demo-cluster \
          --zone=us-central1-a \
          --project=${{ secrets.GCP_PROJECT_ID }}
    
    - name: Update deployment
      run: |
        kubectl set image deployment/demo demo=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ needs.build.outputs.image-tag }} \
          -n default \
          --record
    
    - name: Wait for rollout
      run: |
        kubectl rollout status deployment/demo \
          --timeout=5m
```

---

### 8.2 Create GitHub Secrets

**Navigate to GitHub:**
1. Your repo → Settings → Secrets and variables → Actions
2. Create these secrets:

#### Secret 1: DOCKER_USERNAME
```
Value: YOUR_DOCKER_HUB_USERNAME
```

#### Secret 2: DOCKER_PASSWORD
```
Create access token at https://hub.docker.com/settings/security
Generate token with read/write permissions
Paste entire token as value
```

#### Secret 3: GCP_PROJECT_ID
```bash
# Get from terminal
gcloud config get-value project

# Copy output and paste
Value: devops-demo-PROJECT
```

#### Secret 4: GKE_SA_KEY
```bash
# Create service account
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions"

# Grant permissions
gcloud projects add-iam-policy-binding devops-demo-PROJECT \
  --member=serviceAccount:github-actions@devops-demo-PROJECT.iam.gserviceaccount.com \
  --role=roles/container.developer

# Create key
gcloud iam service-accounts keys create key.json \
  --iam-account=github-actions@devops-demo-PROJECT.iam.gserviceaccount.com

# View and copy entire JSON
cat key.json

# Paste entire JSON as secret value
```

---

### 8.3 Test CI/CD Pipeline

```bash
# Make small change
echo "# Modified" >> README.md

# Commit to develop (build only)
git add .
git commit -m "Test CI/CD pipeline"
git push origin develop

# Or push to main to trigger deploy:
git push origin main
```

**Monitor in GitHub:**
1. Go to your repo
2. Click "Actions" tab
3. Watch workflow execute
4. Click on workflow run to see logs

---

### 8.4 CI/CD Workflow Steps

```
Push to GitHub
       ↓
[BUILD JOB]
├─ Checkout code ✓
├─ Setup Java 21 ✓
├─ Maven clean package ✓
├─ Maven test ✓
├─ Get version from pom.xml ✓
├─ Setup Docker ✓
├─ Login to Docker Hub ✓
└─ Build & push image ✓
       ↓
[DEPLOY JOB] (if main branch)
├─ Setup gcloud ✓
├─ Get GKE credentials ✓
├─ Update deployment image ✓
└─ Wait for rollout ✓
       ↓
✅ Application deployed!
```

---

### ✨ Key Takeaways - Step 8

- ✅ GitHub Actions workflow configured
- ✅ Build automation set up
- ✅ Docker push automated
- ✅ GKE deploy automated
- ✅ Secrets properly configured
- ✅ Full CI/CD pipeline working

---

---

## Step 9️⃣: Production Best Practices

**⏱️ Duration:** 30 minutes  
**📊 Difficulty:** Hard  
**🎯 Goal:** Add production-grade features

### What You'll Add:
- Environment-specific configs
- Secrets management
- Auto-scaling
- Monitoring

---

### 9.1 Environment-Specific ConfigMaps

Create separate configs for dev/prod:

**File Path:** `kubernetes/configmap-prod.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config-prod
data:
  SPRING_PROFILES_ACTIVE: "production"
  LOGGING_LEVEL_ROOT: "WARN"
  APP_CACHE_ENABLED: "true"
  APP_DEBUG: "false"
```

**File Path:** `kubernetes/configmap-dev.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config-dev
data:
  SPRING_PROFILES_ACTIVE: "development"
  LOGGING_LEVEL_ROOT: "DEBUG"
  APP_CACHE_ENABLED: "false"
  APP_DEBUG: "true"
```

---

### 9.2 Secrets Management

```bash
# Create Kubernetes secret
kubectl create secret generic demo-secrets \
  --from-literal=db-password=my-secure-password \
  --from-literal=api-key=my-api-key

# Use in deployment (add to containers section):
envFrom:
  - secretRef:
      name: demo-secrets
```

---

### 9.3 HorizontalPodAutoscaler (HPA)

**File Path:** `kubernetes/hpa.yaml`

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: demo-hpa
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

# Watch scaling (creates new pods if CPU > 70%)
kubectl get hpa -w
```

---

### 9.4 Monitoring & Logging

```bash
# View cluster logs
kubectl logs -f deployment/demo

# Get pod metrics (if metrics-server installed)
kubectl top pods

# Get node metrics
kubectl top nodes

# Describe pod for events
kubectl describe pod <pod-name>
```

---

### ✨ Key Takeaways - Step 9

- ✅ Environment configs created
- ✅ Secrets managed safely
- ✅ Auto-scaling configured
- ✅ Monitoring basics known

---

---

## Step 1️⃣0️⃣: Architecture Review & Summary

**⏱️ Duration:** 20 minutes  
**📊 Difficulty:** Medium  
**🎯 Goal:** Understand complete architecture

---

### Complete DevOps Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ DEVELOPER WORKFLOW                                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Code locally                                            │
│  2. git push origin main                                   │
│  3. GitHub detects push                                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ GITHUB ACTIONS (Automation)                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Build: Maven clean package                             │
│  2. Test: Maven test                                       │
│  3. Containerize: Docker build                             │
│  4. Push: Docker push to Hub                               │
│  5. Deploy: kubectl apply to GKE                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ DOCKER HUB (Registry)                                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  yours-username/demo:1.0.0                                │
│  yours-username/demo:latest                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ GOOGLE CLOUD (GKE Cluster)                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────── Node 1 ────────┐                               │
│  │  ┌─ Pod 1 (demo) ─┐  │                               │
│  │  │ Container:    │  │                               │
│  │  │ :/api/status  │  │                               │
│  │  │ :/api/hello   │  │                               │
│  │  └───────────────┘  │                               │
│  └────────────────────┘                                │
│                                                         │
│  ┌─────── Node 2 ────────┐                           │
│  │  ┌─ Pod 2 (demo) ─┐  │                           │
│  │  │ Container:    │  │                           │
│  │  │ :/api/status  │  │                           │
│  │  │ :/api/hello   │  │                           │
│  │  └───────────────┘  │                           │
│  └────────────────────┘                            │
│                                                     │
│  ┌─────── Node 3 ────────┐                       │
│  │  ┌─ Pod 3 (demo) ─┐  │                       │
│  │  │ Container:    │  │                       │
│  │  │ :/api/status  │  │                       │
│  │  │ :/api/hello   │  │                       │
│  │  └───────────────┘  │                       │
│  └────────────────────┘                        │
│                                                 │
│  LoadBalancer Service                          │
│  External IP: 34.67.89.123                     │
│  (Distributes traffic to 3 pods)               │
│                                                 │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│ PUBLIC INTERNET                                │
├─────────────────────────────────────────────────┤
│                                                 │
│ Users access: 34.67.89.123/api/status         │
│             : 34.67.89.123/api/hello          │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

### Complete File Structure

```
demo/
│
├── src/
│   ├── main/
│   │   ├── java/com/example/demo/
│   │   │   ├── DemoApplication.java
│   │   │   └── controller/DemoController.java
│   │   └── resources/
│   │       ├── application.properties
│   │       ├── application-dev.properties
│   │       └── application-prod.properties
│   └── test/...
│
├── kubernetes/
│   ├── configmap.yaml
│   ├── configmap-dev.yaml
│   ├── configmap-prod.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── hpa.yaml
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml
│
├── Dockerfile
├── .dockerignore
├── .gitignore
├── pom.xml
├── README.md
└── COMPLETE_DEVOPS_PIPELINE_STEPS.md
```

---

### Technology Stack Summary

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Application** | Spring Boot 4.0.4 | REST API |
| **Language** | Java 21 | JVM-based backend |
| **Build** | Maven 3.9 | Compile & package |
| **Container** | Docker | Wrap application |
| **Registry** | Docker Hub | Store images |
| **Orchestration** | Kubernetes | Manage containers |
| **Cloud** | GKE (Google Cloud) | Production deployment |
| **Automation** | GitHub Actions | CI/CD pipeline |
| **Version Control** | Git + GitHub | Source code management |

---

### Quick Command Reference

```bash
# ===== Local Development =====
mvn spring-boot:run      # Run app
mvn clean package        # Build
mvn test                 # Test

# ===== Docker =====
docker build -t demo:1.0.0 .                    # Build image
docker run -p 8080:8080 demo:1.0.0             # Run container
docker push USERNAME/demo:1.0.0                # Push to registry

# ===== Kubernetes (same for Minikube or GKE) =====
kubectl apply -f kubernetes/                   # Deploy
kubectl get pods                               # List pods
kubectl logs <pod-name>                        # View logs
kubectl describe pod <pod-name>                # Pod details
kubectl delete pod <pod-name>                  # Delete pod
kubectl get svc                                # List services
kubectl port-forward svc/demo 8080:80          # Access locally
kubectl rollout status deployment/demo         # Check status

# ===== GKE (Cloud) =====
gcloud container clusters create demo-cluster  # Create cluster
gcloud container clusters get-credentials demo-cluster  # Connect
gcloud container clusters delete demo-cluster  # Delete cluster

# ===== GitHub =====
git push origin main                           # Trigger CI/CD
git push origin develop                        # Build without deploy
```

---

### Learning Path Visualization

```
DAY 1 (2 hours)
├─ Step 1: Create Spring Boot project ✓
├─ Step 2: Git + GitHub setup ✓
└─ Step 3: Docker containerization ✓

DAY 2 (2 hours)
├─ Step 4: Docker Hub deployment ✓
├─ Step 5: Kubernetes manifests ✓
└─ Step 6: Minikube local testing ✓

DAY 3 (2 hours)
├─ Step 7: GKE cloud deployment ✓
├─ Step 8: GitHub Actions CI/CD ✓
└─ Step 9: Production best practices ✓

DAY 4 (1 hour)
└─ Step 10: Architecture review ✓

TOTAL: ~5-6 hours to production-grade pipeline!
```

---

### Production Checklist

- ✅ Application code versioned (Git)
- ✅ Docker image optimized (250MB)
- ✅ Kubernetes manifests defined (YAML)
- ✅ Local testing (Minikube)
- ✅ Cloud deployment (GKE)
- ✅ CI/CD automation (GitHub Actions)
- ✅ Health checks configured (K8s probes)
- ✅ Resource limits set (CPU/Memory)
- ✅ Load balancing active (3 replicas)
- ✅ Auto-healing enabled (Kubernetes)
- ✅ Monitoring ready (kubectl, GCP logs)
- ✅ Secrets managed safely (Kubernetes Secrets)
- ✅ Auto-scaling configured (HPA)

---

### Next Steps After This Guide

1. **Add Database:** PostgreSQL with persistent volumes
2. **Implement Authentication:** JWT tokens, OAuth2
3. **API Gateway:** Kong or nginx ingress
4. **Service Mesh:** Istio for advanced networking
5. **Monitoring Stack:** Prometheus + Grafana
6. **Logging:** ELK Stack or GCP Cloud Logging
7. **SSL Certificates:** Let's Encrypt integration
8. **Domain Name:** DNS setup for custom domain
9. **Backup & Disaster Recovery:** PV backups, cluster recovery
10. **Multi-region Deployment:** High availability setup

---

### ✨ Key Takeaways - Step 10

- ✅ Complete architecture understood
- ✅ All technologies integrated
- ✅ Production pipeline ready
- ✅ Ready for next steps

---

---

# 🎉 Congratulations!

You've built a **complete, production-grade DevOps pipeline!**

## What You've Accomplished:

✅ Created Spring Boot REST API  
✅ Set up Git version control with branching strategy  
✅ Containerized application with Docker  
✅ Pushed to Docker Hub registry  
✅ Deployed to local Kubernetes (Minikube)  
✅ Deployed to cloud Kubernetes (GKE)  
✅ Automated the entire pipeline with GitHub Actions  
✅ Implemented production best practices  

## Skills You've Learned:

- 🟢 **Backend Development:** Java 21, Spring Boot
- 🔵 **DevOps:** Docker, Kubernetes, CI/CD
- 🟣 **Cloud:** GCP, GKE
- 🔴 **Automation:** GitHub Actions
- 📊 **Architecture:** Microservices, scaling, monitoring

## You Can Now:

1. Deploy applications to production automatically
2. Scale applications based on load
3. Manage infrastructure as code
4. Implement continuous integration/deployment
5. Monitor and troubleshoot distributed systems
6. Collaborate with teams using Git Flow
7. Understand modern DevOps practices

---

## 📚 Recommended Learning Resources

- **Kubernetes Official Docs:** https://kubernetes.io/docs/
- **Docker Documentation:** https://docs.docker.com/
- **Spring Boot Guide:** https://spring.io/guides/gs/spring-boot/
- **GKE Documentation:** https://cloud.google.com/kubernetes-engine/docs
- **GitHub Actions:** https://docs.github.com/en/actions

---

## 💡 Pro Tips

1. **Start small:** Master one technology before combining them
2. **Read error messages:** They usually tell you exactly what's wrong
3. **Check logs:** Always look at pod logs when debugging
4. **Version everything:** Use semantic versioning for images
5. **Document decisions:** Note why you chose certain approaches
6. **Practice:** Deploy a few times to build muscle memory
7. **Keep learning:** DevOps evolves constantly

---

## 🚀 Ready for More?

- Add microservices architecture
- Implement service-to-service communication
- Set up distributed tracing (Jaeger)
- Deploy multiple environments (dev/staging/prod)
- Implement GitOps with ArgoCD
- Learn about service meshes (Istio)
- Master serverless (Cloud Functions)

---

**You're now a DevOps engineer! 🎓**

Good luck on your cloud journey! 🚀
