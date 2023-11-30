

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
			"sudo docker run -p 80:80 httpd" 
    ]

		connection {
			host     = vultr_instance.example_server.main_ip
			type        = "ssh"
			user        = "root"
			private_key = file("/Users/sathiraumesh/Desktop/ss/example_rsa")  # Replace with the path to your SSH private key
			timeout     = "2m"
		}
	}
}

