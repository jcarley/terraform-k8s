terraform {
  backend "s3" {
    bucket = "com.datica.jcarley"
    key    = "k8s/state-store"
    region = "us-west-2"
  }
}
