# Create VPC for US-WEST-2
module "vpc-us-west-2" {
    source = "vpc-us-west-2"
    region = "us-west-2"
}

# Create VPC for EU-WEST-2
module "vpc-eu-west-1" {
    source = "vpc-eu-west-1"
    region = "eu-west-1"
}
# Create VPC for US-EAST-1
module "vpc-us-east-1" {
    source = "vpc-us-east-1"
    region = "us-east-1"
}

module "peering-us-east-to-us-west-init" {
    source = "pcx-us-east-to-us-west-init"
    request_region         = "${module.vpc-us-west-2.region}"
    request_vpc_id         = "${module.vpc-us-west-2.vpc_id}"
    accept_region          = "${module.vpc-us-east-1.region}"
    accept_vpc_id          = "${module.vpc-us-east-1.vpc_id}"
}

module "peering-us-east-to-us-west-accept" {
    source = "pcx-us-east-to-us-west-accept"
    pcx_id                 = "${module.peering-us-east-to-us-west-init.pcx_id}"
    accept_region          = "${module.vpc-us-east-1.region}"
}

module "peering-us-east-to-eu-west-init" {
    source = "pcx-us-east-to-eu-west-init"
    request_region         = "${module.vpc-eu-west-1.region}"
    request_vpc_id         = "${module.vpc-eu-west-1.vpc_id}"
    accept_region          = "${module.vpc-us-east-1.region}"
    accept_vpc_id          = "${module.vpc-us-east-1.vpc_id}"
}

module "peering-us-east-to-eu-west-accept" {
    source = "pcx-us-east-to-eu-west-accept"
    pcx_id                 = "${module.peering-us-east-to-eu-west-init.pcx_id}"
    accept_region          = "${module.vpc-us-east-1.region}"
}

module "peering-us-west-to-eu-west-init" {
    source = "pcx-us-west-to-eu-west-init"
    request_region         = "${module.vpc-eu-west-1.region}"
    request_vpc_id         = "${module.vpc-eu-west-1.vpc_id}"
    accept_region          = "${module.vpc-us-west-2.region}"
    accept_vpc_id          = "${module.vpc-us-west-2.vpc_id}"
}

module "peering-us-west-to-eu-west-accept" {
    source = "pcx-us-west-to-eu-west-accept"
    pcx_id                 = "${module.peering-us-west-to-eu-west-init.pcx_id}"
    accept_region          = "${module.vpc-us-west-2.region}"
}