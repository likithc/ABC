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
                // This spins up a container with the exact versions your Enforcer plugin demands
                docker {
                    image 'maven:3.9.6-eclipse-temurin-21'
                    // Reuses your host's local maven repository so it doesn't re-download dependencies every build
                    args '-v /root/.m2:/root/.m2'
                }
            }
            steps {
                // Runs safely inside the Java 21 container
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Run Unit Tests') {
            agent {
                docker {
                    image 'maven:3.9.6-eclipse-temurin-21'
                    args '-v /root/.m2:/root/.m2'
                }
            }
            steps {
                sh 'mvn test'
            }
        }

        stage('Build Docker Image') {
            steps {
                // This runs back on your host machine to wrap the pre-compiled .jar into your app image
                sh "docker build -t ${IMAGE_NAME
