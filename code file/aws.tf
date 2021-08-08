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