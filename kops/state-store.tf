terraform {
  backend "s3" {
    bucket = "com.finishfirstsoftware.deploy"
    key    = "k8s/state-store"
    region = "us-west-2"
  }
}
