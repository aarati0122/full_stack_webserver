# Full stack webserver

📄Task:

1. Create 3 different workspace and create a full stack webserver on 3 different cloud.

2. Launch wordpress on GCP and RDS service using AWS

## Create 3 different workspace and create a full stack webserver on 3 different cloud.

i] Create 3 different workspace
First check terraform workspace list ,and create three different workspce that I mention in following screenshot
```
terraform workspace list
```
```
terraform workspace new [NAME]
```
![workspace](https://user-images.githubusercontent.com/60148173/128638675-0dbf9e92-08e9-4e6d-b284-5364bd808d23.PNG)

ii] Create three different full stack webserver on 3 different cloud 

## aws.tf provider
```
provider "aws" {
region = "ap-south-1"
profile = "default"
}
}

resource "aws_instance" "webos1" {
  ami = "ami-00bf4ae5a7909786c"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  security_groups = ["launch-wizard-4"]
  key_name = "terraform-key"
  tags = {
    Name = "workspace instance"
  }
  
}

resource "null_resource"​ "test1"​ {
 connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/AS/Desktop/Terraform LW/terraform-key.pem")
    host     = aws_instance.webos1.public_ip
  }


 provisioner "remote-exec"​ {
    inline = [
      "sudo yum install http -y"​,
      "sudo yum install php -y"​,
      "sudo systemctl start httpd"​,
      "sudo systemctl start php"​,
      "cd /var/www/html"
  }
}
```
## GCP provider file is name gcpprovider.tf

```
provider "google" {

credentials = file("/Users/AS/Desktop/Terraform LW/gpsvc.json")

project = "googleproject"
 region  = "us-central1"
 zone    = "us-central1-c"
}



resource "google_compute_instance" "apache_server" {
    name = "apache_server"
    machine_type = "f1-micro"

    tags = ["http-server"]

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-9"
        }
    }

    metadata_startup_script =  file("/Users/AS/Desktop/Terraform LW/apache2.sh")

scheduling {
        preemptible = true
        automatic_restart = false
    }

    network_interface {
        network ="default"
        access_config {

        }


}
}
```
Start up code for gcp server
```
!/bin/bash
sudo apt-get update && sudo apt -y install apache2
echo '<!doctype html><html><body><h1>Hello if you see this than you have apache running!</h1></body></html>' | sudo tee /var/www/html/index.html
```
## Now Azure cloud ,file Name is azureprovider.tf

```
provider "azurerm" {
	  version = "~> 1.4"
	  environment = "public"
}
resource "azurerm_resource_group" "network-rg" {
	  name     = "${lower(replace(var.app_name," ","-"))}-${var.environment}-rg"
	  location = var.location
	  tags = {
	    application = var.app_name
	    environment = var.environment
	  }
	}
	resource "azurerm_virtual_network" "network-vnet" {
	  name                = "${lower(replace(var.app_name," ","-"))}-${var.environment}-vnet"
	  address_space       = [var.network-vnet-cidr]
	  resource_group_name = azurerm_resource_group.network-rg.name
	  location            = azurerm_resource_group.network-rg.location
	  tags = {
	    application = var.app_name
	    environment = var.environment
	  }
	}
	resource "azurerm_subnet" "network-subnet" {
	  name                 = "${lower(replace(var.app_name," ","-"))}-${var.environment}-subnet"
	  address_prefix       = var.network-subnet-cidr
	  virtual_network_name = azurerm_virtual_network.network-vnet.name
	  resource_group_name  = azurerm_resource_group.network-rg.name
}
```
## azurevar.tf for azure provider
```
variable "company" {
	  type        = string
	  description = "This variable defines the company name used to build resources"
	}
	

	# application name 
	variable "app_name" {
	  type        = string
	  description = "This variable defines the application name used to build resources"
	}
	

	# application or company environment
	variable "environment" {
	  type        = string
	  description = "This variable defines the environment to be built"
	}
	

	# azure region
	variable "location" {
	  type        = string
	  description = "Azure region where the resource group will be created"
	  default     = "north europe"
    }

variable "network-vnet-cidr" {
	  type        = string
	  description = "The CIDR of the network VNET"
	}
	

	variable "network-subnet-cidr" {
	  type        = string
	  description = "The CIDR for the network subnet"
	}
```

## azureuserdata.tf 
```

sudo apt-get update
	sudo apt-get install -y apache2
	sudo systemctl start apache2
	sudo systemctl enable apache2
	echo "<h1>Azure Linux VM with Web Server</h1>" | sudo tee /var/www/html/index.html
```

## instance creation in azure file name vm_azure.tf
```
resource "random_password" "web-vm-password" {
	  length           = 16
	  min_upper        = 2
	  min_lower        = 2
	  min_special      = 2
	  number           = true
	  special          = true
	  override_special = "!@#$%&"
	}
	resource "random_string" "web-vm-name" {
	  length  = 8
	  upper   = false
	  number  = false
	  lower   = true
	  special = false
	}
	resource "azurerm_network_security_group" "web-vm-nsg" {
	  depends_on=[azurerm_resource_group.network-rg]
	  name                = "web-${lower(var.environment)}-${random_string.web-vm-name.result}-nsg"
	  location            = azurerm_resource_group.network-rg.location
	  resource_group_name = azurerm_resource_group.network-rg.name

	  security_rule {
	    name                       = "AllowWEB"
	    description                = "Allow web"
	    priority                   = 100
	    direction                  = "Inbound"
	    access                     = "Allow"
	    protocol                   = "Tcp"
	    source_port_range          = "*"
	    destination_port_range     = "80"
	    source_address_prefix      = "Internet"
	    destination_address_prefix = "*"
	  }
	

	  security_rule {
	    name                       = "AllowSSH"
	    description                = "Allow SSH"
	    priority                   = 150
	    direction                  = "Inbound"
	    access                     = "Allow"
	    protocol                   = "Tcp"
	    source_port_range          = "*"
	    destination_port_range     = "22"
	    source_address_prefix      = "Internet"
	    destination_address_prefix = "*"
	  }
	  tags = {
	    environment = var.environment
	  }
	}
	
	resource "azurerm_subnet_network_security_group_association" "web-vm-nsg-association" {
	  depends_on=[azurerm_resource_group.network-rg]
	

	  subnet_id                 = azurerm_subnet.network-subnet.id
	  network_security_group_id = azurerm_network_security_group.web-vm-nsg.id
	}
	
	resource "azurerm_public_ip" "web-vm-ip" {
	  depends_on=[azurerm_resource_group.network-rg]
	

	  name                = "web-${random_string.web-vm-name.result}-ip"
	  location            = azurerm_resource_group.network-rg.location
	  resource_group_name = azurerm_resource_group.network-rg.name
	  allocation_method   = "Static"
	  
	  tags = { 
	    environment = var.environment
	  }
	}

	resource "azurerm_network_interface" "web-private-nic" {
	  depends_on=[azurerm_resource_group.network-rg]
	  name                = "web-${random_string.web-vm-name.result}-nic"
	  location            = azurerm_resource_group.network-rg.location
	  resource_group_name = azurerm_resource_group.network-rg.name
	  
	  ip_configuration {
	    name                          = "internal"
	    subnet_id                     = azurerm_subnet.network-subnet.id
	    private_ip_address_allocation = "Dynamic"
	    public_ip_address_id          = azurerm_public_ip.web-vm-ip.id
	  }
	
	  tags = { 
	    environment = var.environment
	  }
	}

	resource "azurerm_virtual_machine" "web-vm" {
	  depends_on=[azurerm_network_interface.web-private-nic]
	  location              = azurerm_resource_group.network-rg.location
	  resource_group_name   = azurerm_resource_group.network-rg.name
	  name                  = "web-${random_string.web-vm-name.result}-vm"
	  network_interface_ids = [azurerm_network_interface.web-private-nic.id]
	  vm_size               = var.web_vm_size
	  license_type          = var.web_license_type
	  delete_os_disk_on_termination    = var.web_delete_os_disk_on_termination
	  delete_data_disks_on_termination = var.web_delete_data_disks_on_termination
	
	  storage_image_reference {
	    id        = lookup(var.web_vm_image, "id", null)
	    offer     = lookup(var.web_vm_image, "offer", null)
	    publisher = lookup(var.web_vm_image, "publisher", null)
	    sku       = lookup(var.web_vm_image, "sku", null)
	    version   = lookup(var.web_vm_image, "version", null)
	  }
	
	  storage_os_disk {
	    name              = "web-${random_string.web-vm-name.result}-disk"
	    caching           = "ReadWrite"
	    create_option     = "FromImage"
	    managed_disk_type = "Standard_LRS"
	  }
	
	  os_profile {
	    computer_name  = "web-${random_string.web-vm-name.result}-vm"
	    admin_username = var.web_admin_username
	    admin_password = random_password.web-vm-password.result
	    custom_data    = file("azure-user-data.sh")
	  }
	
	  os_profile_linux_config {
	    disable_password_authentication = false
	  }
	
	  tags = {
	    environment = var.environment
	  }
}

output "web_vm_name" {
	  description = "Virtual Machine name"
	  value       = azurerm_virtual_machine.web-vm.name
	}
	
	output "web_vm_ip_address" {
	  description = "Virtual Machine name IP Address"
	  value       = azurerm_public_ip.web-vm-ip.ip_address
	}
	
	output "web_vm_admin_username" {
	  description = "Username password for the Virtual Machine"
	  value       = azurerm_virtual_machine.web-vm.os_profile.*
	  #sensitive   = true
	}
	

	output "web_vm_admin_password" {
	  description = "Administrator password for the Virtual Machine"
	  value       = random_password.web-vm-password.result
	  
	}
```
## instnace variable ,vm_variable.tf

```
variable "web_vm_size" {
	  type        = string
	  description = "Size (SKU) of the virtual machine to create"
	}

	variable "web_license_type" {
	  type        = string
	  description = "Specifies the BYOL type for the virtual machine. Possible values are 'Windows_Client' and 'Windows_Server' if set"
	  default     = null
	}

	variable "web_delete_os_disk_on_termination" {
	  type        = string
	  description = "Should the OS Disk (either the Managed Disk / VHD Blob) be deleted when the Virtual Machine is destroyed?"
	  default     = "true"  # Update for your environment
	}
	

	variable "web_delete_data_disks_on_termination" {
	  description = "Should the Data Disks (either the Managed Disks / VHD Blobs) be deleted when the Virtual Machine is destroyed?"
	  type        = string
	  default     = "true"
	}
	

	variable "web_vm_image" {
	  type        = map(string)
	  description = "Virtual machine source image information"
	  default     = {
	    publisher = "Canonical"
	    offer     = "UbuntuServer"
	    sku       = "18.04-LTS" 
	    version   = "latest"
	  }
	}

	variable "web_admin_username" {
	  description = "Username for Virtual Machine administrator account"
	  type        = string
	  default     = ""
	}
	

	variable "web_admin_password" {
	  description = "Password for Virtual Machine administrator account"
	  type        = string
	  default     = ""
} 
Now do'terraform init'--> then go for 'terraform apply'



Follow the below link to launch wordpress on GCP and RDS service using AWS:

https://www.linkedin.com/pulse/launch-wordpress-gcp-rds-service-using-aws-rashni-ghosh/?published=t

```
