# resource "aws_instance" "ec2_instance" {
#   ami           = "ami-05b10e08d247fb927" # us-east-1 AMI
#   # ami           = "ami-" # sa-east-1 AMI
#
#   instance_type = "t3.micro"
#
#   root_block_device {
#     delete_on_termination = true
#   }
#
#   tags = {
#     Name = "NasaCloudProject"
#   }

  # provisioner "file" {
  #   source      = ""
  #   destination = ""
  # }
  #
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo yum install -y java-1.8.0-openjdk",
  #     "java -jar /home/ec2-user/application.jar"
  #   ]
  #
  #   connection {
  #     type        = "ssh"
  #     user        = "ec2-user"
  #     private_key = file("/private-key.pem")
  #     host        = self.public_ip
  #   }
  # }
# }