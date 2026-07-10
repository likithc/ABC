pipeline {
    agent any

    environment {
        IMAGE_NAME     = "student-app"
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = "student-con"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/daya9096/student-app.git'
            }
        }

        stage('Build & Package') {
            agent {
                // This spins up an isolated container with the exact versions your Enforcer plugin requires
                docker {
                    image 'maven:3.9.6-eclipse-temurin-21'
                    // Caches your dependencies on the host EC2 so builds stay fast
                    args '-v /var/lib/jenkins/.m2:/root/.m2'
                }
            }
            steps {
                // This executes inside the container, satisfying the Java 21 & Maven 3.9+ rules
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Back on the host machine, we package the compiled .jar file into your production app image
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
            }
        }

        stage('Deploy Container') {
            steps {
                // Clean up any old running app instances and start the updated one
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
                sh "docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${IMAGE_NAME}:latest"
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Pipeline built, tested, packaged, and deployed successfully using containerized agents!"
        }
        failure {
            echo "Pipeline failed. Check the logs above."
        }
    }
}
