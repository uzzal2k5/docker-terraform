# Configure the docker provider
provider "docker" {
  host = "tcp://192.168.8.62:2376"

}

resource "docker_image" "nginxweb"{
  name = "uzzal2k5/nginx"

}
# Create a container
resource "docker_container" "nginx-server" {
  name = "nginx-server"
  image = "${docker_image.nginxweb.latest}"
  ports {
    internal = 80
    external =  80

  }
  volumes {
    volume_name = "content"
    container_path = "/var/www/html"
    host_path = "/home/uzzal/PROJECTS/nginxweb"
    read_only = true


  }
}