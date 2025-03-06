pipeline {
    agent { label 'slave-node1' }
    environment {
        dockerImage = "pradishtamrakar/maven-demo"
    }

    stages {
        stage('Build Java App') {
            agent { label 'slave-node1' }  
            steps {
                sh 'mvn -f pom.xml clean package'
            }
            post {
                success {
                    echo "Build completed, archiving the file"
                    archiveArtifacts artifacts: '**/*.war', followSymlinks: false
                }
            }
        }

        stage('Create Docker Image') {
            agent { label 'slave-node1' }  
            steps {
                copyArtifacts filter: '**/*.war', fingerprintArtifacts: true, projectName: env.JOB_NAME, selector: specific(env.BUILD_NUMBER)
                echo "Creating Docker Image"
                sh 'whoami'
                sh 'docker build -t $dockerImage:$BUILD_NUMBER .'
            }
        }

        stage('Trivy scan for Docker Image'){
            agent { label 'slave-node1' } 
            steps{
                    sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL --ignore-unfixed $dockerImage:$BUILD_NUMBER'
            }   
        }//trivy for integrating and scanning
        stage('Tag and Push Image') {
            agent { label 'slave-node1' }  
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
                    sh 'docker push $dockerImage:$BUILD_NUMBER'
                }
            }
        }
        stage('Deploy to Development Env') {
            agent {
                label 'slave-node1'
            }
            steps {
                echo "Running app on development env"
                sh '''
                docker stop tomcatInstanceDev || true
                docker rm tomcatInstanceDev || true
                docker run -itd --name tomcatInstanceDev -p 8082:8080 $dockerImage:$BUILD_NUMBER 
                sh '''
            }
        }
        stage('Deploy Production Environment') {
            agent {
                label 'slave-node1'
            }
            steps {
                timeout(time:1, unit:'DAYS'){
                input message:'Approve PRODUCTION Deployment?'
                }
                echo "Running app on Prod env"
                sh '''
                docker stop tomcatInstanceProd || true
                docker rm tomcatInstanceProd || true
                docker run -itd --name tomcatInstanceProd -p 8083:8080 $dockerImage:$BUILD_NUMBER
                '''
            }
        }
    }
    post {
         always {
            echo'Job ran completely'
            mail to: 'tmkr.pradish@gmail.com',
            subject: "Job '${JOB_NAME}' (${BUILD_NUMBER}) status",
            body: "Please go to ${BUILD_URL} and verify the build"
         }
         success {
            echo 'Job succeed'
            mail bcc: '', body: """Hi Team,
            Build #$BUILD_NUMBER is successful, please go through the url
            $BUILD_URL
            and verify the details.
            Regards,
            DevOps Team""", cc: '', from: '', replyTo: '', subject: 'BUILD SUCCESS NOTIFICATION', to: 'tmkr.pradish@gmail.com'
         }
         failure {
            echo 'job failed'
                mail bcc: '', body: """Hi Team,
                Build #$BUILD_NUMBER is unsuccessful, please go through the url
                $BUILD_URL
                and verify the details.
                Regards,
                DevOps Team""", cc: '', from: '', replyTo: '', subject: 'BUILD FAILED NOTIFICATION', to: 'tmkr.pradish@gmail.com'
         }
    }
}
