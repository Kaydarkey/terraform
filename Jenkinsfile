pipeline {
    agent any
    
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'prod'], description: 'Environment to deploy')
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action to execute')
    }
    
    environment {
        TF_IN_AUTOMATION = 'true'
        AWS_REGION = 'eu-west-1'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Initialize Backend') {
            when {
                expression { params.ACTION == 'plan' || params.ACTION == 'apply' }
            }
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        
        stage('Initialize Environment') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Plan') {
            when {
                expression { params.ACTION == 'plan' || params.ACTION == 'apply' }
            }
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform plan -out=tfplan'
                    sh 'terraform show -no-color tfplan > tfplan.txt'
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: "environments/${params.ENVIRONMENT}/tfplan.txt", allowEmptyArchive: true
                }
            }
        }
        
        stage('Approval') {
            when {
                expression { params.ACTION == 'apply' || params.ACTION == 'destroy' }
            }
            steps {
                input message: "Do you want to ${params.ACTION} in ${params.ENVIRONMENT}?", ok: 'Proceed'
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
        
        stage('Deploy Docker Container') {
            when {
                expression { params.ACTION == 'apply' && params.ENVIRONMENT == 'dev' }
            }
            steps {
                script {
                    // Get instance IP from Terraform output
                    dir("environments/${params.ENVIRONMENT}") {
                        def instanceIP = sh(script: 'terraform output -raw instance_public_ip', returnStdout: true).trim()
                        
                        // SSH to instance and check Docker container
                        sshagent(['jenkins-ssh-key']) {
                            sh """
                                ssh -o StrictHostKeyChecking=no ec2-user@${instanceIP} '
                                    sudo docker ps -a
                                    sudo docker info
                                '
                            """
                        }
                    }
                }
            }
        }
        
        stage('Configure EKS') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    dir("environments/${params.ENVIRONMENT}") {
                        // Get EKS cluster info from Terraform output
                        def clusterName = sh(script: "terraform output -json | jq -r '.eks_cluster_endpoint.value' | cut -d'/' -f5", returnStdout: true).trim()
                        
                        // Update kubeconfig
                        sh "aws eks update-kubeconfig --name ${clusterName} --region ${env.AWS_REGION}"
                        
                        // Get cluster info
                        sh "kubectl cluster-info"
                        sh "kubectl get nodes"
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