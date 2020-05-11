node {
    stage('Checking out git repo') {
      echo 'Checkout'
      checkout scm
    }
    stage('Linting') {
        echo 'Linting'
        sh 'docker run --rm -i hadolint/hadolint:v1.17.6-3-g8da4f4e-alpine < Dockerfile'
    }
    stage('Build image') {
        echo 'Building Docker image'
        sh 'docker build -f Dockerfile -t ricoms858/divorce-predictor .'
    }
    stage('Push image') {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]){
            sh 'docker login -u ${dockerHubUser} -p ${dockerHubPassword}'
            sh 'docker tag ricoms858/divorce-predictor ricoms858/divorce-predictor'
            sh 'docker push ricoms858/divorce-predictor'
        }
    }
    stage('Deploy to EKS Kubernetes') {
        dir ('./') {
            withAWS(credentials: 'personal-devops', region: 'us-east-1') {
                sh "aws eks --region us-east-1 update-kubeconfig --name CapstoneEKS"
                sh "kubectl apply -f aws/aws-auth-cm.yaml"
                sh "kubectl apply -f aws/app-deployment.yml"
                sh "kubectl get nodes"
                sh "kubectl get pods"
                sh "aws cloudformation update-stack --stack-name udacity-capstone-nodes --template-body file://aws/worker_nodes.yml --parameters file://aws/worker_nodes_parameters.json --capabilities CAPABILITY_IAM"
            }
        }
    }
    stage("Cleaning up") {
        echo 'Cleaning up...'
        sh 'docker system prune'
    }
}
