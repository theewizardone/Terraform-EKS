terraform {
  backend "s3" {
    bucket = "myawsbucketeks"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}
