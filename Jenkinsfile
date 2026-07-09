pipeline {
    agent any

    tools {
        maven 'Maven3'   
        jdk   'JDK21'
    }

    environment {
        IMAGE_NAME = "student-app"
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = "student-con"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/daya9096/student-app.git'
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
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                // 'sonarqube' must match your SonarQube Server configuration name in Jenkins System Settings
                withSonarQubeEnv('sonarqube') {
                    sh '''
                    mvn sonar:sonar \
                    -Dsonar.host.url=http://docker.internal \
                    -Dsonar.projectKey=student-app-jar \
                    -Dsonar.projectName=student-app
                    '''
                } 
            }
        }

        stage('Package JAR') {
            steps {
                sh 'mvn package -DskipTests'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh """
                    docker rm -f ${CONTAINER_NAME} || true
                    docker run -d --name ${CONTAINER_NAME} -p 8088:8080 ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully. Container is running.'
        }
        failure {
            echo 'Pipeline failed. Check the stage logs above.'
        }
    }
}

