# Product Management API and User Interface

## 1. Project Overview
This repository contains a fully functional web application developed using Node.js, Express, and MongoDB. The application follows the Model-View-Controller (MVC) architectural pattern, providing both a RESTful API for programmatic access and a server-side rendered User Interface for end-user interaction. 

A critical resilience feature engineered into this application is the In-Memory Fallback Mechanism. During the initialization sequence, the server attempts to establish a connection to the primary MongoDB instance with a configured 3-second timeout. If the database is unreachable, the application automatically fails over to an internal in-memory datastore, guaranteeing zero application downtime.

## 2. Technology Stack
* Backend Framework: Node.js runtime environment utilizing the Express.js framework.
* Database: MongoDB with integrated in-memory fallback.
* Frontend Rendering: Embedded JavaScript (EJS) templating engine.
* File Management: Multer middleware for handling multipart/form-data.

## 3. Repository Structure
The repository is systematically organized to separate application source code from DevOps deployment configurations and evidence:

```text
├── phase1/
│   ├── scripts/
│   │   └── setup.sh              # Bash script for automated server provisioning
│   └── README.md                 # Specific documentation for Phase 1
├── phase2/
│   ├── evidence/                 # Documentation and screenshots of Phase 2 deployment
│   ├── reverse-proxy-config/     # Nginx server block configurations
│   ├── .env.example              # Environment variable template
│   └── README.md                 # Specific documentation for Phase 2
├── phase3/
│   ├── evidence/                 # Documentation and screenshots of Phase 3 deployment
│   ├── Dockerfile                # Instructions to build the application container image
│   ├── docker-compose.yml        # Multi-container orchestration configuration
│   └── README.md                 # Specific documentation for Phase 3
├── controllers/                  # Express route controllers
├── models/                       # Mongoose database schemas
├── public/                       # Static assets and locally uploaded files
├── routes/                       # API and UI route definitions
├── services/                     # Business logic and database abstraction layers
├── validators/                   # Data validation rules and middlewares
├── views/                        # EJS templates for frontend rendering
├── .gitignore                    # Framework-specific Git exclusions
├── main.js                       # Application entry point
├── package.json                  # Project metadata and dependencies
└── README.md                     # Comprehensive project documentation
```

## 4. Local Environment Setup

1. Install required dependencies:
   ```bash
   npm install
   ```

2. Environment Configuration:
   Copy the provided environment template from the phase2 directory to create your local configuration file.
   ```bash
   cp phase2/.env.example .env
   ```

3. Execute the application:
   ```bash
   npm start
   ```

## 5. DevOps Deployment Strategy

### Automation Script (Phase 1)
Located at `phase1/scripts/setup.sh`, this Bash automation script is engineered to prepare a pristine Ubuntu Linux environment. It automates the installation of essential system dependencies, including the Node.js runtime, Nginx web server, and PM2 process manager, ensuring a consistent and reproducible server setup prior to deployment.

### Phase 2: Traditional Cloud Deployment
The Phase 2 deployment approach utilizes a traditional host-based execution model on an Ubuntu virtual machine. The Node.js application is daemonized using PM2 to ensure process persistence and automatic restarts upon failure. Nginx is configured as a reverse proxy to securely route external HTTP and HTTPS traffic to the internal application port. The server environment is further secured using UFW (Uncomplicated Firewall) and Let's Encrypt SSL/TLS certificates.

### Phase 3: Containerization Architecture
The Phase 3 approach transitions the infrastructure from a host-based model to a containerized architecture using Docker. The application and the MongoDB database are packaged into isolated, portable containers using the provided `Dockerfile` and orchestrated via a `docker-compose.yml` configuration. Docker Volumes are implemented to decouple persistent data from the container lifecycle, ensuring absolute data retention for database records and user-uploaded media across container rebuilds.