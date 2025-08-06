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
