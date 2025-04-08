module "alarm_topic" {
  source = "./modules/alarm-topic"

  email = var.email # use .tfvars file
}