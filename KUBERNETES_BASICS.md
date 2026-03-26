# Kubernetes Basics - Complete Guide

## 🎯 What is Kubernetes?

**Kubernetes (K8s)** is a container **orchestration platform**. It's what you use when Docker isn't enough.

### **The Problem Kubernetes Solves**

```
Without Kubernetes (Just Docker):
┌─────────────────────────────────────────┐
│ Server 1          Server 2               │
│ ┌────────┐        ┌────────┐            │
│ │ demo:1 │        │ demo:1 │  Manual    │
│ │ PID 123│        │ PID 456│  setup &   │
│ └────────┘        └────────┘  mgmt!     │
│                                          │
│ Server crashed? Manual restart 😞       │
│ Too much traffic? Manually add servers  │
│ Need updates? Manual restart on each    │
└─────────────────────────────────────────┘

With Kubernetes:
┌──────────────────────────────────────────────┐
│           Kubernetes Cluster                  │
│  ┌──────────────────────────────────────┐   │
│  │  "Run 3 copies of demo:1.0.0"        │   │
│  │  Kubernetes handles everything:      │   │
│  │  - Auto-restart failed pods          │   │
│  │  - Auto-scale if traffic increases   │   │
│  │  - Zero-downtime rolling updates     │   │
│  │  - Load balancing traffic            │   │
│  │  - Health monitoring                 │   │
│  │  - Resource allocation               │   │
│  └──────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
```

---

## 📦 Core Kubernetes Concepts

### **1. Pod (Smallest Unit)**

A **Pod** is the smallest deployable unit in Kubernetes. It usually contains:
- 1 Container (your Docker image)
- Unique IP address
- Shared storage (optional)
- Networking configuration

```
Think of a Pod like a:
- Docker container wrapper
- Lightweight VM
- Single IP address
- Can contain 1-2 containers (usually 1)

Pod ✓ (Deployment): 1 app container
Pod ✗ (Deployment): Multiple app containers (use separate pods)
Pod ✓ (Advanced): 1 app + 1 sidecar logging container
```

### **2. Deployment (Run Multiple Pods)**

A **Deployment** tells Kubernetes:
- What image to run
- How many copies (replicas)
- How to update
- Resource limits
- Health checks

```
Deployment = Template + Controller

Deployment:
"Run 3 copies of demo:1.0.0 always.
 If one crashes, start another.
 If I say 5, scale up to 5.
 If I say 1, scale down to 1."

Result:
Pod 1 ──────┐
Pod 2 ──────┼─> All identical copies
Pod 3 ──────┘
```

### **3. Service (Expose Pods)**

A **Service** provides:
- Stable IP address (Pods get random IPs)
- Load balancing (distributes traffic)
- External access point
- Internal DNS name

```
Without Service:
Pod 1 (IP: 10.0.0.1) ┐
Pod 2 (IP: 10.0.0.2) ├─> Client doesn't know which to talk to
Pod 3 (IP: 10.0.0.3) ┘   Pods die/restart with new IPs

With Service:
┌─────────────────────────────┐
│  Service: demo              │
│  IP: 10.1.1.1 (Stable)     │
│  Port: 80                   │
└──────────┬──────────────────┘
           │ Load Balancer
        ┌──┴──┬──────┬──────┐
        │     │      │      │
    Pod 1  Pod 2  Pod 3   New Pod
                         (Replacement)
Client always connects to Service IP!
```

### **4. ConfigMap (Configuration Data)**

A **ConfigMap** stores configuration separate from code:
- Environment variables
- Config files
- Mounted as volumes or env vars

```
ConfigMap (demo-config):
  SPRING_PROFILES_ACTIVE: prod
  SERVER_PORT: 8080
  LOGGING_LEVEL_ROOT: INFO

Pod reads ConfigMap:
  env: [SPRING_PROFILES_ACTIVE=prod, ...]
  Spring Boot reads and applies config!
```

---

## 🏗️ Kubernetes Architecture

### **How Everything Works Together**

```
┌─────────────────────────────────────────────────────────────┐
│                 Kubernetes Cluster                           │
│                                                              │
│ ┌────────────────────────────────────────────────────────┐ │
│ │  Master/Control Plane (Manages cluster)                │ │
│ │  ┌──────────────────────────────────────────────────┐ │ │
│ │  │ API Server - Receives your commands              │ │ │
│ │  │               (kubectl apply -f deployment.yaml) │ │ │
│ │  ├──────────────────────────────────────────────────┤ │ │
│ │  │ Scheduler - Decides which Node runs each Pod     │ │ │
│ │  ├──────────────────────────────────────────────────┤ │ │
│ │  │ Controller - Ensures desired state               │ │ │
│ │  │ (3 replicas? Have exactly 3!)                    │ │ │
│ │  ├──────────────────────────────────────────────────┤ │ │
│ │  │ etcd - Stores all cluster data                   │ │ │
│ │  └──────────────────────────────────────────────────┘ │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                              │
│ ┌────────────────────────────────────────────────────────┐ │
│ │  Worker Node 1                                         │ │
│ │  ┌──────────────────────────────────────────────────┐ │ │
│ │  │ kubelet - Manages pods on this node             │ │ │
│ │  │ ┌──────────┐        ┌──────────┐                │ │ │
│ │  │ │ Pod 1    │        │ Pod 2    │                │ │ │
│ │  │ │demo:1.0.0│        │demo:1.0.0│                │ │ │
│ │  │ │Port: 8080│        │Port: 8080│                │ │ │
│ │  │ └──────────┘        └──────────┘                │ │ │
│ │  └──────────────────────────────────────────────────┘ │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                              │
│ ┌────────────────────────────────────────────────────────┐ │
│ │  Worker Node 2                                         │ │
│ │  ┌──────────────────────────────────────────────────┐ │ │
│ │  │ kubelet - Manages pods on this node             │ │ │
│ │  │ ┌──────────┐                                    │ │ │
│ │  │ │ Pod 3    │                                    │ │ │
│ │  │ │demo:1.0.0│                                    │ │ │
│ │  │ │Port: 8080│                                    │ │ │
│ │  │ └──────────┘                                    │ │ │
│ │  └──────────────────────────────────────────────────┘ │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                              │
│ ┌────────────────────────────────────────────────────────┐ │
│ │  Service "demo" (LoadBalancer)                         │ │
│ │  External IP: 34.123.45.67:80                         │ │
│ │  Routes to: Pod1, Pod2, Pod3 (load balance)           │ │
│ └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 📄 Understanding Our YAML Files

### **File 1: ConfigMap (demo-config)**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config
  labels:
    app: demo
data:
  SPRING_PROFILES_ACTIVE: "prod"
  SERVER_PORT: "8080"
  LOGGING_LEVEL_ROOT: "INFO"
  APP_NAME: "demo-app"
  APP_VERSION: "1.0.0"
```

**Explanation:**

| Section | Meaning |
|---------|---------|
| `apiVersion: v1` | Kubernetes API version (v1 = stable) |
| `kind: ConfigMap` | Type of resource we're creating |
| `metadata.name: demo-config` | Name to reference in Deployment |
| `data:` | Key-value configuration pairs |

**What happens:**
1. Kubernetes creates a ConfigMap named `demo-config`
2. Stores configuration as key-value pairs
3. Deployment references it with `envFrom.configMapRef.name`
4. Spring Boot reads these as environment variables
5. Different configs for dev/staging/prod possible

---

### **File 2: Deployment (deployment.yaml)**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
  labels:
    app: demo
    version: v1
spec:
  replicas: 3                    # Run 3 copies
  selector:
    matchLabels:
      app: demo                  # Find pods labeled "app: demo"
  template:
    metadata:
      labels:
        app: demo                # Label this pod "app: demo"
    spec:
      containers:
      - name: demo
        image: demo:latest       # Docker image (local or Docker Hub)
        imagePullPolicy: IfNotPresent   # Use local if available
        
        ports:
        - containerPort: 8080
          name: http
          
        envFrom:
        - configMapRef:
            name: demo-config    # Load config from ConfigMap
            
        resources:               # Resource limits
          requests:              # Minimum to allocate
            cpu: 100m            # 0.1 CPU core
            memory: 256Mi        # 256 MB RAM
          limits:                # Maximum allowed
            cpu: 500m            # 0.5 CPU core
            memory: 512Mi        # 512 MB RAM
            
        livenessProbe:           # Is the app alive?
          httpGet:
            path: /api/status
            port: 8080
          initialDelaySeconds: 30  # Wait 30s before first check
          periodSeconds: 10        # Check every 10s
          failureThreshold: 3      # Restart after 3 failures
          
        readinessProbe:          # Is the app ready for traffic?
          httpGet:
            path: /api/status
            port: 8080
          initialDelaySeconds: 10  # Wait 10s before first check
          periodSeconds: 5         # Check every 5s
          failureThreshold: 3      # Remove from service after 3 failures
          
        lifecycle:
          preStop:               # Before stopping pod
            exec:
              command: ["/bin/sh", "-c", "sleep 15"]  # Wait 15 seconds
```

**Line-by-Line Explanation:**

| Line | Purpose | Why It Matters |
|------|---------|-----------------|
| `replicas: 3` | Run 3 copies always | If 1 dies, 2 remain; K8s starts 1 more |
| `selector.matchLabels.app: demo` | Find pods with label "app: demo" | Tells Deployment which pods to manage |
| `image: demo:latest` | Docker image to run | Pulls from Docker Hub (adarshtripathi111/demo:latest) |
| `imagePullPolicy: IfNotPresent` | Use local if exists | Faster, no Docker Hub pull on rebuild |
| `containerPort: 8080` | Port app listens on | Spring Boot runs on 8080 |
| `envFrom.configMapRef` | Load config from ConfigMap | Pods get env vars from demo-config |
| `requests: cpu/memory` | Minimum resources | K8s won't schedule pod without this |
| `limits: cpu/memory` | Maximum resources | Pod killed if it exceeds this |
| `livenessProbe` | "Is app alive?" check | Restarts pod if health check fails |
| `readinessProbe` | "Is app ready?" check | Removes from Service if not ready |
| `lifecycle.preStop` | Before shutdown | Gives app 15s to finish requests |

---

### **File 3: Service (service.yaml)**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo
  labels:
    app: demo
spec:
  type: LoadBalancer          # Expose externally with IP
  selector:
    app: demo                 # Route to pods labeled "app: demo"
  ports:
  - protocol: TCP
    port: 80                  # External port (what client uses)
    targetPort: 8080          # Internal port (pod listens here)
    name: http
```

**Explanation:**

| Line | Meaning |
|------|---------|
| `type: LoadBalancer` | Create external IP address |
| `selector.app: demo` | Find all pods with label "app: demo" |
| `port: 80` | Listen on port 80 (external) |
| `targetPort: 8080` | Forward to port 8080 (pod) |

**How traffic flows:**

```
Client connects to: 34.123.45.67:80

Service listens on 80
    ↓
Route to Pod 1 (10.0.0.1:8080)    ┐
Route to Pod 2 (10.0.0.2:8080)    ├─ Load balanced
Route to Pod 3 (10.0.0.3:8080)    ┘

Spring Boot on pod:8080 handles request
    ↓
Response back to client
```

---

## 🔄 Kubernetes Workflow

### **Deployment Process (Step-by-Step)**

```
1. You run:
   kubectl apply -f kubernetes/configmap.yaml
   
   Kubernetes:
   ✓ Creates ConfigMap "demo-config"
   ✓ Stores configuration

2. You run:
   kubectl apply -f kubernetes/deployment.yaml
   
   Kubernetes:
   ✓ Creates Deployment "demo"
   ✓ Scheduler places pods on nodes
   ✓ kubelet pulls image (adarshtripathi111/demo:1.0.0)
   ✓ Starts 3 Pod replicas
   ✓ Loads ConfigMap variables
   ✓ Spring Boot starts
   ✓ Health checks pass
   
3. You run:
   kubectl apply -f kubernetes/service.yaml
   
   Kubernetes:
   ✓ Creates LoadBalancer Service
   ✓ Allocates external IP
   ✓ Routes traffic to Pod endpoints
   ✓ load balances across 3 pods

4. Result:
   External IP: 34.123.45.67
   Client: curl http://34.123.45.67/api/status
   Service routes to Pod 1, 2, or 3 (auto-load balanced)
```

---

## 🛡️ Production Features We Implemented

### **1. Health Checks**

```yaml
livenessProbe:           # "Is app dead?"
  httpGet:
    path: /api/status   # Check endpoint
    port: 8080
  initialDelaySeconds: 30
  failureThreshold: 3    # Restart after 3 failures

readinessProbe:          # "Can I send traffic?"
  httpGet:
    path: /api/status
    port: 8080
  initialDelaySeconds: 10
  failureThreshold: 3    # Remove from service if failing
```

**Kubernetes uses this for:**
- ✅ Auto-restart dead pods (liveness)
- ✅ Don't send traffic to starting pods (readiness)
- ✅ Remove unhealthy pods from load balancer

### **2. Resource Management**

```yaml
resources:
  requests:           # "I need at least this"
    cpu: 100m         # 100 millicores = 0.1 CPU
    memory: 256Mi     # 256 MB RAM
  limits:             # "Don't go above this"
    cpu: 500m         # 500 millicores = 0.5 CPU
    memory: 512Mi     # 512 MB RAM
```

**Kubernetes uses this for:**
- ✅ Schedule pods on nodes with enough resources
- ✅ Prevent pod from consuming all node resources
- ✅ Kill pod if it exceeds limits (OOMKilled)

### **3. Graceful Shutdown**

```yaml
lifecycle:
  preStop:                    # Before killing pod
    exec:
      command: ["/bin/sh", "-c", "sleep 15"]
```

**What happens:**
1. K8s sends TERM signal to app
2. Wait 15 seconds (app finishes requests)
3. App closes connections gracefully
4. After 15s, K8s force kills if needed
5. **Result: No dropped connections during updates!**

### **4. Rolling Updates**

```
When you deploy new version (1.0.1):

Current State:
Pod 1 (1.0.0) ─┐
Pod 2 (1.0.0) ─┼─ Service routes traffic
Pod 3 (1.0.0) ─┘

Update Step 1 (Create new pod):
Pod 1 (1.0.0) ─┐
Pod 2 (1.0.0) ─┼─ Service routes traffic
Pod 3 (1.0.0) ─┤
Pod 4 (1.0.1) ─┘ New pod starting

Update Step 2 (Remove old pod):
Pod 1 (1.0.0) ─┐
Pod 2 (1.0.0) ─┼─ Service routes traffic
Pod 3 (1.0.1) ─┤
                ─ (Pod 4 older 1.0.0 removed)

Result:
- ✅ Zero downtime
- ✅ Traffic always handled
- ✅ Old pods gradually replaced
- ✅ Rollback available (revert to 1.0.0)
```

---

## 🎮 Kubernetes Commands You'll Use

### **Apply Configuration**

```bash
# Create resources from YAML
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

# Or all at once
kubectl apply -f kubernetes/
```

### **Check Status**

```bash
# List pods
kubectl get pods

# List deployments
kubectl get deployments

# List services
kubectl get services

# Describe pod (detailed info)
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow logs
```

### **Update Deployment**

```bash
# Change number of replicas
kubectl scale deployment demo --replicas=5

# Update image version
kubectl set image deployment/demo demo=adarshtripathi111/demo:1.0.1

# Rollback to previous version
kubectl rollout undo deployment/demo
```

### **Debug**

```bash
# Get into a pod
kubectl exec -it <pod-name> -- /bin/sh

# Port forward to local machine
kubectl port-forward pod/<pod-name> 8080:8080

# Watch resources
kubectl get pods --watch

# Delete resources
kubectl delete deployment demo
kubectl delete service demo
```

---

## 📊 What Each YAML Does

```
┌──────────────────────────────┐
│ configmap.yaml               │
│ Creates: demo-config         │
│ Contains: Environment vars   │
│ Size: Small (config only)    │
└──────────────────────────────┘
          ↓
         Uses ↓
┌──────────────────────────────┐
│ deployment.yaml              │
│ Creates: Deployment "demo"   │
│ Runs: 3 Pod replicas         │
│ Image: adarshtripathi111/demo:latest │
│ Config: From demo-config     │
│ Health: Liveness + Readiness │
└──────────────────────────────┘
          ↓
       Managed ↓
┌──────────────────────────────┐
│ service.yaml                 │
│ Creates: Service "demo"      │
│ Type: LoadBalancer           │
│ Routes: Traffic to 3 pods    │
│ Port: 80 → 8080             │
└──────────────────────────────┘
          ↓
       Exposes ↓
┌──────────────────────────────┐
│ External IP: 34.123.45.67   │
│ Available: Globally          │
│ Load balanced across 3 pods  │
└──────────────────────────────┘
```

---

## 🚀 Next Steps

Your YAML files are production-ready. In **Step 6**, we'll:

1. **Install Minikube** - Local Kubernetes cluster (for testing)
2. **Deploy locally** - Run your app on Minikube
3. **Test endpoints** - Verify everything works
4. **Monitor pods** - Watch Kubernetes magic happen
5. **Scale replicas** - Test auto-scaling features

This is where the DevOps magic becomes real! 🎉

---

## 📋 Kubernetes Concepts Summary

| Concept | What It Is | Why Needed |
|---------|-----------|-----------|
| **Pod** | Container wrapper | Smallest deployable unit |
| **Deployment** | Pod manager | Ensures desired replicas |
| **Service** | Network expose | External access + load balance |
| **ConfigMap** | Config storage | Separate config from code |
| **Liveness** | Health check (alive?) | Auto-restart dead pods |
| **Readiness** | Health check (ready?) | Don't send traffic if starting |
| **Resources** | CPU/Memory limits | Prevent resource hogging |
| **Replicas** | Number of copies | High availability + scaling |

---

## ✅ What You Now Understand

✅ **Problem Kubernetes Solves** - Manual container management → Automated orchestration  
✅ **Core Concepts** - Pods, Deployments, Services, ConfigMaps  
✅ **Our YAML Files** - What each line does and why  
✅ **Architecture** - How components work together  
✅ **Production Features** - Health checks, resource limits, graceful shutdown  
✅ **Workflow** - How to deploy and update  
✅ **Commands** - How to interact with K8s  

You're now ready for **Step 6: Local Kubernetes Testing!** 🎉
