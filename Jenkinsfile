pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')  // set in Jenkins
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
                sh 'docker run --rm -i hadolint/hadolint < Dockerfile || true'
            }
        }

        stage('Build Image') {
            steps {
                echo "Building image: ${IMAGE_NAME}:${IMAGE_TAG}"
                sh """
                    docker build \
                        --build-arg GNS3_VERSION=2.2.44 \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} \
                        -t ${IMAGE_NAME}:latest \
                        .
                """
            }
        }

        stage('Test Container') {
            steps {
                echo 'Running smoke test...'
                sh """
                    docker run -d \
                        --name gns3-test-${BUILD_NUMBER} \
                        --cap-add NET_ADMIN \
                        -p 13080:3080 \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                    
                    sleep 8
                    
                    # Check if server responds
                    curl -f http://localhost:13080/v2/version || exit 1
                    
                    echo "✅ GNS3 server responded successfully!"
                """
            }
            post {
                always {
                    sh "docker stop gns3-test-${BUILD_NUMBER} && docker rm gns3-test-${BUILD_NUMBER} || true"
                }
            }
        }

        stage('Push to DockerHub') {
            when {
                branch 'main'
            }
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker push ${IMAGE_NAME}:latest"
                echo "✅ Pushed to DockerHub!"
            }
        }

        stage('Tag & Push to GitHub Packages (optional)') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    sh """
                        echo ${GITHUB_TOKEN} | docker login ghcr.io -u YOURGITHUBUSERNAME --password-stdin
                        docker tag ${IMAGE_NAME}:latest ghcr.io/YOURGITHUBUSERNAME/gns3-server:latest
                        docker push ghcr.io/YOURGITHUBUSERNAME/gns3-server:latest
                    """
                }
            }
        }
    }

    post {
        success {
            echo '🎉 Pipeline completed! Image is live on DockerHub.'
        }
        failure {
            echo '❌ Pipeline failed. Check logs above.'
        }
        always {
            sh 'docker logout || true'
        }
    }
}