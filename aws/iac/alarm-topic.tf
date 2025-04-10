module "alarm_topic" {
  source = "./modules/alarm-topic"

  name_suffix = "dev"
  email       = var.email # use .tfvars file
}