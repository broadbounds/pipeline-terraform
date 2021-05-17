pipeline {

    parameters {
        string(name: 'environment', defaultValue: 'terraform', description: 'Workspace/environment file to use for deployment')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')

    }


     environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_Access_Key_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_Secret_Access_Key')
    }

   agent  any
    stages {
            stage('TerraformInit'){
            steps {
                dir('./'){
                    sh "terraform init -input=false"
                    sh "echo \$PWD"
                    sh "whoami"
                }
            }
        }

        stage('TerraformFormat'){
            steps {
                dir('./'){
                    sh "terraform fmt -list=true -write=false -diff=true -check=true"
                }
            }
        }

        stage('TerraformValidate'){
            steps {
                dir('./'){
                    sh "terraform validate"
                }
            }
        }

        stage('Plan') {
            steps {
                sh 'terraform init -input=false'
                sh 'terraform workspace new ${environment}'
                sh 'terraform workspace select ${environment}'
                sh "terraform plan -input=false -out tfplan "
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }
        stage('Approval') {
           when {
               not {
                   equals expected: true, actual: params.autoApprove
               }
           }

           steps {
               script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
               }
           }
       }

        stage('Apply') {
            steps {
                sh "pwd;cd terraform ; terraform apply -input=false tfplan"
            }
        }
    }
}
