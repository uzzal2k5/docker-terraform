#!groovy
import groovy.json.JsonSlurperClassic
def DOCKER_BUILD_SERVER = "tcp://10.10.10.62:2376"
def DOCKER_IMAGE_REGISTRY = "index.docker.io/uzzal2k5/"
def GIT_REPOSITORY_NAME  = "https://github.com/uzzal2k5/docker-terraform.git"


def IMAGE_NAME = "nginx"
def nginxImages



// Version & Release Specified Here
def getVersion(def projectJson){
    def slurper = new JsonSlurperClassic()
    project = slurper.parseText(projectJson)
    slurper = null
    return project.version.split('-')[0]
}



// REPOSITORY CLONE FROM GIT
def CloneFromGit( REPOSITORY_NAME ){
    def version, revision
    try {
        git(branch: "${params.BRANCH}",
                changelog: true,
                credentialsId: 'docker-hub-credentials',
                poll: true,
                url: "${REPOSITORY_NAME }"
        )
    }
    catch (Exception e) {
        println 'Some Exception happened here '
        throw e

    }
    finally {
        revision = version + "-" + sprintf("%04d", env.BUILD_NUMBER.toInteger())
        println "Start building  revision $revision"

    }
    return this
}



// DOCKER IMAGE BUILD & PUSH TO REGISTRY
def DockerImageBuild( DOCKER_BUILD_SERVER, DOCKER_IMAGE_REGISTRY, IMAGE_NAME ){

    // DOCKER IMAGE BUILD
    withDockerServer([uri: "${DOCKER_BUILD_SERVER}"]) {
        stage('IMAGE BUILD'){

            nginxImages = docker.build("${DOCKER_IMAGE_REGISTRY}/${IMAGE_NAME}")


        }

        //PUSH TO REGISTRY
        stage('PUSH IMAGE'){
            withDockerRegistry(url: "${DOCKER_IMAGE_REGISTRY}") {
                nginxImages.push("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                nginxImages.push("${IMAGE_NAME}:latest")
            }

        }

    }
    return this
}


// RUNNING TERRAFORM TO DEPLOY CONTAINER

def DeployWithTerraform(DOCKER_BUILD_SERVER){
    withDockerServer([uri: "${DOCKER_BUILD_SERVER}"]) {
        stage('CONTAINER DEPLOY WITH TF') {
                def TERRAFORM = "/usr/local/bin/terraform"
                sh "${TERRAFORM} init"
                sh "${TERRAFORM} apply -auto-approve"

        }
    }
 return this
 }

// BUILD NODE
node {
     def version, revision
     // GIT CLONE
     stage('GIT CLONE') {
            CloneFromGit(GIT_REPOSITORY_NAME)

      }
     // BUILD & PUSH IMAGE
     DockerImageBuild(SERVER_TO_DEPLOY,DOCKER_IMAGE_REGISTRY, IMAGE_NAME)

     // DEPLOY USING TERRAFORM
     DeployWithTerraform(DOCKER_BUILD_SERVER)

//NODE END
}

