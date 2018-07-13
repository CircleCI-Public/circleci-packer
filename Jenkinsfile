// Declarative Jenkinsfile Pipeline for a Hashicorp packer/terraform AWS simple ec2 stack
// (n.b. use of env.BRANCH_NAME to filter stages based on branch means this needs to be part
// of a Multibranch Project in Jenkins - this fits with the model of branches/PR's being
// tested & master being deployed)
pipeline {
  agent none

  environment {
     AWS_DEFAULT_REGION = 'us-east-1'
  }

  stages {
    stage('Validate & lint') {
      parallel {
        stage('packer validate') {
          agent {
            docker {
              image 'simonmcc/hashicorp-pipeline:latest'
              alwaysPull true
            }
          }
          steps {
            deleteDir()
            checkout scm
            echo "env.BRANCH_NAME: ${env.BRANCH_NAME}"

            wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
              sh "packer validate ./base/base.json"
              sh "AMI_BASE=ami-fakefake packer validate app/app.json"
            }
          }
        }
        stage('terraform fmt') {
          agent { docker { image 'simonmcc/hashicorp-pipeline:latest' } }
          steps {
            checkout scm
            sh "terraform fmt -check=true -diff=true"
          }
        }
      }
    }
		stage('build AMIs') {
			agent { docker { image 'simonmcc/hashicorp-pipeline:latest' } }
			steps {
				checkout scm
				withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                          credentialsId: 'demo-aws-creds',
                          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
					wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
						sh "./scripts/build.sh base base"
						sh "./scripts/build.sh app app"
					}
				}
			}
		}

		stage('build test stack') {
			agent { docker { image 'simonmcc/hashicorp-pipeline:latest' } }
      when {
        expression { env.BRANCH_NAME != 'master' }
      }
			steps {
				checkout scm
				withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                          credentialsId: 'demo-aws-creds',
                          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
					wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
						sh "./scripts/tf-wrapper.sh -a plan"
						sh "./scripts/tf-wrapper.sh -a apply"
            sh "cat output.json"
            stash name: 'terraform_output', includes: '**/output.json'
					}
				}
			}
		}
		stage('test test stack') {
			agent {
        docker {
          image 'chef/inspec:latest'
        }
      }
      when {
        expression { env.BRANCH_NAME != 'master' }
      }
			steps {
				checkout scm
				withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                          credentialsId: 'demo-aws-creds',
                          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
					wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
            sh "inspec detect -t aws://"
            unstash 'terraform_output'
            // sh "cat output.json"
            // sh "mkdir aws-security/files || true"
            // sh "mkdir /tmp/test-results || true"
            // sh "cp output.json aws-security/files/output.json"
            sh "exec aws-security --reporter=cli junit:/tmp/test-results/inspec-junit.xml -t aws://us-east-1"
            stash name: 'inspec_results', includes: '/tmp/test-results/inspec-junit.xml'
					}
				}
			}
		}
		stage('destroy test stack') {
			agent { docker { image 'simonmcc/hashicorp-pipeline:latest' } }
      when {
        expression { env.BRANCH_NAME != 'master' }
      }
			steps {
				checkout scm
				withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                          credentialsId: 'demo-aws-creds',
                          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
					wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
						sh "./scripts/tf-wrapper.sh -a destroy"
					}
				}
			}
		}
    stage('Manual Approval') {
      // TODO: this should be outside the implicit node definition, but then we'd
      // have to work out how to manage the plan/plan.out being persisted between stages
      // (probably use stash & unstash?)
      when {
        expression { env.BRANCH_NAME == 'master' }
      }
      steps {
        input 'Do you approve the apply?'
      }
    }
  }
  post {
    always {
      unstash 'inspec_results'
      junit '/tmp/test-results/inspec-junit.xml'
    }
  }
}
