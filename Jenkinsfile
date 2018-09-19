#!groovy

import groovy.json.JsonSlurperClassic
def DOCKER_DEPLOY_SERVER = "tcp://192.168.8.62:2376"
def DOCKER_IMAGE_REGISTRY = "uzzal2k5"
def REPOSITORY_NAME = "https://github.com/uzzal2k5/docker-terraform.git"
def DOCKER_REGISTRY_URL = "https://registry.hub.docker.com"
def CONTAINER = "nginx-serve"


def getVersion(def projectJson){
    def slurper = new JsonSlurperClassic()
    project = slurper.parseText(projectJson)
    slurper = null
    return project.version.split('-')[0]
}

def version, revision

// BUILD NODE
node {
    def IMAGE_NAME = "nginx"

    // Git Clone
    stage('Checkout'){

       try {
        git(branch: 'master',
            changelog: true,
            credentialsId: 'github-credentials',
            poll: true,
            url: "${REPOSITORY_NAME}"
            )
       }
       catch(Exception e){
           println 'Some Exception Occure here '
           throw e

       }
       finally{
         revision = version + "-" + sprintf("%04d", env.BUILD_NUMBER.toInteger())
         println "Start building  revision $revision"

       }

    }

    // DOcker Image Build & Deploy
    withDockerServer([uri: "${DOCKER_DEPLOY_SERVER}"]) {
        stage('Image Build'){

            nginxweb = docker.build("${DOCKER_IMAGE_REGISTRY}/${IMAGE_NAME}")


        }
    // Remove Local Image after push
        stage('Remove Local Images') {
           // remove docker images
           sh("docker rmi -f ${DOCKER_IMAGE_REGISTRY}/${IMAGE_NAME}:${env.TAG} || :")
           sh("docker rmi -f ${DOCKER_IMAGE_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER} || :")

        }


    }
    // DEPLOPY CONTAINER WITH TERRAFORM
    withDockerServer([uri: "${DOCKER_DEPLOY_SERVER}"]){
        // Deploy Container

        stage('CONTAINER CLEAN'){
                sh "docker ps -f name=${CONTAINER} -q | xargs --no-run-if-empty docker container stop"
                sh "docker container ls -a -fname=${CONTAINER} -q | xargs -r docker container rm"
                sh 'docker ps -q -f status=exited | xargs --no-run-if-empty docker rm'
        }
        stage('CONTAINER DEPLOY WITH TF') {
                def TERRAFORM = "/usr/local/bin/terraform"
                sh "${TERRAFORM} init"
                sh "${TERRAFORM} apply -auto-approve"

        }

    }

//NODE END
}
