module "route53" {
  source = "./modules/route53"

  domain_name        = "" # TODO get domain name
  create_hosted_zone = true
  private_zone       = false
  records = [
    {
      name = "cdn"
      type = "A"
      alias = {
        name    = module.cloudfront.domain_name
        zone_id = module.cloudfront.hosted_zone_id
      }
    },
    {
      name = "alb"
      type = "A"
      alias = {
        name    = module.alb.dns_name
        zone_id = module.alb.hosted_zone_id
      }
    }
  ]
  enable_dnssec              = false
  key_management_service_arn = module.kms_dnssec.key_arn
}

module "kms_dnssec" {
  source = "./modules/kms"

  description         = "Key for Route 53 DNSSEC"
  alias_name          = "dnssec"
  enable_key_rotation = false # TODO rotate key?

  additional_policies = [
    data.aws_iam_policy_document.TODO
  ]
}

# TODO DNSSEC key policies
data "aws_iam_policy_document" "TODO" {
  statement {
    sid    = ""
    effect = ""
    principals {
      type        = ""
      identifiers = [""]
    }
    actions   = [""]
    resources = [""]
    condition {
      test     = ""
      variable = ""
      values   = [""]
    }
  }
}