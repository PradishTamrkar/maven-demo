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
        stage('Create Docker Image'){
            steps{
            copyArtifacts filter: '**/*.war', fingerprintArtifacts: true, projectName: env.JOB_NAME, selector: specific(env.BUILD_NUMBER)
            echo "Creating Docker Image"
            sh 'whoami'
            sh 'Docker build -t localtomcatimg:$BUILD_NUMBER .'
            }
        }
        stage('package'){
            steps{
            echo "packaging application"
            }
        }
    }
}