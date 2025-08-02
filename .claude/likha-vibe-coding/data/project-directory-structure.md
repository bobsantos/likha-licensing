# Project directory structure for a monolith application

Since our application or platform will be a monolith, both the backend and frontend will live in the same repository.

.
├── frontend/ # React frontend
│ ├── public/  
│ ├── src/ # React components and pages
│ ├── Dockerfile # Dockerfile for React
│ └── package.json # React dependencies
├── backend/ # Spring Boot backend
│ ├── src/ # Java code for APIs and services
│ ├── Dockerfile # Dockerfile for Spring Boot
│ └── pom.xml # Maven dependencies
├── docker-compose.yaml # Docker Compose file to manage multi-container application
└── README.md # Project documentation

For the backend we will use app.likha as project package name.
