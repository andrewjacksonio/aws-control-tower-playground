variable aws_region {
  default = "us-west-2"
}

variable org_accounts {
  type = list(object({
    name  = string
    email = string
  }))
}