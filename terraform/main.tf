# ============================
# Provider configuration
# ============================
provider "aws" {
  region = "us-east-2"       # Change region if needed
}

# ============================
# Generate random suffix for uniqueness
# ============================
resource "random_id" "bucket_id" {
  byte_length = 4
}

# ============================
# S3 Bucket creation
# ============================
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "pyspark-demo-${random_id.bucket_id.hex}"
  acl    = "private"

  tags = {
    Name = "pyspark-demo-bucket"
  }
}

# ============================
# Key Pair creation
# ============================
# Provide your public key file path here
resource "aws_key_pair" "lab_key" {
  key_name   = "lab_key"
  public_key = file("lab_key.pub") 
}

# ============================
# Security Group to allow SSH
# ============================
resource "aws_security_group" "ssh_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # WARNING: public SSH access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ============================
# EC2 Instance creation
# ============================
resource "aws_instance" "lab_ec2" {
  ami                    = "ami-0c02fb55956c7d316"  # Amazon Linux 2 in us-east-2
  instance_type          = "t2.micro"              # Free tier
  key_name               = aws_key_pair.lab_key.key_name
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]

  tags = {
    Name = "pyspark-demo-ec2"
  }
}

# ============================
# Outputs
# ============================
output "ec2_public_ip" {
  value = aws_instance.lab_ec2.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.demo_bucket.bucket
}
