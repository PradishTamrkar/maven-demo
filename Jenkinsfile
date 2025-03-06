pipeline {
    agent any
    environment {
        dockerImage = "pradishtamrakar/maven-demo"
    }

    stages{
        stage('Build Java App'){
             agent(
                label 'slave-node1'
            )
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
             agent(
                label 'slave-node1'
            )
            steps{
            copyArtifacts filter: '**/*.war', fingerprintArtifacts: true, projectName: env.JOB_NAME, selector: specific(env.BUILD_NUMBER)
            echo "Creating Docker Image"
            sh 'whoami'
            sh 'docker build -t $dockerImage:$BUILD_NUMBER .'
            }
        }
        stage('Tag and Push Image'){
             agent(
                label 'slave-node1'
            )
            steps{
            withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']){
                sh '''
                docker push $dockerImage:$BUILD_NUMBER
                '''
            }
            }
        }
    }
}