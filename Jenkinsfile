pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'eu-west-1'
    }

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'prod'], description: 'Environment to deploy (dev or prod)')
        booleanParam(name: 'DESTROY_INFRASTRUCTURE', defaultValue: false, description: 'Destroy infrastructure after apply?')
    }

    stages {
        stage('Pull Code') {
            steps {
                git branch: 'main', poll: false, url: 'https://github.com/Kaydarkey/terraform.git'
            }
        }

        stage('Terraform Init & Validate') {
            steps {
                echo "Initializing and validating Terraform for ${params.ENVIRONMENT} environment"
                
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh """
                        cd environments/${params.ENVIRONMENT}
                        terraform init
                        terraform fmt -recursive
                        terraform validate
                    """
                }
            }
        }

        stage('Select Workspace') {
            steps {
                echo "Selecting workspace for ${params.ENVIRONMENT} environment"
                
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh """
                        cd environments/${params.ENVIRONMENT}
                        terraform workspace select ${params.ENVIRONMENT} || terraform workspace new ${params.ENVIRONMENT}
                    """
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                echo "Generating Terraform plan for ${params.ENVIRONMENT} environment"
                
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh """
                        cd environments/${params.ENVIRONMENT}
                        terraform plan -var="environment=${params.ENVIRONMENT}" -out=tfplan
                    """
                }
            }
        }

        stage('Approval') {
            when {
                expression { params.ENVIRONMENT == 'prod' }
            }
            steps {
                input message: 'Approve deployment to production?', ok: 'Deploy to Production'
            }
        }

        stage('Terraform Apply') {
            steps {
                echo "Applying Terraform changes to ${params.ENVIRONMENT} environment"
                
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh """
                        cd environments/${params.ENVIRONMENT}
                        terraform apply -auto-approve tfplan
                    """
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.DESTROY_INFRASTRUCTURE }
            }
            steps {
                echo "Destroying Terraform infrastructure in ${params.ENVIRONMENT} environment"

                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh """
                        cd environments/${params.ENVIRONMENT}
                        terraform destroy -auto-approve -var="environment=${params.ENVIRONMENT}"
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Terraform execution complete for ${params.ENVIRONMENT} environment."
            cleanWs()
        }
        success {
            echo "Terraform deployment (or destruction) successful for ${params.ENVIRONMENT} environment."
        }
        failure {
            echo "Terraform deployment (or destruction) failed for ${params.ENVIRONMENT} environment."
        }
    }
}