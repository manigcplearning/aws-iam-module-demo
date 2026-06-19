app_name     = "myapp"
drn          = "1234"
environment  = "non-prod"
resource_key = "s3-read"
description  = "Allows read-only access to a specific S3 bucket."

policy_document = <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3ReadOnly",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-test-bucket",
        "arn:aws:s3:::my-test-bucket/*"
      ]
    }
  ]
}
EOT
