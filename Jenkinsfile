pipeline {
   tools {
        maven 'Maven3'      
    }
    agent any
    environment {
        AWS_REGION = 'us-east-1' // Or your desired region
    }
  
   
    stages {
        stage('Cloning Git') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '', url: 'https://github.com/khajaehtesham/jenkins-eks-springboot-app.git']]])     
            }
        }
      stage ('Build') {
          steps {
            sh 'mvn clean install'           
            }
      }
    // Building Docker images

    stage('Build Docker'){

            steps{
               withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-production-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                script{
                    sh '''
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 210613553230.dkr.ecr.us-east-1.amazonaws.com
                    docker build -t eks-demo .    
                    docker tag eks-demo:latest 210613553230.dkr.ecr.us-east-1.amazonaws.com/eks-demo:${BUILD_NUMBER}
                    '''
                }
            }
        }
    }
   
   
    // Uploading Docker images into AWS ECR
   stage('Push the artifacts'){
           steps{
            withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-production-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                script{
                    sh '''
                    echo 'Pushing Docker Image'
                    docker push 210613553230.dkr.ecr.us-east-1.amazonaws.com/eks-demo:${BUILD_NUMBER}
                    '''
                }
            }
        }
   }
    stage('Checkout K8S manifest SCM'){
            steps { 
               git credentialsId: 'git-login', url: 'https://github.com/khajaehtesham/cicd-k8s-manifests.git',
                branch: 'main'
            }
        }

       stage('Update K8S manifest & push to Repo') {
    steps {
        script {
            withCredentials([gitUsernamePassword(credentialsId: 'git-login', gitToolName: 'Default')]) {
                def gitRepoUrl = 'https://github.com/khajaehtesham/cicd-k8s-manifests.git'
                def commitMessage = "Update image tag to ${env.BUILD_NUMBER}" // Improved message
                def targetBranch = "release-branch"
                def newImageRepository = "210613553230.dkr.ecr.us-east-1.amazonaws.com/eks-demo"
                def newImageTag = env.BUILD_NUMBER

                echo "Updating image to ${newImageRepository}:${newImageTag} in values.yaml"

                // Git configuration (only if needed for this specific step, otherwise do it globally)
                sh "git config user.email 'khajaehtesham@gmail.com'"
                sh "git config user.name 'KhajaEhtesham'"

                // Checkout the release branch (or create if it doesn't exist)
                try {
                    sh "git checkout ${targetBranch}"
                } catch (Exception e) {
                    sh "git checkout -b ${targetBranch}"
                }

                // Update the values.yaml file using sed.  Safer and more readable.
                sh "sed -i 's#repository: .*#repository: ${newImageRepository}#' helmcharts/java-app/values.yaml"
                sh "sed -i 's#tag: .*#tag: ${newImageTag}#' helmcharts/java-app/values.yaml"

                // Verify the change
                sh "cat helmcharts/java-app/values.yaml"

                // Add, commit, and push
                sh "git add helmcharts/java-app/values.yaml"
                sh "git commit -m \"${commitMessage}\""
                sh "git push origin ${targetBranch}"
            }
        }
    }
}

    } 
    post {
        always {
            cleanWs() //  Clean up the workspace after the pipeline finishes
        }
    }

    }
