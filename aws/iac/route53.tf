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
  enable_dnssec              = true
  key_management_service_arn = module.kms_dnssec.key_arn
}

module "kms_dnssec" {
  source = "./modules/kms"

  description         = "Key for Route 53 DNSSEC"
  alias_name          = "dnssec"
  enable_key_rotation = false

  additional_policies = data.aws_iam_policy_document.dnssec_kms_policy.json
}

data "aws_iam_policy_document" "dnssec_kms_policy" {
  statement {
    sid    = "AllowRoute53DNSSECService"
    effect = "Allow"
    actions = [
      "kms:GetPublicKey",
      "kms:Sign"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["dnssec-route53.amazonaws.com"]
    }
  }
}