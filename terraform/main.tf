# Generate unique ID for bucket
resource "random_id" "bucket_id" {
  byte_length = 4
}

# Create S3 bucket
resource "aws_s3_bucket" "demo" {
  bucket = var.s3_bucket_name
  acl    = "private"
}

# Create EC2 instance
resource "aws_instance" "lab_ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "TerraformLabInstance"
  }
}

# Output EC2 public IP
output "ec2_public_ip" {
  value = aws_instance.lab_ec2.public_ip
}

# Output S3 bucket name
output "s3_bucket" {
  value = aws_s3_bucket.demo.bucket
}
