pipeline {
    agent any
     environment {
    DOCKERHUB_CREDENTIALS = credentials('docker_credentials')
  }
  stages {
      
        stage('checkout') {
        steps {    
      git branch: 'main', credentialsId: 'git_credentials', url: 'https://github.com/MgELevateLabsInternship/knights'
        }
        }  
        
        stage('Build') {
        steps {
            sh 'docker build -t mahi7888/knights1 .'
        }
     }
          stage('Login') {
      steps {
        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
        echo "docker login success"
      }
    }  
           stage('Push') {
      steps {
        sh 'docker push mahi7888/knights1'
      }
    }   
  }  
}
