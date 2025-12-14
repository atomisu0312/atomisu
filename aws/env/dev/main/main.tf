terraform {
  backend "s3" {
    bucket = "terraform-atomisu"
    key    = "terraform/atomisu/dev/main"
    region = "ap-northeast-1" # ここにregionを追加
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "lambda_image_viewer" {
  source               = "../../../modules/lambda/imageViewer"
  lambda_function_name = "lambda_image_viewer"
  ecr_repository_name  = "img_viewer2_nextjs_action"
  application_port     = "3030"
}

module "lambda_my_good_stuff" {
  source               = "../../../modules/lambda/myGoodStuff"
  lambda_function_name = "my_good_stuff"
  ecr_repository_name  = "my_good_stuff_action"
  application_port     = "3030"
}

module "network" {
  source = "../../../modules/network"

  vpc-cidr        = "10.1.0.0/16"
  vpc-name        = "atomisu-terraform-vpc"
  env-name        = "dev"
  private-subnets = ["private-1a", "private-1c", "private-1d"]
  public-subnets  = ["public-1a", "public-1c", "public-1d"]
  az-list         = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

module "github_provider" {
  source = "../../../modules/github_provider"
}