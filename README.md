# The Plug
## Disclaimer! System created for educational purposes only.
Drug dealing service store based on Beta Reputation System.
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
```
Run application
```
  python manage.py runserver localhost:8080
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

## Roadmap
- [x] build project diagrams
- [x] build backend application
- [x] build frontend application
- [x] build docker deployment
- [x] build github workflow cicd
- [x] complete final README
- [ ] deploy application
## Authors
- [@WallyS02](https://github.com/WallyS02) everything
