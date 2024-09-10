terraform {
  backend "s3" {
    bucket = "terraform-atomisu"
    key    = "terraform/dev/main"
    region = "ap-northeast-1" # ここにregionを追加
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
