pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'me1vin/lesta-end'
        DOCKER_TAG = 'latest'
        REGISTRY_CREDENTIALS = 'dockerhub'
    }
    stages {
        stage('Checkout'){
            steps {
                git 'https://github.com/ilyaKrivitskiy/lesta-end.git'
            }
        }
        stage('Build'){
            steps {
                bat "docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% ."
            }
        }
        stage('Test/Lint'){
            steps {
                sh 'pip install flake8'
                sh 'flake8 routes.py'
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