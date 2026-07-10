pipeline {
    agent any

    tools {
        // Ensure these exact matching names are configured under Manage Jenkins -> Tools
        // Use 'maven3' (lowercase) or whatever you exactly named it in the UI
        maven 'Maven3'
        jdk   'JDK21'
    }

    environment {
        IMAGE_NAME = "student-app"
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = "student-con"
        SONAR_HOST = "http://sonarqube:9000"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/daya9096/student-app.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                // Injects SonarQube credentials safely 
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh "mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                        -Dsonar.host.url=${SONAR_HOST} \
                        -Dsonar.token=${SONAR_TOKEN}"
                }
            }
        }

        stage('Package Artifact') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Generates the production Docker image using your standard Dockerfile
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
            }
        }

        stage('Deploy Container') {
            steps {
                // Stop and remove the old container if it exists, then spin up the new one
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
    }
}
