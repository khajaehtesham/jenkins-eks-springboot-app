# jenkins-eks-springboot-app

**Pre-requsites:**

  Install aws cli on jenkins server and configure it with your credentials. it would be helpful to connect to ecr repo for pushing the containerized images.
  
  Create ECR repo, and update the Account ID and ecr repo in the JenkinsFile accordingly.

This repo is used for building the java application using maven and containerizing the application. 

In this repo , we are using Jenkins as a CI tool. 


With the help of Jenkinsfile, we are performing below steps.

1. Checkout the Code from Git
2. Building the code using Maven
3. Docker Image Build using docker and push to ECR
4. Checkout the Manifest repository
5. create a release branch from main branch in manifest repository to push the latest docker image tag
6. Update the manifest file with latest image tag and image repository in values file of each environment
7. Push the changes to the manifest repo, these changes would be pushed to release branch. 

**You can include the security related steps which i have excluded from the pipeline, such as sonarqube scan and trivy scan**

Below are the source code repository and manifest repo details: 

app source code repo : https://github.com/khajaehtesham/jenkins-eks-springboot-app.git


manifest repo :  https://github.com/khajaehtesham/cicd-k8s-manifests.git

**Once the changes are pushed to release branch, we can then raise a PR to get it merged to main branch.**

The PR would then needs to be approved to deploy the changes. 



**In ArgoCD, you need to create separate applications, each application would have a separate path defining each environment , as we have same structure followed in the manifest repository.**
