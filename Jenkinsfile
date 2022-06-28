#!groovy

@Library('github.com/ayudadigital/jenkins-pipeline-library@v6.3.0') _

// Initialize global config
cfg = jplConfig('mapfre-gitops-frizqui', 'backend' ,'', [email: 'frizqui@mapfre.com'])
cfg.commitValidation.enabled = false

pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_KEY')
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
   stage ("Sonar: Regular Branch Check") {
            when { not { branch 'PR-*' } }
            steps {
                // Make analysis of the branch with SonarScanner and send it to SonarCloud
                withSonarQubeEnv ('frizqui615sonar') {
                    sh '~/.sonar/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner \
                        -Dsonar.organization=frizqui615 \
                        -Dsonar.projectKey=frizqui615-sonar \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=https://sonarcloud.io \
                        -Dsonar.branch.name="$BRANCH_NAME"'
                }
            }
        }
        stage ("Sonar: PR Check") {
            when { branch 'PR-*' }
            steps {
                // Make analysis of the PR with SonarScanner and send it to SonarCloud
                // Reference: https://blog.jdriven.com/2019/08/sonarcloud-github-pull-request-analysis-from-jenkins/
                withSonarQubeEnv ('frizqui615sonar') {
                    sh "~/.sonar/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner \
                        -Dsonar.organization=frizqui615 \
                        -Dsonar.projectKey=frizqui615-sonar \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=https://sonarcloud.io \
                        -Dsonar.pullrequest.provider='GitHub' \
                        -Dsonar.pullrequest.github.repository='frizqui615/reto' \
                        -Dsonar.pullrequest.key='${env.CHANGE_ID}' \
                        -Dsonar.pullrequest.branch='${env.CHANGE_BRANCH}'"
                }
            }
        }
        stage ("Sonar: Wait for QG") {
            steps {
                // Wait for QuaityGate webhook result
                timeout(time: 30, unit: 'MINUTES') {
                    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                    // true = set pipeline to UNSTABLE, false = don't
                    waitForQualityGate abortPipeline: false
                }
            }
        }
        stage("test") {
            when { not { branch 'main' } }
            steps {

                sh """
                    ansible-playbook copyhtml.yml --check                
                """
            }
        }

        stage ("Terraform apply") {
            when { branch 'main' }
            steps {
               
              sh """
                 terraform plan 
                 terraform apply --auto-approve 
                 ansible-playbook copyhtml.yml
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
        timeout(time: 15, unit: 'MINUTES')
    }
}
