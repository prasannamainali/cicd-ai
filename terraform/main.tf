#############################################
# Terraform: AWS Free-Tier Demo Infrastructure
# Creates:
#  - EC2 instance (t2.micro)
#  - S3 bucket
#  - ECR Docker registry
#############################################

# ---------- 1. Define Terraform and AWS provider ----------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"
}

# ---------- 2. Configure AWS region ----------
provider "aws" {
  region = var.aws_region
}

# ---------- 3. Define variables ----------
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-2"
}

variable "key_pair_path" {
  description = "Path to your public key (.pub) for SSH access"
  default     = "/Users/prasannasmac/Downloads/lab_key.pub"
}

variable "ec2_ami" {
  description = "Amazon Linux 2 AMI (free-tier eligible)"
  default     = "ami-08962a4068733a2b6"
}

variable "instance_type" {
  description = "EC2 instance type (t2.micro = free tier)"
  default     = "t2.micro"
}

variable "s3_bucket_name" {
  description = "Unique S3 bucket name"
  default     = "my-terraform-lab-bucket-demo"
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  default     = "pyspark-demo-repo"
}

# ---------- 4. Create EC2 Key Pair ----------
resource "aws_key_pair" "lab_key" {
  key_name   = "lab_key"
  public_key = file(var.key_pair_path)
}

# ---------- 5. Create Security Group ----------
resource "aws_security_group" "lab_sg" {
  name        = "lab-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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

# ---------- 6. Get Default VPC ----------
data "aws_vpc" "default" {
  default = true
}

# ---------- 6b. Get Subnets of the Default VPC ----------
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# ---------- 7. Launch EC2 Instance ----------
resource "aws_instance" "lab_ec2" {
  ami           = var.ec2_ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.lab_key.key_name
  subnet_id     = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  tags = {
    Name = "TerraformLabEC2"
  }
}

# ---------- 8. Create S3 Bucket ----------
resource "aws_s3_bucket" "lab_bucket" {
  bucket = var.s3_bucket_name
  tags = {
    Name = "TerraformLabBucket"
  }
}

# ---------- 9. Create ECR Repository ----------
resource "aws_ecr_repository" "lab_repo" {
  name = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "TerraformLabECR"
  }
}

# ---------- 10. Output section ----------
output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.lab_ec2.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.lab_bucket.bucket
}

output "ecr_repo_url" {
  value = aws_ecr_repository.lab_repo.repository_url
}
