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

variable "instance_count" {
  default = 1  # Change this value to the desired number of instances
}

# Define a Vultr server resource
resource "vultr_instance" "example_server" {
	count   = var.instance_count 
  region   = "fra"  # Replace with your desired region
  plan     = "vc2-1c-1gb"  # Replace with your desired plan
	os_id = 1743
  hostname   = "docker-vm"
	label   = "example-instance-${count.index + 1}"
}



