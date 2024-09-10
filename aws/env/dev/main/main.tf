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

module "lambda_image_viewer" {
  source               = "../../../modules/lambda/imageViewer"
  lambda_function_name = "lambda_image_viewer"
  ecr_repository_name  = "img_viewer2_nextjs_action"
  application_port     = "3030"
}
