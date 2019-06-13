data "aws_caller_identity" "current" {}

provider "aws" {
  region = "${var.request_region}"
  shared_credentials_file = "/path/to/credentials"
  profile = "default"
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = "${var.request_vpc_id}"
  peer_vpc_id   = "${var.accept_vpc_id}"
  #peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  peer_region   = "${var.accept_region}"
  auto_accept   = false

  tags = {
    Side = "Requester"
  }
}
