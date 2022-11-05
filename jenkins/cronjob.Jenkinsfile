pipeline {
	
    agent {
        label('awscli')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    triggers {
        cron('*/10 * * * *')
    }
    stages {
        stage('test'){
            steps {
	        dir('jenkins') {
	            sh "bash check_size.sh"
		}
	    }
        }
    }
}
