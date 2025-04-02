provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project = "the-plug"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "cloudfront"
}