pipeline {
    agent any

    environment {
        TF_DIR     = "terraform"
        AWS_REGION = "us-east-1"
    }

    stages {

        // ─────────────────────────────────────────────
        // STAGE 1: Pull Terraform code
        // ─────────────────────────────────────────────
        stage('Pull') {
            steps {
                echo "========== Stage 1: Pull EKS Terraform Code =========="
                git branch: 'main',
                    url: 'https://github.com/CK23004/eks-cluster-tf.git'
                sh 'ls -la ${TF_DIR}/'
            }
        }

        // ─────────────────────────────────────────────
        // STAGE 2: Terraform Init
        // ─────────────────────────────────────────────
        stage('Init') {
            steps {
                echo "========== Stage 2: Terraform Init =========="
                withAWS(credentials: 'aws-terraform-credentials', region: "${AWS_REGION}") {
                    dir("${TF_DIR}") {
                        sh 'terraform init -input=false'
                    }
                }
            }
        }

        // ─────────────────────────────────────────────
        // STAGE 3: Terraform Plan (Test)
        // ─────────────────────────────────────────────
        stage('Plan') {
            steps {
                echo "========== Stage 3: Terraform Plan (Review Changes) =========="
                withAWS(credentials: 'aws-terraform-credentials', region: "${AWS_REGION}") {
                    dir("${TF_DIR}") {
                        sh 'terraform plan -input=false -out=tfplan.binary'
                        // Convert binary plan to readable text for review
                        sh 'terraform show -no-color tfplan.binary > tfplan.txt'
                        sh 'echo "=== PLAN OUTPUT ===" && cat tfplan.txt'
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: "${TF_DIR}/tfplan.txt",
                                     allowEmptyArchive: true
                }
            }
        }

        // ─────────────────────────────────────────────
        // STAGE 4: Manual Approval before touching AWS
        // ─────────────────────────────────────────────
        stage('Approval') {
            steps {
                echo "========== Stage 4: Waiting for Manual Approval =========="
                timeout(time: 30, unit: 'MINUTES') {
                    input message: """
                        Review the Terraform plan output above (or open tfplan.txt artifact).
                        This will provision an EKS cluster on AWS (takes ~15 minutes).
                        Are you sure you want to apply?
                    """,
                    ok: 'Yes, Apply to AWS'
                }
            }
        }

        // ─────────────────────────────────────────────
        // STAGE 5: Terraform Apply (Deploy)
        // ─────────────────────────────────────────────
        stage('Apply') {
            steps {
                echo "========== Stage 5: Terraform Apply — Creating EKS Cluster =========="
                withAWS(credentials: 'aws-terraform-credentials', region: "${AWS_REGION}") {
                    dir("${TF_DIR}") {
                        sh 'terraform apply -input=false -auto-approve tfplan.binary'
                    }
                }
                echo "EKS cluster provisioned. See outputs above for cluster name and endpoint."
            }
        }

        // ─────────────────────────────────────────────
        // STAGE 6: Print Outputs + kubeconfig command
        // ─────────────────────────────────────────────
        stage('Output') {
            steps {
                echo "========== Stage 6: Terraform Outputs =========="
                withAWS(credentials: 'aws-terraform-credentials', region: "${AWS_REGION}") {
                    dir("${TF_DIR}") {
                        sh 'terraform output'
                    }
                }
            }
        }
    }

    post {
        success {
            echo """
                ✅ EKS cluster successfully deployed via Jenkins + Terraform.

                Run this command locally to configure kubectl:
                  aws eks update-kubeconfig --name jenkins-eks-cluster --region ap-south-1

                Then verify:
                  kubectl get nodes
            """
        }
        failure {
            echo "❌ Pipeline failed. Check the Plan or Apply stage logs. No partial infra should remain — run terraform destroy if needed."
        }
        always {
            cleanWs()
        }
    }
}
