pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        EKS_CLUSTER_NAME = 'devopslite-dev-eks-cluster'
        KUBE_CONFIG_PATH = '/root/.kube/config'
        NAMESPACE = 'app'
        SLACK_CHANNEL = '#deployments'
        SLACK_CREDENTIALS = credentials('slack-webhook-url')
    }

    stages {
        stage('Checkout Repository') {
            steps {
                checkout scm
            }
        }

        stage('Configure AWS & EKS') {
            steps {
                sh '''
                echo "Configuring AWS and EKS..."
                aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME}
                '''
            }
        }

        stage('Deploy Kubernetes Manifests') {
            steps {
                sh '''
                echo "Applying Kubernetes manifests..."
                kubectl apply -f application/
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    def status = sh (
                        script: 'kubectl rollout status deployment/httpbin -n ${NAMESPACE}',
                        returnStatus: true
                    )
                    if (status != 0) {
                        error("Deployment failed! Initiating rollback...")
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                sh '''
                echo "Deployment successful!"
                curl -X POST --data-urlencode "payload={\\"channel\\": \\"${SLACK_CHANNEL}\\", \\"username\\": \\"jenkins\\", \\"text\\": \\"✅ Deployment successful!\\", \\"icon_emoji\\": \\":rocket:\\"}" ${SLACK_CREDENTIALS}
                '''
            }
        }
        failure {
            script {
                sh '''
                echo "Deployment failed. Rolling back..."
                kubectl rollout undo deployment/httpbin -n ${NAMESPACE}

                curl -X POST --data-urlencode "payload={\\"channel\\": \\"${SLACK_CHANNEL}\\", \\"username\\": \\"jenkins\\", \\"text\\": \\"❌ Deployment failed! Rolling back...\\", \\"icon_emoji\\": \\":fire:\\"}" ${SLACK_CREDENTIALS}
                '''
            }
        }
    }
}
