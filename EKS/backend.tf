terraform {
  backend "s3" {
    bucket = "n"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}
