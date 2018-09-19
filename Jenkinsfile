#!groovy

import groovy.json.JsonSlurperClassic
def DOCKER_DEPLOY_SERVER = "tcp://192.168.8.62:2376"
def DOCKER_IMAGE_REGISTRY = "uzzal2k5"
def REPOSITORY_NAME = "https://github.com/uzzal2k5/docker-terraform.git"
def DOCKER_REGISTRY_URL = "https://registry.hub.docker.com"


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


    }
    // DEPLOPY CONTAINER WITH TERRAFORM
    stage('CONTAINER DEPLOY WITH TF') {

                def tfCMD = "/usr/local/bin/terraform"
                sh "${tfCMD} apply"

    }


//NODE END
}
