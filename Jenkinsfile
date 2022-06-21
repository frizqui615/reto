#!groovy

@Library('github.com/ayudadigital/jenkins-pipeline-library@v6.3.0') _

// Initialize global config
cfg = jplConfig('mapfre-gitops-frizqui', 'backend' ,'', [email: 'frizqui@mapfre.com'])
cfg.commitValidation.enabled = false

pipeline {
    agent any
    stages {
        stage ('Initialize') {
            steps  {
                jplStart(cfg)
            }
        }
        stage ("Terraform init") {
            steps {
                sh "terraform init"
            }
        }
        stage ("Terraform plan") {
            when { not { branch 'main' } }
            steps {
                script{    
                                               
                    withCredentials([usernamePassword(credentialsId: 'AKIA3IT5FKBPTR2FSLRS', usernameVariable: 'accessKeyID', passwordVariable: 'accessKeySecret')]){
                        sh "terraform plan -var var_aws_access_key=${accessKeyID}  -var var_aws_secret_key=${accessKeySecret}"
                        
                    }
                }
                
            }
        }
        stage ("Terraform apply") {
            when { branch 'main' }
            steps {
                script{    
                                               
                    withCredentials([usernamePassword(credentialsId: 'AKIA3IT5FKBPTR2FSLRS', usernameVariable: 'accessKeyID', passwordVariable: 'accessKeySecret')]){
                        sh """
                            terraform plan -var var_aws_access_key=${accessKeyID}  -var var_aws_secret_key=${accessKeySecret}
                            terraform apply --auto-approve -var var_aws_access_key=${accessKeyID}  -var var_aws_secret_key=${accessKeySecret}
                        """
                        
                    }
                }
//                sh """
//                    terraform plan 
//                    terraform apply -auto-approve 
//                """
            }
        }
        stage ("Terraform show") {
            steps {
                sh "terraform show"
            }
        }
    }

    post {
        always {
            jplPostBuild(cfg)
        }
    }

    options {
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(artifactNumToKeepStr: '20',artifactDaysToKeepStr: '30'))
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
    }
}
