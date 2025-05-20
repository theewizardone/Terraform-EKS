terraform {
  backend "s3" {
    bucket = "myawsbucketeks"
    key    = "jenkins/terraform.tfstate"
    region = "us-east-1"
  }
}