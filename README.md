# DevOps Capstone Project

This project is a comprehensive DevOps implementation that combines multiple technologies and tools to create a modern, scalable, and maintainable application infrastructure. The project includes a React-based frontend application, containerization with Docker, Kubernetes orchestration, Infrastructure as Code with Terraform, automation with Ansible, and a robust CI/CD pipeline using GitHub Actions for continuous integration and deployment. The CI/CD pipeline automates testing, building, and deployment processes, ensuring consistent and reliable delivery of the application across different environments.

## Project Structure

```
.
├── app/                  # React frontend application
├── k8/                  # Kubernetes configurations
├── terraform_argocd/    # Terraform configurations for ArgoCD
├── ansible/            # Ansible playbooks and configurations
└── .github/            # GitHub Actions workflows
```

## Prerequisites

Before you begin, ensure you have the following installed:
- Node.js (v14 or higher)
- Docker
- Kubernetes (kubectl)
- Terraform
- Ansible
- Git

## Getting Started

### 1. Frontend Application Setup

The frontend is a React application located in the `app` directory.

```bash
cd app
npm install
npm start
```

The application will be available at `http://localhost:3000`

### 2. Docker Containerization

The application is containerized using Docker. Build and run the container:

```bash
# From the app directory
docker build -t my-app .
docker run -p 3000:3000 my-app
```

### 3. Kubernetes Deployment

The Kubernetes configurations are located in the `k8` directory. The setup includes:
- Base configurations in `k8/_base`
- Environment-specific overlays in `k8/_overlays`
- Documentation in `k8/docs`

To deploy to Kubernetes, first apply the base configuration and then the environment-specific overlay:

For Development Environment:
```bash
# Apply development overlay
kubectl apply -k k8/_overlays/dev
```

For Production Environment:
```bash
# Apply production overlay
kubectl apply -k k8/_overlays/prod
```

### 4. Infrastructure as Code (Terraform)

The Terraform configurations for ArgoCD are located in `terraform_argocd/`. To initialize and apply:

```bash
cd terraform_argocd
terraform init
terraform plan
terraform apply
```

### 5. Ansible Automation

Ansible playbooks and configurations are in the `ansible/` directory. These can be used for:
- Server provisioning
- Configuration management
- Application deployment

## Environment Variables

Required environment variables are documented in `app/env-variables.md`. Make sure to set these up before running the application.

## Development Workflow

1. Make changes to the React application in the `app` directory
2. Test locally using `npm start`
3. Build and test the Docker container
4. Update Kubernetes configurations if needed
5. Deploy using the provided CI/CD pipeline

## CI/CD Pipeline

The project uses GitHub Actions for continuous integration and deployment. The workflows are defined in the `.github/workflows` directory.

## Monitoring and Logging

- Kubernetes dashboard for cluster monitoring
- Application logs can be accessed through kubectl:
  ```bash
  kubectl logs <pod-name>
  ```

## Security Considerations

- All sensitive information should be stored in Kubernetes secrets
- Environment variables should never be committed to version control
- Regular security updates should be applied to all dependencies

## Troubleshooting

Common issues and their solutions:
1. If the application fails to start, check the environment variables
2. For Kubernetes deployment issues, verify the configurations in `k8/_base`
3. For Docker build issues, ensure the Dockerfile is properly configured

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue in the GitHub repository or contact the development team. 