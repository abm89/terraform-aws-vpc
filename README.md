# terraform - work in progress

This is just some stuff I whipped together. This deployment creates two VPCs (one in each region), with inside and outside subnets in each VPC. This also deploys EC2 instances inside of the VPCs.

## VPC Peering
VPC peering currently does not work. It needs to be able to peer the two VPCs together without user intervention.