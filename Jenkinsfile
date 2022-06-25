#!groovy

@Library('github.com/ayudadigital/jenkins-pipeline-library@v6.3.0') _

// Initialize global config
cfg = jplConfig('mapfre-gitops-frizqui', 'backend' ,'', [email: 'frizqui@mapfre.com'])
cfg.commitValidation.enabled = false

pipeline {
    agent any

    environment {
        AWS_KEY_ID     = credentials('AWS_KEY_ID')
        AWS_SECRET_KEY = credentials('AWS_SECRET_KEY')
    }  

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
                sh "terraform plan"
                
            }
        }
        stage ("Terraform apply") {
            when { branch 'main' }
            steps {
               
              sh """
                 terraform plan 
                 terraform apply --auto-approve 
                """
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
