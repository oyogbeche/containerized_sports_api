# Containerized NFL API
The Containerized NFL Sports API Project is a modern, scalable application designed to provide NFL game schedules through a RESTful API. The project integrates various AWS services and tools to deliver a robust and secure platform. It includes a frontend web UI that displays the game schedule and allows users to poll for schedule updates.

## Features 
- **SERPAPI:** Provides up-to-date NFL schedule data.
- **Polling for Updates:** Users can request the latest schedule updates via the web UI.
- **Frontend Web UI:** Interactive and user-friendly interface to display schedules.
- **Authentication:** API is secured with Auth0.
- **CI/CD Pipeline:** Automated build and deployment pipeline using GitHub Actions.
- **Infrastructure as Code (IaC):** All resources are provisioned using Terraform.
- **Containerized:** Built with Docker for consistent deployment.
- **Scalable Deployment:** Leveraging Amazon ECS, ALB, and API Gateway for high availability and scalability.

## Project structure
```markdown
    nba-gameday-notification/ 
    ├── .github/workflows
    │   └── frontend_ci_cd.yaml         # CI/CD for frontend
    │ 
    ├──frontend/                        # files for Web UI
    │   └──  index.html
    │ 
    ├── infrastructure/                    
    │   ├── main.tf                     # AWS infrastructure definition
    │   ├── provider.tf                 # AWS config for terraform
    |   └── variables.tf                # Input variables for terraform
    |  
    ├──media/                           
    | 
    | 
    ├── .dockerignore                   # Ignored files for docker 
    ├── .gitignore                      # Ignored  files for git
    ├── app.py                          # Flask app
    ├── Dockerfile                      # Dockerfile for image build
    ├── LICENSE                         # License
    ├── README.md                       # Project documentation  
    └── requirements.txt  
```

## Architecture 
![Architecture](./media/containerized%20sports%20api.jpeg)

## Getting Started
Prerequisites
- AWS Account
- Terraform Installed
- Docker Installed
- SERPAPI Key
- Auth0

## Steps 

1. Clone the Repository:
```bash
    git clone https://github.com/oyogbeche/nba_gameday_notification.git
    cd nba_gameday_notification
```

2. Build the docker image:
```bash
    docker build --platform linux/amd64 -t sports-api .
```

3. Run and Test the Docker container:
```bash
    docker run -d -p 8080:8080 -env SERPAPI_KEY='your-api-key' sports-api 
```

4. Create ECR repo:
```bash
    aws ecr create-repository --repository-name sports-api --region us-east-1
```

5. Login, tag and push image to ECR:
```bash
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

    docker tag sports-api:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/sports-api:sports-api-latest
    docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/sports-api:sports-api-latest
```

6. Provision Infrastructure:
```bash
    cd infrastructure
    terraform init
    terraform plan
    terraform apply
```

## Contact 
For questions or feedback please contact; 
- [email](mailto:oyogbeche@gmail.com)
- [LinkedIn](https://www.linkedin.com/in/oyameogbeche/)