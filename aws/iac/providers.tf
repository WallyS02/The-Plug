provider "aws" {
  region = var.region
  alias = "main"

  default_tags {
    tags = {
      Project = "the-plug"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias = "cloudfront"
}