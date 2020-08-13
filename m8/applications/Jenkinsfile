pipeline {
    agent any
    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform"
    }
    parameters {
        string(name: 'CONSUL_STATE_PATH', defaultValue: 'applications/state/globo-primary', description: 'Path in Consul for state data')
        string(name: 'WORKSPACE', defaultValue: 'development', description:'workspace to use in Terraform')
    }

    environment {
        TF_HOME = tool('terraform')
        TF_INPUT = "0"
        TF_IN_AUTOMATION = "TRUE"
        TF_VAR_consul_address = "host.docker.internal"
        TF_LOG = "WARN"
        CONSUL_HTTP_TOKEN = credentials('applications_consul_token')
        AWS_ACCESS_KEY_ID = credentials('aws_access_key')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        PATH = "$TF_HOME:$PATH"
    }

    stages {
        stage('ApplicationInit'){
            steps {
                dir('m8/applications/'){
                    sh 'terraform --version'
                    sh "terraform init --backend-config='path=${params.CONSUL_STATE_PATH}'"
                }
            }
        }
        stage('ApplicationValidate'){
            steps {
                dir('m8/applications/'){
                    sh 'terraform validate'
                }
            }
        }
        stage('ApplicationPlan'){
            steps {
                dir('m8/applications/'){
                    script {
                        try {
                           sh "terraform workspace new ${params.WORKSPACE}"
                        } catch (err) {
                            sh "terraform workspace select ${params.WORKSPACE}"
                        }
                        sh "terraform plan -out terraform-applications.tfplan;echo \$? > status"
                        stash name: "terraform-applications-plan", includes: "terraform-applications.tfplan"
                    }
                }
            }
        }
        stage('ApplicationApply'){
            steps {
                script{
                    def apply = false
                    try {
                        input message: 'confirm apply', ok: 'Apply Config'
                        apply = true
                    } catch (err) {
                        apply = false
                        dir('m8/applications/'){
                            sh "terraform destroy -auto-approve"
                        }
                        currentBuild.result = 'UNSTABLE'
                    }
                    if(apply){
                        dir('m8/applications/'){
                            unstash "terraform-applications-plan"
                            sh 'terraform apply terraform-applications.tfplan'
                        }
                    }
                }
            }
        }
    }
}