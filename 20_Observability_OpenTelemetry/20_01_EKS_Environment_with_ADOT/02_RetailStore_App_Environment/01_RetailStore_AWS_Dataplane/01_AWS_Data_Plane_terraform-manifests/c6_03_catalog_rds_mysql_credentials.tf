# Use existing AWS Secrets Manager Secret (already created manually)

# Lookup the existing secret in AWS Secrets Manager:
data "aws_secretsmanager_secret" "retailstore_secret" {
  name = "retailstore-db-secret-1"
}


# This tells Terraform: “Now that you found the secret named 
# retailstore-db-secret-1, fetch its current version and read 
#the secret string stored inside it.”:
data "aws_secretsmanager_secret_version" "retailstore_secret_value" {
  secret_id = data.aws_secretsmanager_secret.retailstore_secret.id
}

# This block decodes the JSON string retrieved from AWS Secrets Manager 
#into a local Terraform variable that looks like this: 
# {
#   "username": "your-db-username",
#   "password": "your-db-password"
# }

locals {
  retailstore_secret_json = jsondecode(data.aws_secretsmanager_secret_version.retailstore_secret_value.secret_string)
}


# --------------------------------------------------------------------
# ⚠️ TEMPORARY DEBUG OUTPUTS (NOT RECOMMENDED FOR PRODUCTION)
# --------------------------------------------------------------------
# These outputs are only for verifying that Terraform correctly fetched
# username and password from AWS Secrets Manager. 
# REMOVE or comment out after validation to avoid exposing credentials.
# --------------------------------------------------------------------

output "debug_retailstore_secret_username" {
  description = "⚠️ For testing only: DB username from Secrets Manager"
  value       = local.retailstore_secret_json.username
  sensitive   = true
}

output "debug_retailstore_secret_password" {
  description = "⚠️ For testing only: DB password from Secrets Manager"
  value       = local.retailstore_secret_json.password
  sensitive   = true
}

# If you want to actually see the values just once (for validation), you can run:
# terraform output -json | jq -r '.debug_retailstore_secret_username.value'
# terraform output -json | jq -r '.debug_retailstore_secret_password.value'

