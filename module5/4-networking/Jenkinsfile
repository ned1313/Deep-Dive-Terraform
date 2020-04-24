pipeline {
    agent any
    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform"
    }
    parameters {
        string(name: 'LAMBDA_URL', defaultValue: '', description: 'URL to the Lamdba function')
        string(name: 'WORKSPACE', defaultValue: 'development', description:'workspace to use in Terraform')
        string(name: 'DYNAMODB_STATELOCK', defaultValue: 'ddt-tfstatelock', description:'DynamoDB table for state locking')
        string(name: 'NETWORKING_BUCKET', defaultValue: '', description:'S3 bucket to use for state locking')
        string(name: 'REGION', defaultValue: 'us-east-1', description:'Region for resources')
        string(name: 'DATASOURCE', defaultValue: '', description:'Table name for datasource')
        
    }
    environment {
        TF_HOME = tool('terraform')
        TF_IN_AUTOMATION = "true"
        PATH = "$TF_HOME:$PATH"
        NETWORKING_ACCESS_KEY = credentials('networking_access_key')
        NETWORKING_SECRET_KEY = credentials('networking_secret_key')
    }
    stages {
        stage('NetworkInit'){
            steps {
                dir('module5/4-networking/'){
                    sh 'terraform --version'
                    sh "terraform init -input=false -plugin-dir=/var/jenkins_home/terraform_plugins \
                     --backend-config='dynamodb_table=${params.DYNAMODB_STATELOCK}' --backend-config='bucket=${params.NETWORKING_BUCKET}' \
                     --backend-config='access_key=$NETWORKING_ACCESS_KEY' --backend-config='secret_key=$NETWORKING_SECRET_KEY' \
                     --backend-config='region=${params.REGION}'"
                    sh "echo \$PWD"
                    sh "whoami"
                }
            }
        }
        stage('NetworkPlan'){
            steps {
                dir('module5/4-networking/'){
                    script {
                        try {
                           sh "terraform workspace new ${params.WORKSPACE}"
                        } catch (err) {
                            sh "terraform workspace select ${params.WORKSPACE}"
                        }
                        sh "terraform plan -var 'aws_access_key=$NETWORKING_ACCESS_KEY' \
                          -var 'aws_secret_key=$NETWORKING_SECRET_KEY' \
                          -var 'url=${params.LAMBDA_URL}' -var 'region=${params.REGION}' \
                          -var 'tablename=${params.DATASOURCE}' \
                          -input=false -out terraform-networking.tfplan;echo \$? > status"
                        stash name: "terraform-networking-plan", includes: "terraform-networking.tfplan"
                    }
                }
            }
        }
        stage('NetworkApply'){
            steps {
                script{
                    def apply = false
                    try {
                        input message: 'confirm apply', ok: 'Apply Config'
                        apply = true
                    } catch (err) {
                        apply = false
                        dir('module5/4-networking'){
                            sh "terraform destroy -var 'aws_access_key=$NETWORKING_ACCESS_KEY' \
                             -var 'aws_secret_key=$NETWORKING_SECRET_KEY' \
                             -var 'url=${params.LAMBDA_URL}' \
                             -var 'region=${params.REGION}' \
                             -var 'tablename=${params.DATASOURCE}' \
                             -auto-approve"
                        }
                        currentBuild.result = 'UNSTABLE'
                    }
                    if(apply){
                        dir('module5/4-networking'){
                            unstash "terraform-networking-plan"
                            sh 'terraform apply terraform-networking.tfplan'
                        }
                    }
                }
            }
        }
    }
}