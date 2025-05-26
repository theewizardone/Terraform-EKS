pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials("AWS_ACCESS_KEY_ID")
        AWS_SECRET_ACCESS_KEY = credentials("AWS_SECRET_ACCESS_KEY")
        AWS_DEFAULT_REGION    = "us-east-1"
        action = "apply" // or "destroy"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/theewizardone/Terraform-EKS.git']]
                ])
            }
        }

        stage('Initialize Terraform') {
            steps {
                dir('EKS') {
                    sh 'terraform init -upgrade'
                }
            }
        }

        stage('Format Terraform') {
            steps {
                dir('EKS') {
                    sh 'terraform fmt'
                }
            }
        }

        stage('Validate Terraform') {
            steps {
                dir('EKS') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Plan Terraform') {
            steps {
                dir('EKS') {
                    sh 'terraform plan'
                }
            }
        }

        stage('Apply/Destroy Terraform') {
            steps {
                dir('EKS') {
                    sh "terraform ${env.action} -auto-approve"
                }
            }
        }

        stage('Update kubeconfig') {
            steps {
                dir('EKS') {
                    sh 'aws eks update-kubeconfig --name my-eks-cluster --region us-east-1'
                }
            }
        }

        stage('Deploy Nginx Application') {
            steps {
                dir('EKS/ConfigurationFiles') {
                    sh '''
                        # Switch to the correct EKS context
                        kubectl config use-context arn:aws:eks:us-east-1:522585361427:cluster/my-eks-cluster

                        # Optionally verify access
                        kubectl get nodes

                        # Apply deployment and service
                        kubectl apply -f nginx-deployment.yaml
                        kubectl apply -f nginx-service.yaml
                    '''
                }
            }
        }
    }
}
