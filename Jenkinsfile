pipeline {
    agent any
    stages{
        stage('Build Java App'){
            steps{
            sh 'mvn -f pom.xml clean package'
            }
            post{
                success{
                    echo "Build completed so archiving the file"
                archiveArtifacts artifacts: '**/*.war', followSymlinks: false
                }
            }
        }
        stage('Build stage'){
            steps{
            echo "Building application"
            }
        }
        stage('package'){
            steps{
            echo "packaging application"
            }
        }
    }
}