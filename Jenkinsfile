pipeline {
    agent any

    environment {
        IMAGE_NAME     = "student-app"
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = "student-con"
        SONAR_HOST     = "http://sonarqube:9000" 
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
                    // We change the volume mount location to write cleanly to the project workspace instead of container root
                    args '-v ${WORKSPACE}/.m2:/var/maven/.m2'
                }
            }
            steps {
                // -Duser.home forces Maven to use our writable mount directory
                sh 'mvn clean package -DskipTests -Duser.home=/var/maven'
            }
        }

        stage('Run Unit Tests') {
            agent {
                docker {
                    image 'maven:3.9.6-eclipse-temurin-21'
                    args '-v ${WORKSPACE}/.m2:/var/maven/.m2'
                }
            }
            steps {
                sh 'mvn test -Duser.home=/var/maven'
            }
        }

        stage('SonarQube Analysis') {
            agent {
                docker {
                    image 'maven:3.9.6-eclipse-temurin-21'
                    args '-v ${WORKSPACE}/.m2:/var/maven/.m2'
                }
            }
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh "mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                        -Dsonar.host.url=${SONAR_HOST} \
                        -Dsonar.token=${SONAR_TOKEN} \
                        -Duser.home=/var/maven"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
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
            echo "Pipeline ran successfully!"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
