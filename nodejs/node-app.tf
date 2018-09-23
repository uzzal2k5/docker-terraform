# Configure the docker provider
provider "docker" {
  host = "tcp://192.168.8.62:2376"

}

resource "docker_image" "nodeapp-image"{
  name = "uzzal2k5/node-terraform"

}
# Create NODE APP  container
resource "docker_container" "node-server" {
  count = 2
  name = "node-server"
  image = "${docker_image.nodeapp-image.latest}"
  ports {
    internal = 8080
    external =  8081
    protocol = "tcp"

  }

}

resource "docker_image" "mongodb-image"{
  name = "mongo"

}
# Create MONGO DB  container
resource "docker_container" "mongodb" {
  name = "mongodb2"
  image = "${docker_image.mongodb-image.latest}"
  ports {
    internal = 27017
    external =  27018
    protocol = "tcp"

  }
  volumes {
    volume_name = "database"
    container_path = "/data/db"
    host_path = "/home/uzzal/PROJECTS/database"

  }
}