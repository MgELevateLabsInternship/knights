TASK 2: Create a Simple Jenkins Pipeline for CI/CD

✅ Static Website Deployment via Jenkins + Docker + Apache2
🧱 Project Overview
Goal: Serve a static website (index.html) using Apache2 inside a Docker container

CI/CD: Jenkins pipeline

Server: Same EC2/VPS running Jenkins (Jenkins on port 8080, site on port 9090)

Repo: https://github.com/MgELevateLabsInternship/knights

🧾 Prerequisites
Jenkins installed and running on port 8080

Docker installed and running

GitHub credentials stored in Jenkins (ID: git_credentials)

DockerHub credentials stored in Jenkins (ID: docker_credentials)

Security Group / Firewall rule allows port 9090

📄 Step 1: Prepare Your Dockerfile
Place this inside the root of your GitHub repo (knights):

Dockerfile

FROM ubuntu

RUN apt-get update -y && \
    apt-get install -y apache2 curl

# Optional: Suppress Apache domain name warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add website files
ADD . /var/www/html

# Environment variable (optional)
ENV name Devuser-1

EXPOSE 80

ENTRYPOINT apachectl -D FOREGROUND

📜 Step 2: Jenkins Pipeline Script
Use this Declarative Pipeline in your Jenkins job:

groovy

pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker_credentials')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'git_credentials',
                    url: 'https://github.com/MgELevateLabsInternship/knights'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t mahi7888/knights1 .'
            }
        }

        stage('DockerHub Login') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh 'docker push mahi7888/knights1'
            }
        }

        stage('Run Container Locally') {
            steps {
                sh '''
                    docker stop knights1-container || true
                    docker rm knights1-container || true
                    docker run -d -p 9090:80 --name knights1-container mahi7888/knights1
                '''
            }
        }
    }
}

🌐 Step 3: Configure EC2 Port Access (If applicable)
For AWS EC2:

Go to EC2 Dashboard > Security Groups

Edit inbound rules

Type: Custom TCP

Port: 9090

Source: 0.0.0.0/0 (or your IP)

Save

🔍 Step 4: Verify Deployment
Once pipeline completes:

Visit your website at:


http://<your-server-ip>:9090
If blank or error:

Run: docker exec -it knights1-container ls /var/www/html

Run: docker exec -it knights1-container curl localhost

Run: docker logs knights1-container

✅ Troubleshooting Checklist
Check	Command
Apache is running	`docker exec -it knights1-container ps aux
HTML is copied	docker exec -it knights1-container ls /var/www/html
Apache serving?	docker exec -it knights1-container curl localhost
Server port open?	curl localhost:9090 on the host machine
Firewall issue?	Check cloud security group rules

🏁 Summary
✅ Jenkins pulls code from GitHub
✅ Builds and pushes Docker image
✅ Deploys container on same server
✅ Apache serves site on port 9090
✅ Accessible via browser
