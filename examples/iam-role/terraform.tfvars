app_name          = "myapp"
drn               = "1234"
environment       = "non-prod"
resource_key      = "lambda-exec"
service_principal = "lambda.amazonaws.com"

# Reference the policy we created in Component 1
# Replace with the actual ARN from your AWS Console after Component 1 apply
managed_policy_arns = [
  "id=arn:aws:iam::968909452923:policy/myapp-1234-non-prod-s3-read"
]
