# The Plug
Herb trading service store based on Beta Reputation System.
## Run Locally
Clone the project

```bash
  git clone https://github.com/WallyS02/The-Plug
```

### Run with Docker
Before you begin, ensure that you have the following tools installed on your system:

- [Docker](https://www.docker.com/get-started)

Go to the project directory

```bash
  cd The-Plug
```

Run *docker-compose-local.yml* with docker compose up

```bash
  docker-compose -f docker-compose-local.yml up  
```

### Run backend
Before running backend locally, ensure you have the following prerequisites installed on your system:
- Python 3.11 - [Download and Install Python 3.11](https://www.python.org/downloads/)

Go to the project directory

```bash
  cd backend/the_plug_backend_django
```
Before running backend locally run Postgres database in docker container
```bash
  docker-compose -f docker-compose-local.yml up -d db
```
Install requirements
```bash
  pip install -r requirements.txt
```
Make migrations and migrate
```bash
  python manage.py makemigrations
  python manage.py migrate
  python manage.py loaddata api/fixtures/herbs.json
```
Run application
```
  python manage.py runserver 0.0.0.0:8080
```
Once the application is running, you can access it locally by navigating to http://localhost:8080.

### Run frontend
Before running frontend locally, ensure you have the following prerequisites installed on your system:
- Node.js and npm - [Download and Install Node.js](https://nodejs.org/)

Go to the project directory
```bash
  cd frontend/the_plug_svelte_frontend
```
Install dependencies
```bash
  npm install
```
Run the Development Server
```bash
  npm run dev
```
This will start the development server, and you can access the application at http://localhost:80 in your web browser.

## Important directories and files
* **.github** - directory that contains GitHub Actions pipelines
* **ansible** - directory that contains Ansible configurations that can be used in project
* **aws** - directory that contains AWS cloud architecture for application and it's implementation using IaC practise with Terraform
* **backend** - directory that contains backend application code
* **documentation** - directory that contains application design and it's diagrams
* **frontend** - directory that contains frontend application code
* **jenkins** - directory that contains local Jenkins configuration files
* **k8s** - directory containing Minikube cluster and k8s application configuration
  * **cluster-setup** - directory that contains cluster configurations (including NGINX Ingress Controller, Prometheus, Grafana and Loki monitoring) and scripts that run and configure cluster
  * **helm** - directory that contains Helm charts for application
  * **raw** - directory that contains raw Kubernetes manifests for application
* **.gitlab-ci.yml** - main GitLab CI/CD pipeline, which uses gitlab-ci-local, that triggers child pipelines located in backend, frontend and k8s subdirectories
* **docker-compose-local.yml** - docker-compose file that allows running application locally

## Roadmap
- [x] prepare project design
- [x] create backend application
- [x] create frontend application
- [x] create Docker images
- [x] create Kubernetes (raw + Helm) deployment
- [x] prepare AWS cloud architecture
- [x] create example unit, integration, e2e and performance tests
- [x] create IaC Terraform configuration for application's AWS cloud
- [x] create GitHub Actions, GitLab CI/CD (gitlab-ci-local) and Jenkins CI/CD pipelines
- [x] complete final README
## Authors
- [@WallyS02](https://github.com/WallyS02) everything
