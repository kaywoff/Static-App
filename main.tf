provider "aws" {
  region = "us-east-1"
}
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# Variable for dynamic bucket name
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "my-dynamic-string-bucket"
}

# Variable for the dynamic string in HTML
variable "dynamic_string" {
  description = "The dynamic string to be displayed on the HTML page"
  type        = string
  default     = "Kobe's dynamic string"
}

# Create an S3 Bucket
resource "aws_s3_bucket" "web_bucket" {
  bucket = var.bucket_name
}

# Enable Public Access to the Bucket (Overrides Default Blocked Setting)
resource "aws_s3_bucket_public_access_block" "web_bucket_access" {
  bucket                  = aws_s3_bucket.web_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy to Allow Public Read Access
resource "aws_s3_bucket_policy" "web_bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.web_bucket.arn}/*"
      }
    ]
  })
}

# Enable S3 Static Website Hosting
resource "aws_s3_bucket_website_configuration" "web_bucket_website" {
  bucket = aws_s3_bucket.web_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# Upload the HTML File to S3 with a Dynamic String
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.web_bucket.id
  key          = "index.html"
  content      = <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dynamic String</title>
</head>
<body>
    <h1>The saved string is ${var.dynamic_string}</h1>
</body>
</html>
EOF
  content_type = "text/html"
}

# Output the S3 Website URL
output "website_url" {
  value = "http://${aws_s3_bucket.web_bucket.bucket}.s3-website-${var.region}.amazonaws.com"
}