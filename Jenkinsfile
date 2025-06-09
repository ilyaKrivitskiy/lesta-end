pipeline {
    agent any

    triggers {
        githubPush()
    }

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
        stage('Lint') {
            steps {
                sh 'python3 -m flake8 app/models.py app/routes.py'
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
        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'docker-compose.yaml', fingerprint: true
            }
        }
    }
}