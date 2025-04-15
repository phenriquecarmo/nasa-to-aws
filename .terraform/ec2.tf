resource "aws_iam_role" "ec2_role" {
  name = "ec2_secrets_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_and_sns_policy" {
  name        = "AllowSecretsManagerAndSNSAccess"
  description = "Allow EC2 to read specific secrets from Secrets Manager and publish to SNS"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = "arn:aws:sns:sa-east-1:699475950124:nasa-cloud-project-topic"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets_and_sns_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_and_sns_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_key_pair" "deployer" {
  key_name   = "nasaws-instance-key"
  public_key = file("/Users/paulocarmo/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_instance" {
  ami                    = "ami-092cd6a84ad570057"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer.key_name
  security_groups        = [aws_security_group.allow_http_ssh.name]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  root_block_device {
    delete_on_termination = true
  }

  tags = {
    Name = "NasaCloudProject"
  }

  user_data = <<-EOF
  rpm --import https://yum.corretto.aws/corretto.key
  curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
  yum install -y java-21-amazon-corretto-devel

  yum install -y aws-cli jq

  NASA_API_KEY=$(aws secretsmanager get-secret-value --secret-id nasa_api_key --query SecretString --output text | jq -r '.NASA_API_KEY')

  echo "export NASA_API_URL=https://api.nasa.gov" >> /etc/profile.d/nasa_api.sh
  echo "export NASA_API_KEY=$NASA_API_KEY" >> /etc/profile.d/nasa_api.sh
  chmod +x /etc/profile.d/nasa_api.sh
  source /etc/profile.d/nasa_api.sh
EOF

  provisioner "file" {
    source      = "../build/libs/nasaws-0.0.1-SNAPSHOT.jar"
    destination = "/home/ec2-user/application.jar"
  }

  provisioner "remote-exec" {
    inline = [
      "nohup java -jar /home/ec2-user/application.jar > /home/ec2-user/app.log 2>&1 &"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/Users/paulocarmo/.ssh/id_rsa")
    host        = self.public_ip
  }
}

output "public_ip" {
  value = aws_instance.ec2_instance.public_ip
}