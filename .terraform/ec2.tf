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
  public_key = var.ssh_public_key
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
}

output "public_ip" {
  value = aws_eip.nasa_eip.public_ip
}
