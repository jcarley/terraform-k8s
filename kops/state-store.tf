terraform {
  backend "s3" {
    bucket = "com.example.jcarley.deploy"
    key    = "k8s/state-store"
    region = "us-west-2"
  }
}
