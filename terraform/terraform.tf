terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.71"
    }
  }
}

provider aws {
  region = var.aws_region
}

# S3 Backend for Terraform State
terraform {
  backend s3 {
    bucket  = "andrewjacksonio-control-tower-terraform"
    key     = "terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}
