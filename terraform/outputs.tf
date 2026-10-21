output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "web_url" {
  value = "http://${aws_instance.web.public_ip}"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.assets.id
}

output "asset_uri" {
  description = "Private S3 URI, not a public web URL"
  value       = "s3://${aws_s3_bucket.assets.id}/${aws_s3_object.demo.key}"
}
