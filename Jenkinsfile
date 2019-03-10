def getEnvVar(String deployEnv, String paramName){
    return sh (script: "grep '${paramName}' env_vars/${deployEnv}.properties|cut -d'=' -f2", returnStdout: true).trim();
}

pipeline{

agent any

parameters {
    password(name:'AWS_KEY', defaultValue: '', description:'Enter AWS_KEY')
    choice(name: 'DEPLOY_ENV', choices: ['dev','sit','uat','prod'], description: 'Select the deploy environment')
    choice(name: 'ACTION_TYPE', choices: ['deploy','create','destroy'], description: 'Create or destroy')
    choice(name: 'INSTANCE_TYPE', choices: ['t2.micro','m3.medium','m3.large'], description: 'Type of instance')
    string(name: 'SPOT_PRICE', defaultValue: '0.008', description: 'Spot price')
    string(name: 'SPOT_HDPSPARK_MASTER_COUNT', defaultValue: '1', description: 'Masters count')
    string(name: 'SPOT_HDPSPARK_WORKER_COUNT', defaultValue: '1', description: 'Worker price')
}

stages{
    stage('Init'){
        steps{
            checkout scm 
        script{
        env.DEPLOY_ENV = "$params.DEPLOY_ENV"
        env.ACTION_TYPE = "$params.ACTION_TYPE"
        env.INSTANCE_TYPE = "$params.INSTANCE_TYPE"
        env.SPOT_PRICE = "$params.SPOT_PRICE"
        env.SPOT_HDPSPARK_MASTER_COUNT = "$params.SPOT_HDPSPARK_MASTER_COUNT"
        env.SPOT_HDPSPARK_WORKER_COUNT= "$params.SPOT_HDPSPARK_WORKER_COUNT"
        env.APP_ID = getEnvVar("${env.DEPLOY_ENV}",'APP_ID')
        env.APP_BASE_DIR = pwd()
        env.GIT_HASH = sh (script: "git rev-parse --short HEAD", returnStdout: true)
        env.TIMESTAMP = sh (script: "date +'%Y%m%d%H%M%S%N' | sed 's/[0-9][0-9][0-9][0-9][0-9][0-9]\$//g'", returnStdout: true)
        }
        echo "do some init here";

        }
    }

    stage('Create Stack'){
        when {
        expression {
            return env.ACTION_TYPE == 'create';
            }
        }
        steps{
            withCredentials([file(credentialsId: 'aws_terraform_tfvars', variable: 'aws_terraform_tfvars')]){
            sh '''#!/bin/bash -xe
            cd $APP_BASE_DIR/terraform
            cp $aws_terraform_tfvars $APP_BASE_DIR/terraform/terraform.tfvars
            /usr/local/bin/terraform init -input=false
            /usr/local/bin/terraform plan -var instance_type=$INSTANCE_TYPE -var spot_price=$SPOT_PRICE -var spot_hdpspark_master_count=$SPOT_HDPSPARK_MASTER_COUNT -var spot_hdpspark_worker_count=$SPOT_HDPSPARK_WORKER_COUNT -out=tfplan -input=false
            /usr/local/bin/terraform apply -input=false tfplan
            '''
            sh '''
            cd $APP_BASE_DIR/terraform
            rm -f $APP_BASE_DIR/ansible/hosts | true
            pwd && ls -lart .
            chmod 755 $APP_BASE_DIR/terraform/make_inventory.py
            python $APP_BASE_DIR/terraform/make_inventory.py $APP_BASE_DIR/terraform/terraform.tfstate
            '''
            }
        }
    }
    stage('Deploy'){
        when {
        expression {
            return env.ACTION_TYPE == 'deploy';
            }
        }
        steps{
        sh '''
        cd $APP_BASE_DIR/ansible
        ansible-playbook -i hosts main.yml
        '''
        }
    }
    stage('Destroy Stack'){
        when {
        expression {
            return env.ACTION_TYPE == 'destroy';
            }
        }
        steps{
            withCredentials([file(credentialsId: 'aws_terraform_tfvars', variable: 'aws_terraform_tfvars')]){
            sh '''
            cd $APP_BASE_DIR/terraform
            cp $aws_terraform_tfvars $APP_BASE_DIR/terraform/terraform.tfvars
            /usr/local/bin/terraform destroy -force
            '''
            }
        }
    }
}

post {
    always {
        sh '''
        rm -f $APP_BASE_DIR/terraform/terraform.tfvars | true
        '''
    }
}
}
