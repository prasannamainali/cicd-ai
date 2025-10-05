# EC2 instance variables
variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  # Amazon Linux 2 free-tier AMI in us-east-2
  default = "ami-0c02fb55956c7d316"
}

variable "key_name" {
  description = "Name of an existing AWS Key Pair"
  default     = "lab_key"
}

# S3 bucket name
variable "s3_bucket_name" {
  default = "pyspark-demo-bucket-${random_id.bucket_id.hex}"
}
