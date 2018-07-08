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
          agent { docker { image 'simonmcc/hashicorp-pipeline:latest' } }
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
						sh "./scripts/build.sh base base ; echo $?"
						sh "./scripts/build.sh app app"
					}
				}
			}
		}
  }
}
