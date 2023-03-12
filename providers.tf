terraform {
  backend "s3" {
    bucket               = "terraform-state-cyber-110323"
    key                  = "terraform.json"   
    region               = "eu-west-2"
    # dynamodb_table       = "terraform-state"
  }
}

provider "aws" {
  region = "eu-west-2"

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}