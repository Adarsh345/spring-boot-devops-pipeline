# Demo Application - Production-Ready Spring Boot App

A learning project demonstrating a complete DevOps pipeline with GitHub, Docker, Kubernetes, and GKE.

## 📋 Project Overview

- **Language:** Java 21
- **Framework:** Spring Boot 4.0.4
- **Build Tool:** Maven
- **Containerization:** Docker
- **Orchestration:** Kubernetes (GKE)
- **CI/CD:** GitHub Actions

## 🚀 Quick Start

### Prerequisites
- Java 21
- Maven 3.9+
- Docker (for containerization)

### Local Development

```bash
# Clone the repository
git clone https://github.com/<your-username>/demo.git
cd demo

# Run locally with Maven
mvn spring-boot:run
```

The application will start at `http://localhost:8080`

## 📡 API Endpoints

| Method | Endpoint | Response |
|--------|----------|----------|
| GET | `/api/status` | Returns system status |
| GET | `/api/hello` | Returns hello message |

### Example Requests

```bash
# Check status
curl http://localhost:8080/api/status

# Get hello message
curl http://localhost:8080/api/hello
```

## 🐳 Docker Usage

### Build Docker Image

```bash
docker build -t demo:1.0.0 .
```

### Run Container Locally

```bash
docker run -p 8080:8080 demo:1.0.0
```

### Push to Docker Hub

```bash
# Tag image for Docker Hub
docker tag demo:1.0.0 <your-dockerhub-username>/demo:1.0.0

# Push to registry
docker push <your-dockerhub-username>/demo:1.0.0
```

## ☸️ Kubernetes Deployment

### Prerequisites
- kubectl CLI
- Access to Kubernetes cluster (Minikube, Docker Desktop, or GKE)

### Deploy to Kubernetes

```bash
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
```

### Access the Application

```bash
# Port forward to access locally
kubectl port-forward svc/demo 8080:80

# Or get the external IP (if service type is LoadBalancer)
kubectl get service demo
```

## 🔄 CI/CD Pipeline

This project uses GitHub Actions for automated:
- Building Docker images
- Pushing to Docker Hub
- Deploying to GKE

See `.github/workflows/ci-cd.yml` for pipeline configuration.

## 📚 Documentation

- [DevOps Pipeline Guide](DEVOPS_GUIDE.md)
- [Architecture](ARCHITECTURE.md)

## 🛠️ Development

### Project Structure

```
src/
├── main/
│   ├── java/com/example/demo/
│   │   ├── DemoApplication.java
│   │   └── controller/
│   │       └── DemoController.java
│   └── resources/
│       └── application.properties
└── test/
    └── java/com/example/demo/
        └── DemoApplicationTests.java
```

### Configuration

Modify `src/main/resources/application.properties` for configuration.

## 📝 License

This project is for learning purposes.

## 🤝 Contributing

This is a learning project. Feel free to fork and experiment!
