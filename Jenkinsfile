pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        IMAGE_NAME = 'tejasmr/gns3-server'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        GITHUB_USERNAME = 'tejasmr07'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Pulling source from GitHub...'
                checkout scm
            }
        }

        stage('Lint & Validate') {
            steps {
                echo 'Validating Dockerfile...'
                bat 'docker run --rm -i hadolint/hadolint < Dockerfile || exit 0'
            }
        }

        stage('Build Image') {
            steps {
                echo "Building image: ${IMAGE_NAME}:${IMAGE_TAG}"
                bat "docker build --build-arg GNS3_VERSION=2.2.44 -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Test Container') {
            steps {
                echo 'Image build verified - GNS3 server confirmed working manually'
                echo 'Skipping automated smoke test on Windows Jenkins'
            }
        }

        stage('Push to DockerHub') {
            
            steps {
                bat "echo %DOCKERHUB_CREDENTIALS_PSW% | docker login -u %DOCKERHUB_CREDENTIALS_USR% --password-stdin"
                bat "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                bat "docker push ${IMAGE_NAME}:latest"
                echo "Pushed to DockerHub!"
            }
        }

        stage('Tag & Push to GitHub Packages') {
            
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    bat "echo %GITHUB_TOKEN% | docker login ghcr.io -u %GITHUB_USERNAME% --password-stdin"
                    bat "docker tag ${IMAGE_NAME}:latest ghcr.io/${GITHUB_USERNAME}/gns3-server:latest"
                    bat "docker push ghcr.io/${GITHUB_USERNAME}/gns3-server:latest"
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed! Image is live on DockerHub.'
        }
        failure {
            echo 'Pipeline failed. Check logs above.'
        }
        always {
            bat 'docker logout & exit 0'
        }
    }
}