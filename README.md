# TASK 2: Create a Simple Jenkins Pipeline for CI/CD

#### ✅ Static Website Deployment via Jenkins + Docker + Apache2
### 🧱 Project Overview

- Goal: Serve a static website (index.html) using Apache2 inside a Docker container
- CI/CD: Jenkins pipeline
- Server: EC2 running Jenkins (Jenkins on port 8080, site on port 9090)
- Repo: https://github.com/MgELevateLabsInternship/knights

### 🧾 Prerequisites
- EC2 server
- Jenkins installed and running on port 808
- Docker installed and running

### ⚙️Configure Jenkins
- GitHub credentials stored in Jenkins (ID: git_credentials)
- DockerHub credentials stored in Jenkins (ID: docker_credentials)
- Plugins: install without restart
  - openjdk --Eclips terminal install,openjdk--native-plugin
  - docker --- Docker,Docker Pipeline,docker-build-step,CloudBees Docker build,publish

- Global Tool Config
  - JDK
     Add JDK
	 - OpenJDK8, 
	   Install automatically
	   Add Installer -- Install from adoptium.net
	   select version
	
	 - OpenJDK11, 
	   Install automatically
	   Add Installer -- Install from adoptium.net
	   select version

  - Docker:
	Name: Docker, 
	Docker from docker.com

#### On Terminal 
- sudo usermod -a -G docker jenkins
- sudo systemctl  restart jenkins
- chmod 777 /var/run/docker.sock
- systemctl daemon-reload
- systemctl restart docker.service


- Security Group / Firewall rule allows port 9090

### 📄 Step 1: Prepare Your Dockerfile
- Place this inside the root of your GitHub repo (knights):

Dockerfile

FROM ubuntu

RUN apt-get update -y && \
    apt-get install -y apache2 curl

// Optional: Suppress Apache domain name warning

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

// Add website files

ADD . /var/www/html

// Environment variable (optional)

ENV name Devuser-1

EXPOSE 80

ENTRYPOINT apachectl -D FOREGROUND

### 📜 Step 2: Jenkins Pipeline Script
- Use this Declarative Pipeline in your Jenkins job:



pipeline {

  agent any

  environment {
    DOCKERHUB_CREDENTIALS = credentials('docker_credentials') // Add in Jenkins credentials
    IMAGE_NAME = 'mahi7888/knights1'
    CONTAINER_NAME = 'knights1-container'
    SITE_PORT = '9090' // Avoids Jenkins 8080 port
  }

  stages {

    stage('Checkout Code') {
      steps {
        git branch: 'main', credentialsId: 'git_credentials', url: 'https://github.com/MgELevateLabsInternship/knights'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME .'
      }
    }

    stage('Login to Docker Hub') {
      steps {
        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
      }
    }

    stage('Push Docker Image') {
      steps {
        sh 'docker push $IMAGE_NAME'
      }
    }

    stage('Deploy Container on Server') {
      steps {
        sh '''
          echo "Cleaning up existing container..."
          docker stop $CONTAINER_NAME || true
          docker rm $CONTAINER_NAME || true

          echo "Running updated container on port $SITE_PORT..."
          docker run -d -p $SITE_PORT:80 --name $CONTAINER_NAME $IMAGE_NAME
        '''
      }
    }
  }

  post {
    success {
      echo "✅ Deployment completed successfully!"
      echo "➡ Visit your site at: http://<your-server-ip>:$SITE_PORT"
    }
    failure {
      echo "❌ Pipeline failed. Please check error logs above."
    }
  }
}



#### ⚙️Enable GitHub Webhook in Jenkins Job
- Go to your Jenkins job (freestyle or pipeline)
- Click Configure
- Under Build Triggers:
- ✅ Check “GitHub hook trigger for GITScm polling”
- Save

#### ⚙️Add GitHub Webhook
- Go to your GitHub repo:
- 👉 https://github.com/MgELevateLabsInternship/knights
- Click on Settings > Webhooks > Add Webhook
- Payload URL: http://<YOUR_JENKINS_PUBLIC_IP>:8080/github-webhook/
- Content type: application/json
- Events: “Just the push event”
- Save


### 🌐 Step 3: Configure EC2 Port Access (If applicable)
- For AWS EC2:
- Go to EC2 Dashboard > Security Groups
- Edit inbound rules
- Type: Custom TCP
- Port: 9090
- Source: 0.0.0.0/0 (or your IP)
- Save

### 🔍 Step 4: Verify Deployment

- Once pipeline completes: run it
- <img width="1920" height="880" alt="knights_Dockerfile at main · MgELevateLabsInternship_knights - Brave 06-08-2025 16_15_05" src="https://github.com/user-attachments/assets/4cb83028-e7fd-44a1-ade7-ee288e10be4f" />
- <img width="1920" height="879" alt="knights_Dockerfile at main · MgELevateLabsInternship_knights - Brave 06-08-2025 16_14_32" src="https://github.com/user-attachments/assets/6e8066aa-2be5-41cd-b978-1e943862005b" />
- Visit your website at:
- http://<your-server-ip>:9090
  <img width="1920" height="889" alt="Knights - Free Bootstrap 4 Template by Colorlib - Brave 06-08-2025 17_37_56" src="https://github.com/user-attachments/assets/55d545e7-5f3f-4cc1-93dd-29315ddca9dc" />


#### ⚙️If blank or error:

- Run: docker exec -it knights1-container ls /var/www/html

- Run: docker exec -it knights1-container curl localhost

- Run: docker logs knights1-container

#### ✅ Troubleshooting Checklist
- Check	Command
- Apache is running	`docker exec -it knights1-container ps aux
- HTML is copied	docker exec -it knights1-container ls /var/www/html
- Apache serving?	docker exec -it knights1-container curl localhost
- Server port open?	curl localhost:9090 on the host machine
- Firewall issue?	Check cloud security group rules

### 🏁 Summary
- ✅ Jenkins pulls code from GitHub
- ✅ Builds and pushes Docker image
- ✅ Deploys container on same server
- ✅ Apache serves site on port 9090
- ✅ Accessible via browser


