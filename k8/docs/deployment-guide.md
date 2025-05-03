# Kubernetes Deployment Guide

## Overview
This guide explains how to deploy the application to Kubernetes using Kustomize. The deployment structure is organized into base configurations and environment-specific overlays.

## Prerequisites
- Kubernetes cluster
- kubectl configured
- Docker registry access
- Metrics Server installed

### Installing Metrics Server
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Project Structure
```
k8s/
├── _base/                    # Core configurations
│   ├── namespace.yaml      # Namespace definition
│   ├── workloads/          # Application components
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── hpa.yaml
│   └── kustomization.yaml
├── _overlays/               # Environment-specific configs
│   ├── dev/
│   └── prod/
└── docs/                   # Documentation
```

## Deployment Steps

### 1. Build and Push Docker Image
```bash
# Build the image
docker build -t your-docker-username/appxhub:latest -f dockerfile .

# Push to registry
docker push your-docker-username/appxhub:latest
```

### 2. Update Image Configuration
Edit `_base/kustomization.yaml`:
```yaml
images:
- name: appxhub
  newName: your-docker-username/appxhub
  newTag: latest
```

### 3. Apply the namespace file 
```bash
kubectl apply -f _base/appxhub-namespace.yml
```

### 4. Deploy to Development
```bash
kubectl apply -k _overlays/dev/
```

### 5. Deploy to Production
```bash
kubectl apply -k _overlays/prod/
```

### Development Environment
- Namespace: appxhub-dev
- Replicas: 1
- Resource Limits:
  - CPU: 200m
  - Memory: 128Mi

### Production Environment
- Namespace: appxhub-prod
- Replicas: 3
- Resource Limits:
  - CPU: 500m
  - Memory: 512Mi

### Pipeline Steps
1. Build and test application
2. Build Docker image
3. Push to registry
4. Update image tag in kustomization
5. Apply Kubernetes manifests
6. Run post-deployment tests

## Monitoring and Scaling

### Horizontal Pod Autoscaling
- CPU utilization target: 80%
- Min replicas: 1 (dev) / 3 (prod)
- Max replicas: 3 (dev) / 5 (prod)

### Monitoring
```bash
# Check deployment status
kubectl get deployments -n dev
kubectl get deployments -n prod

# Check pod status
kubectl get pods -n dev
kubectl get pods -n prod

# Check HPA status
kubectl get hpa -n dev
kubectl get hpa -n prod
```

## Troubleshooting

### Common Issues

1. **Image Pull Errors**
   - Verify image name and tag in kustomization.yaml
   - Check Docker registry credentials
   - Ensure network connectivity to registry

2. **Resource Issues**
   - Check resource requests/limits
   - Verify node capacity
   - Check for resource quotas

3. **HPA Not Working**
   - Verify Metrics Server installation
   - Check HPA configuration
   - Monitor CPU utilization

### Logs and Debugging
```bash
# View pod logs
kubectl logs <pod-name> -n dev
kubectl logs <pod-name> -n prod

# Describe resources for details
kubectl describe deployment appxhub -n dev
kubectl describe hpa appxhub -n dev
```

## Security Notes
- Environment files (.env*) are committed to the repository to allow ease of use for practice deployments. However, do not do this in a real-world scenario.
- Each environment runs in its own namespace.
- Production environment has stricter resource limits.
- Secrets are managed separately from the repository.

## Maintenance

### Updating Deployments
1. Make changes to base or overlay configurations
2. Apply changes:
   ```bash
   kubectl apply -k _overlays/dev/
   kubectl apply -k _overlays/prod/
   ```

### Rolling Back
```bash
kubectl rollout undo deployment/appxhub -n dev
kubectl rollout undo deployment/appxhub -n prod
```