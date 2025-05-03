# Kubernetes Application Deployment

This repository contains Kubernetes configurations for deploying applications in both development and production environments using Kustomize. The configuration is designed to be easily integrated with CI/CD pipelines while maintaining clear separation between environments.

## Features

- 🚀 **Multi-environment Support**: Separate configurations for development and production
- 📊 **Auto-scaling**: Horizontal Pod Autoscaling (HPA) for dynamic resource management
- 🔒 **Security**: Environment-specific secrets and configmaps
- 📦 **Containerized**: Docker-based deployment
- 🔄 **CI/CD Ready**: Structured for easy integration with deployment pipelines

## Quick Start

1. **Prerequisites**
   ```bash
   # Install Metrics Server
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   ```

2. **Deploy**
   ```bash
   # Namespace
   kubectl apply -f _base/appxhub-namespace.yml

   # Development
   kubectl apply -k _overlays/dev/

   # Production
   kubectl apply -k _overlays/prod/
   ```

## Project Structure

```
k8s/
├── _base/                    # Core configurations
├── _overlays/               # Environment-specific configs
│   ├── dev/               # Development environment
│   └── prod/              # Production environment
└── docs/                  # Documentation
```

## Documentation

- [Deployment Guide](docs/deployment-guide.md): Detailed instructions for deployment and maintenance
- [Troubleshooting](docs/deployment-guide.md#troubleshooting): Common issues and solutions
- [CI/CD Integration](docs/deployment-guide.md#cicd-integration): Pipeline setup and configuration

## Environment Configuration

| Environment | Namespace    | Replicas | CPU Limit | Memory Limit |
|------------|-------------|----------|-----------|--------------|
| Development| appxhub-dev | 1        | 200m      | 128Mi        |
| Production | appxhub-prod| 3        | 500m      | 512Mi        |

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Security

- Environment files (.env*) are committed to the repository to allow ease of use for practice deployments. However, do not do this in a real-world scenario.
- Each environment runs in its own namespace.
- Production environment has stricter resource limits.
- Secrets are managed separately from the repository.


## License

This project is licensed under the MIT License - see the LICENSE file for details.