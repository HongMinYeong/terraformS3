output "website_endpoint" {
  value = aws_s3_bucket.bucket1.website_endpoint
  description = "The endpoint for the S3 bucket website."
}
