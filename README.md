### What this project currently does
* Set up a CI/CD pipeline in CodePipeline for a Spring Boot project from GitHub (https://github.com/kristof-eekhaut/aws-events-event) 
* Create a build stage for the pipeline using CodeBuild
* The build pushes the docker image to the image repository (ECR)

### Prerequisites
* An S3 bucket to store the tfstate file and configure in main.tf file
* A CodeStar Connection to be able to access GitHub repositories (variable 'codestar_connector_arn')
* An ECR to store the docker images (variable 'image_repository')

### To Do List
* Set up Kubernetes cluster on EKS
* Add Deploy stage to deploy the image to EKS
* Create pipeline to run the terraform updates automatically when committing changes to GitHub
