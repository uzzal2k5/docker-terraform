#!groovy

import groovy.json.JsonSlurperClassic

// DEFINING REQUIRED VARIABLES
def DOCKER_DEPLOY_SERVER = "tcp://192.168.8.62:2376"
def DOCKER_IMAGE_REPOSITORY = "uzzal2k5"
def GIT_REPOSITORY_NAME = "https://github.com/uzzal2k5/docker-terraform.git"
def DOCKER_REGISTRY_URL = "https://registry.hub.docker.com"
def CONTAINER = "nginx-server"

// DEFINING FUNCTION TO GET VERSION AND REVISION
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

    // CLONNING FROM GIT
    stage('CHECKOUT'){

       try {
        git(branch: 'master',
            changelog: true,
            credentialsId: 'github-credentials',
            poll: true,
            url: "${GIT_REPOSITORY_NAME}"
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

    //DOCKER BUILD
    withDockerServer([uri: "${DOCKER_DEPLOY_SERVER}"]) {
        stage('IMAGE BUILD'){

            nginxweb = docker.build("${DOCKER_IMAGE_REPOSITORY}/${IMAGE_NAME}")
        }

        //PUSH TO DOCKER HUB
        stage('PUSH IMAGE'){
            withDockerRegistry([ credentialsId: "DOCKERID", url: "" ]){
               nginxweb.push("${env.BUILD_NUMBER}")
               nginxweb.push("latest")
            }
        }

        // REMOVE LOCAL IMAGES
        stage('Remove Local Images') {
           // remove docker images
           sh("docker rmi -f ${DOCKER_IMAGE_REPOSITORY}/${IMAGE_NAME}:${env.TAG} || :")
           sh("docker rmi -f ${DOCKER_IMAGE_REPOSITORY}/${IMAGE_NAME}:${env.BUILD_NUMBER} || :")
           sh("docker rmi -f ${DOCKER_IMAGE_REPOSITORY}/${IMAGE_NAME}:latest || :")

        }


    }
    // DEPLOPY CONTAINER WITH TERRAFORM
    withDockerServer([uri: "${DOCKER_DEPLOY_SERVER}"]){
        // CLEANING CONTAINER
        stage('CONTAINER CLEAN'){
                sh "docker ps -f name=${CONTAINER} -q | xargs --no-run-if-empty docker container stop"
                sh "docker container ls -a -fname=${CONTAINER} -q | xargs -r docker container rm"
                sh 'docker ps -q -f status=exited | xargs --no-run-if-empty docker rm'
        }

        // CLEANNING IMAGE
        stage('IMAGE CLEANUP') {
                sh 'docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi'
        }
        // RUNNING TERRAFORM TO DEPLOY CONTAINER
        stage('CONTAINER DEPLOY WITH TF') {
                def TERRAFORM = "/usr/local/bin/terraform"
                sh "${TERRAFORM} init"
                sh "${TERRAFORM} apply -auto-approve"

        }

    }

//NODE END
}
