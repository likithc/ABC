pipeline {
    agent any

    environment {
        IMAGE_NAME     = "student-app"
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = "student-con"
        SONAR_HOST     = "http://sonarqube:9000" // Adjust this to your SonarQube server URL
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/daya9096/student-app.git'
            }
        }

        stage('Build & Package') {
            agent {
                docker {
                    image 'maven:3.9.6-eclipse-temurin-21'
                    args '-v /var/lib/jenkins/.m2:/root/.m2'
                }
            }
            steps {
                // Compiles and packages the app using Java 21 / Maven 3.9 inside the container
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Run Unit Tests') {
            agent {
                docker {
                    image 'maven:3.9.6-eclipse-temurin-21'
                    args '-v /var/lib/jenkins/.m2:/root/.m2'
                }
            }
            steps {
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            agent {
                docker {
                    image 'maven:3.9.6-eclipse-temurin-21'
                    args '-v /var/lib/jenkins/.m2:/root/.m2'
                }
            }
            steps {
                // Safely injects your SonarQube token credentials configured in Jenkins
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh "mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                        -Dsonar.host.url=${SONAR_HOST} \
                        -Dsonar.token=${SONAR_TOKEN}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                // Back on the host machine to wrap the compiled jar into your final image
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
            }
        }

        stage('Deploy Container') {
            steps {
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
            echo "Pipeline built, tested, scanned, and deployed successfully!"
        }
        failure {
            echo "Pipeline failed. Review the logs above."
        }
    }
}
