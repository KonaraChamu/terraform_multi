

# main.tf

terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.17.1"
    }
  }
}

provider "vultr" {
  api_key = "SILLVA2A6J3F6S4SKKSNXAPFNZFMWNFF2MRA"
  rate_limit = 100
  retry_limit = 3
}


resource "vultr_ssh_key" "example" {
  name = "example created from terraform"

  ssh_key = "${file("example_rsa.pub")}"
}

resource "vultr_startup_script" "my_script" {
    name = "install docker"
    script = "IGVjaG8gImhlbGxvIg=="
}

# Define a Vultr server resource
resource "vultr_instance" "example_server" {
  region   = "fra"  # Replace with your desired region
  plan     = "vc2-1c-1gb"  # Replace with your desired plan
	os_id = 1743
	label      = "docker-vm"
  hostname   = "docker-vm"
	script_id = vultr_startup_script.my_script.id
	ssh_key_ids = [vultr_ssh_key.example.id]
}


resource "vultr_instance_ipv4" "my_instance_ipv4" {
    instance_id = "${vultr_instance.example_server.id}"
    reboot = false
}

output "server_ip" {
  value = vultr_instance.example_server.main_ip
}


resource "null_resource" "execute_command" {
  depends_on = [vultr_instance.example_server]  # Ensure the server is provisioned first

  provisioner "remote-exec" {
    inline = [
      "echo 'Executing a command on the server'",
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo service docker start",
    ]

		connection {
			host     = vultr_instance.example_server.main_ip
			type        = "ssh"
			user        = "root"
			private_key = file("example_rsa")  # Replace with the path to your SSH private key
			timeout     = "2m"
		}
	}
}

resource "null_resource" "mysql_container" {
  depends_on = [null_resource.execute_command]

  provisioner "remote-exec" {
    inline = [
      "sudo docker run --name mysql-db -e MYSQL_ROOT_PASSWORD=rootpassword -d mysql:latest"
    ]

    connection {
      type        = "ssh"
      host        = vultr_instance.example_server.main_ip
      user        = "root"
      private_key = file("example_rsa")
    }
  }
}

resource "null_resource" "wordpress_container" {
  depends_on = [null_resource.mysql_container]

  provisioner "remote-exec" {
    inline = [
      "sudo docker run --name wordpress-site -e WORDPRESS_DB_HOST=mysql-db -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=rootpassword -e WORDPRESS_DB_NAME=wordpress -p 8080:80 -d wordpress:latest",
			"docker logs wordpress-site"
    ]

    connection {
      type        = "ssh"
      host        = vultr_instance.example_server.main_ip
      user        = "root"
      private_key = file("example_rsa")
    }
  }
}
