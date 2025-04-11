pipeline {
    agent any
    
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'prod'], description: 'Environment to deploy')
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action to execute')
    }
    
    environment {
        AWS_REGION = 'eu-west-1'
        // Force AWS SDK to use a specific region
        AWS_DEFAULT_REGION = 'eu-west-1'
        // Add this to fix potential encoding issues
        PYTHONIOENCODING = 'UTF-8'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Debug Environment') {
            steps {
                sh 'date'  // Check server time
                sh 'env | grep -v KEY | grep -v SECRET'  // Print environment variables (excluding sensitive data)
            }
        }
        
        stage('Setup AWS Credentials') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-credentials', 
                                  accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    // Ensure we're using aws cli v2 if available
                    sh 'aws --version'
                    
                    // Use explicit region with command
                    sh 'aws sts get-caller-identity --region ${AWS_REGION}'
                }
            }
        }
        
        stage('Initialize') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-credentials', 
                                  accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir("environments/${params.ENVIRONMENT}") {
                        sh 'terraform version'
                        sh 'terraform init'
                    }
                }
            }
        }
        
        stage('Plan') {
            when {
                expression { params.ACTION == 'plan' || params.ACTION == 'apply' }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-credentials', 
                                  accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir("environments/${params.ENVIRONMENT}") {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }
        
        stage('Approval') {
            when {
                expression { params.ACTION == 'apply' || params.ACTION == 'destroy' }
            }
            steps {
                input message: "Proceed with ${params.ACTION} in ${params.ENVIRONMENT}?"
            }
        }
        
        stage('Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-credentials', 
                                  accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir("environments/${params.ENVIRONMENT}") {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
        
        stage('Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-credentials', 
                                  accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir("environments/${params.ENVIRONMENT}") {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
        
        stage('Verify') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-credentials', 
                                  accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir("environments/${params.ENVIRONMENT}") {
                        sh 'terraform output'
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo "Terraform ${params.ACTION} on ${params.ENVIRONMENT} completed successfully!"
        }
        failure {
            echo "Terraform ${params.ACTION} on ${params.ENVIRONMENT} failed!"
        }
    }
}