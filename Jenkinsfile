pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'me1vin/lesta-end'
        DOCKER_TAG = '0.0.1'
        REGISTRY_CREDENTIALS = 'dockerhub'
    }
    stages {
        stage('Checkout'){
            steps {
                git url: 'https://github.com/ilyaKrivitskiy/lesta-end.git',
                    credentialsId: 'github-pat'
            }
        }
        stage('Build'){
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }
        stage('Test/Lint'){
            steps {
                script {
                    dockerImage.inside {
                        sh 'pip install flake8'
                        sh 'flake8 routes.py models.py'
                    }
                }
            }
        }
        stage('Push'){
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${REGISTRY_CREDENTIALS}") {
                        dockerImage.push()
                    }
                }
            }
        }
    }
}