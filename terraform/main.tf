# main.tf

# ---------------------------
# Provider
# ---------------------------
provider "aws" {
  region = "us-east-2"  # update to your region
}

# ---------------------------
# Random ID for unique names
# ---------------------------
resource "random_id" "bucket_id" {
  byte_length = 4
}

# ---------------------------
# Key Pair
# ---------------------------
resource "aws_key_pair" "lab_key" {
  key_name   = "lab_key"
  public_key = file("~/.ssh/id_rsa.pub")  # path to your local public key
}

# ---------------------------
# EC2 Instance
# ---------------------------
resource "aws_instance" "lab_ec2" {
  ami           = "ami-0c2b8ca1dad447f8a"  # update for us-east-2 free tier Ubuntu
  instance_type = "t2.micro"
  key_name      = aws_key_pair.lab_key.key_name

  tags = {
    Name = "pyspark-demo"
  }
}

# ---------------------------
# S3 Bucket
# ---------------------------
resource "aws_s3_bucket" "bucket" {
  bucket = "pyspark-demo-bucket-${random_id.bucket_id.hex}"
  acl    = "private"
}

# ---------------------------
# Outputs
# ---------------------------
output "ec2_public_ip" {
  value = aws_instance.lab_ec2.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}
