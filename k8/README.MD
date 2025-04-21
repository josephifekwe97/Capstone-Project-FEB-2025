# Kubernetes Application Deployment

This repository contains Kubernetes configurations for deploying applications in both development and production environments using Kustomize.

## Prerequisites

Before proceeding with the deployment, ensure you have the following:

1. Kubernetes cluster up and running
2. kubectl configured to access your cluster
3. Metrics Server installed (required for HPA to function)
4. Docker installed and configured
5. Access to a Docker registry (Docker Hub, private registry, etc.)

### Installing Metrics Server

If you don't have Metrics Server installed, run the following command:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Image Preparation

Before deploying to Kubernetes, you need to build and push your Docker image:

1. Build the Docker image:
   ```bash
   docker build -t your-docker-username/appxhub:latest -f dockerfile .
   ```

2. Push the image to your Docker registry:
   ```bash
   docker push your-docker-username/appxhub:latest
   ```

3. Update the image references in the deployment files:
   - In `_base/workloads/appxhub_deploy.yml`
   - In `dev/appxhub_dev-deploy.patch.yml`
   - In `prod/appxhub_prod-deploy.patch.yml`

   Replace the image name with your Docker image path:
   ```yaml
   spec:
     containers:
     - name: appxhub
       image: your-docker-username/appxhub:latest
   ```

## Project Structure

```
.
├── _base/                  # Base configurations
│   ├── workloads/         # Core workload definitions
│   │   ├── appxhub_deploy.yml    # Deployment configuration
│   │   ├── appxhub_hpa.yml       # Horizontal Pod Autoscaler
│   │   └── appxhub_svc.yml       # Service configuration
│   ├── kustomization.yml  # Base kustomization
│   └── appxhub-namespace.yml     # Namespace definition
├── dev/                   # Development environment
│   ├── kustomization.yml  # Dev environment kustomization
│   ├── appxhub_dev-*.patch.yml   # Dev-specific patches
│   └── .env.dev*         # Development environment variables
├── prod/                  # Production environment
│   ├── kustomization.yml  # Prod environment kustomization
│   ├── appxhub_prod-*.patch.yml  # Prod-specific patches
│   └── .env.prod*        # Production environment variables
├── compose.yml           # Docker Compose configuration
└── dockerfile           # Docker build configuration
```

## Deployment Steps

### 1. Create Namespace

First, create the namespace for the application:

```bash
kubectl apply -f _base/appxhub-namespace.yml
```

### 2. Deploy to Development Environment

To deploy to the development environment:

```bash
kubectl apply -k dev/
```

### 3. Deploy to Production Environment

To deploy to the production environment:

```bash
kubectl apply -k prod/
```

## Environment Configuration

Both development and production environments have their own configuration files:

- `.env.dev` and `.env.dev.config` for development
- `.env.prod` and `.env.prod.config` for production

These files are automatically ignored by Git (see .gitignore).

## Monitoring and Scaling

The application includes Horizontal Pod Autoscaling (HPA) configurations in both environments. The HPA will automatically scale the application based on CPU utilization.

## Accessing the Application

After deployment, you can access the application using the service endpoints:

- Development: `kubectl get svc -n appxhub-dev`
- Production: `kubectl get svc -n appxhub-prod`

## Maintenance

To update the deployment:

1. Make your changes to the appropriate configuration files
2. Apply the changes using the corresponding kustomize command:
   ```bash
   # For development
   kubectl apply -k dev/
   
   # For production
   kubectl apply -k prod/
   ```

## Troubleshooting

If you encounter any issues:

1. Check the status of your pods:
   ```bash
   kubectl get pods -n appxhub-dev
   kubectl get pods -n appxhub-prod
   ```

2. View pod logs:
   ```bash
   kubectl logs <pod-name> -n appxhub-dev
   kubectl logs <pod-name> -n appxhub-prod
   ```

3. Verify HPA status:
   ```bash
   kubectl get hpa -n appxhub-dev
   kubectl get hpa -n appxhub-prod
   ```

## Security Notes

- Environment files (`.env.*`) are not committed to the repository
- Each environment runs in its own namespace for isolation
- Production environment has stricter resource limits and higher replica counts
