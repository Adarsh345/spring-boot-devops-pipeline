# Git Branching Strategy Guide

## 🌳 Branch Structure

Your repository uses **Git Flow** - the industry-standard branching model.

```
main (Production)
  ↑
  └─ Pull Requests from develop
  
develop (Staging)
  ↑
  └─ Pull Requests from feature branches
  
feature/my-feature (Your Work)
```

---

## 📌 Branch Purposes

| Branch | Purpose | Who Controls | Deployment |
|--------|---------|--------------|-----------|
| `main` | Production code | Protected, requires PR + review | Auto-deploy (GKE) |
| `develop` | Integration/Staging | Team merges features here | Auto-deploy (staging) |
| `feature/*` | Individual features | Developer owns | Local testing |

---

## ⚡ Typical Workflow

### **1. Create Feature Branch from develop**

```bash
# Update develop branch
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/add-metrics
```

**Names should be descriptive:**
- ✅ `feature/add-health-endpoint`
- ✅ `feature/update-docker-image`
- ✅ `bugfix/fix-null-pointer-exception`
- ❌ `feature/fix` (too vague)

### **2. Make Changes (Commit Often)**

```bash
# Make changes to files
nano src/main/java/com/example/demo/controller/DemoController.java

# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: add metrics endpoint for monitoring

- Add GET /api/metrics endpoint
- Return JVM memory stats
- Add endpoint documentation to README"
```

### **3. Push Feature Branch to GitHub**

```bash
git push -u origin feature/add-metrics
```

### **4. Create Pull Request (PR) on GitHub**

- Go to: https://github.com/Adarsh345/spring-boot-devops-pipeline
- Click "Pull Requests" tab
- Click "New Pull Request"
- Base: `develop` ← Compare: `feature/add-metrics`
- Add description of changes
- Click "Create Pull Request"

### **5. Automated Testing & Review**

When you create a PR:
1. ✅ GitHub Actions CI/CD runs automatically
2. ✅ Tests execute
3. ✅ Docker image builds
4. ✅ Results show in PR

### **6. Merge PR to develop**

After review approval:
```bash
# Click "Merge Pull Request" on GitHub
# Then delete the feature branch
```

### **7. develop → main (Release)**

When ready for production:
1. Create PR: `develop` → `main`
2. More rigorous review
3. Merge to main
4. Auto-deployment to GKE

---

## 🔄 Current Repository Status

```
You are currently on: develop (staging branch)

Remote branches on GitHub:
- origin/main     (production code - 1 commit)
- origin/develop  (staging code - will receive feature PRs)

Next steps:
1. Create feature branches from develop
2. Push feature branches to GitHub
3. Create Pull Requests for review
4. Merge to develop (CI/CD runs)
5. Eventually merge develop → main for production
```

---

## 🚫 Protection Rules (Implemented in Step 8)

In Step 8 (CI/CD Setup) we'll add **branch protection rules**:

- ❌ Cannot push directly to `main` (must use PR)
- ❌ Cannot merge PR without CI/CD success
- ❌ Cannot merge PR without code review
- ✅ Force all changes through Pull Requests

---

## 📋 Example: Creating Your First Feature Branch

```bash
# Ensure you're on develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/add-logging

# Make changes, commit
git add .
git commit -m "feat: add structured logging

- Add SLF4J for structured logging
- Log requests/responses with correlation IDs
- Configure JSON logging for ELK stack"

# Push to GitHub
git push -u origin feature/add-logging

# Go to GitHub and create Pull Request
# Base: develop, Compare: feature/add-logging
```

---

## 💡 Commit Message Best Practices

Use conventional commits (industry standard):

```
type(scope): subject

body (optional)

footer (optional)
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `test:` - Test changes
- `chore:` - Build, dependencies, CI/CD
- `perf:` - Performance improvement
- `refactor:` - Code refactoring

**Example:**
```
feat(api): add health check endpoint

- New GET /api/health endpoint
- Returns service status and version
- Used by Kubernetes liveness probe

Closes #42
```

---

## 🔍 Viewing Branches

```bash
# List local branches
git branch

# List all branches (local + remote)
git branch -a

# Show branch tracking
git branch -vv

# Delete old feature branch locally
git branch -d feature/old-feature

# Delete remote feature branch
git push origin --delete feature/old-feature
```

---

## 🆘 Common Operations

### Switch between branches
```bash
git checkout main
git checkout develop
git checkout feature/my-feature
```

### Update current branch with latest code
```bash
git pull origin feature/my-feature
```

### See what changed
```bash
git log --oneline -10          # Last 10 commits
git diff feature/my-feature    # See all changes
```

---

## 🎯 Your Next Steps

1. ✅ Branching strategy is set up
2. When ready: Create a feature branch and make changes
3. Push to GitHub
4. Create a Pull Request
5. We'll test CI/CD with your PR

This prepares you for **Step 3: Dockerization**
