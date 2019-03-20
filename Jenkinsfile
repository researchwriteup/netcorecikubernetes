#!groovy
def kuberemote = [:]
kuberemote.name = 'test' // change the test to your names
kuberemote.host = '172.xxx.xxx.xxx'		// give the ip of the kubernetes cluster master node
kuberemote.allowAnyHosts = true
		
pipeline {
    agent any
    environment {
        IMAGE_NAME = "dotnet-core-demo" // The name you want to give your docker image. Ex. git-migrator                
	DOCKER_HUB_REPO = "hpatani/docker-demo-hub" // the name of the Docker Hub Repository
		
    }
    options {
        skipDefaultCheckout true
    }
    
    stages {
        stage('Pull Repository') {
            agent any
            steps {
                script {
                    def gitRepoUrl = scm.getUserRemoteConfigs()[0].getUrl()
		
                    checkout scm: [$class: 'GitSCM', branches: scm.branches, extensions: scm.extensions, gitTool: 'Linux-Git Path', userRemoteConfigs: [[credentialsId: 'gitcred', name: 'origin', url: gitRepoUrl]]]                    
	        // change the credential ID with the your GITHUB credential ID Created in the Jenkins Portal.
                }
            }
        }

        stage('Create Image') {
            agent any
            steps {
                script {               //change the credential object for the docker login
					withCredentials([usernamePassword(credentialsId: 'dockercred', usernameVariable: 'docker_username', passwordVariable: 'docker_password')]) {
						env.IMAGE_TAG = "latest"
						sh "docker login -u $docker_username -p $docker_password"
						sh "docker build -f Dockerfile . -t ${env.IMAGE_NAME}"
						sh "docker tag ${env.IMAGE_NAME} ${env.DOCKER_HUB_REPO}:${env.IMAGE_TAG}"
						sh "docker push ${env.DOCKER_HUB_REPO}:${env.IMAGE_TAG}"																
					}
				}
			}
        }
		
		stage('Copy Deployment File') {
			agent any
			steps {
				script {
							//change the credential object for the kubernetes login
					withCredentials([usernamePassword(credentialsId: 'Kube-Creds', usernameVariable: 'kube_username', passwordVariable: 'kube_password')]) {
						sh "sshpass -p ${kube_password} scp deployment.yml  ${kube_username}@172.25.200.70:/home/${kube_username}/deployments"
					}
				}
			}
		}
		
		stage('Deploy Container') {
			agent any
			steps {
				script { //change the credential object for the docker login and kubernetes
					withCredentials([usernamePassword(credentialsId: 'dockercred', usernameVariable: 'docker_username', passwordVariable: 'docker_password'), usernamePassword(credentialsId: 'Kube-Creds', usernameVariable: 'kube_username', passwordVariable: 'kube_password')]) {
						kuberemote.user = kube_username
						kuberemote.password = kube_password
						
						sshCommand remote: kuberemote, sudo: true, command: "kubectl create secret generic regcred --from-literal=username=${docker_username} --from-literal=password=${docker_password}"	
						sshCommand remote: kuberemote, sudo: true, command: "kubectl create -f /home/${kube_username}/deployments/deployment.yml"					
					}
					
				}
			}
		}
    }
}
