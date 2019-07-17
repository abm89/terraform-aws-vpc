provider "aws" {
  region                  = var.accept_region
  shared_credentials_file = "/path/to/credentials"
  profile                 = "default"
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = var.pcx_id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

