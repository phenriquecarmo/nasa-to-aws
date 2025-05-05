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
  key_name   = "nasaws-instance-key-2"
  public_key = var.ec2_ssh_key
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow SSH, HTTP, and custom port 9092"

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

resource "aws_eip" "nasa_eip" {
}

resource "aws_eip_association" "nasa_eip_assoc" {
  instance_id   = aws_instance.ec2_instance.id
  allocation_id = aws_eip.nasa_eip.id
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
              #!/bin/bash
              yum update -y
              yum install -y aws-cli jq

              SECRET=$(aws secretsmanager get-secret-value --region sa-east-1 --secret-id pgsql_access_nasaws_db --query SecretString --output text)

              DB_USERNAME=$(echo $$SECRET | jq -r .username)
              DB_PASSWORD=$(echo $$SECRET | jq -r .password)
              DB_HOST=$(echo $$SECRET | jq -r .host)
              DB_PORT=$(echo $$SECRET | jq -r .port)
              DB_NAME=$(echo $$SECRET | jq -r .dbname)
              DB_URL="jdbc:postgresql://$${DB_HOST}:$${DB_PORT}/$${DB_NAME}"

              echo "DB_URL=$$DB_URL" >> /etc/environment
              echo "DB_USERNAME=$$DB_USERNAME" >> /etc/environment
              echo "DB_PASSWORD=$$DB_PASSWORD" >> /etc/environment

              echo "Secrets loaded into environment."
              EOF

}

output "public_ip" {
  value = aws_eip.nasa_eip.public_ip
}
