module "ecs" {
  source = "./ecs"

  name    = "${var.candidate}-candidate-test"
  vpc_id  = "${module.vpc.vpc_id}"
  subnets = "${module.vpc.private_subnets}"
}
