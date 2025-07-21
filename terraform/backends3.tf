terraform {
  backend "s3" {
    bucket         = "jaykape-s3-awsproj-tfstate-backend"
    key            = "landingpage-crm/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
