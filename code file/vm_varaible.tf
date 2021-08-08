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
