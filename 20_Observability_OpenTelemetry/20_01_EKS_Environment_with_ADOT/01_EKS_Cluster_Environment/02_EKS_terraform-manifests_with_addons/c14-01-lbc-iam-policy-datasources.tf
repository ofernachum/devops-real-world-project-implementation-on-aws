# Datasource: AWS Load Balancer Controller IAM Policy get
# from aws-load-balancer-controller/ GIT Repo (latest)
# Using the http provider declared in c1_versions.tf, this datasource will fetch
# the IAM policy JSON file from the AWS Load Balancer Controller GitHub repo.

data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

# LBC IAM Policy
/*
output "lbc_iam_policy" {
  value = data.http.lbc_iam_policy.response_body
}
*/

