pipeline {
    agent any

    tools {
        // These names must match exactly what you configured in Manage Jenkins -> Tools
        maven 'Maven3'
        jdk   'JDK21'
    }

    environment {
        IMAGE_NAME     = "student-app"
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = "student-con"
    }

    stages {
        stage('Checkout') {
            steps {
                // Pulls your source code repository
                git branch: 'main', url: 'https://github.com/daya9096/student-app.git'
            }
        }

        stage('Build with Maven') {
            steps {
                // Explicitly forces Jenkins to inject JDK21 and Maven3 into this execution path
                withMaven(maven: 'Maven3', jdk: 'JDK21') {
                    sh 'mvn clean compile'
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                withMaven(maven: 'Maven3', jdk: 'JDK21') {
                    sh 'mvn test'
                }
            }
        }

        stage('Package Artifact') {
            steps {
                // Compiles and outputs the final target/student.jar file
                withMaven(maven: 'Maven3', jdk: 'JDK21') {
                    sh 'mvn package -DskipTests'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                // Builds the production-ready Docker image on your EC2 host
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
            }
        }

        stage('Deploy Container') {
            steps {
                // Stops and cleans up any old container instance before launching the updated one
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
                sh "docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${IMAGE_NAME}:latest"
            }
        }
    }

    post {
        always {
            // Keeps your Jenkins server lightweight by cleaning the workspace directory
            cleanWs()
        }
        success {
            echo "Pipeline built, tested, packaged, and deployed successfully!"
        }
        failure {
            echo "Pipeline failed. Review the console logs above to diagnose."
        }
    }
}
