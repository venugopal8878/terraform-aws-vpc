resource "aws_vpc_peering_connection" "peering" {
  count =var.is_peering_required ? 1:0
  #peer_owner_id = var.peer_owner_id self peering no required
  vpc_id        = aws_vpc.main.id #requsestor 
  peer_vpc_id = data.aws_vpc.default.id           #acceptor we need to get default vpc id by using data source

auto_accept = true

tags = merge(
    var.common_tags,
    var.vpc_peering_tags,
    {
        Name = "${local.resource_name}-default"
    }
)

}

#routes peering
resource "aws_route" "public_peering" {
 count =var.is_peering_required ? 1:0 #when peering rquired only it executed so we kept this statement
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id    #here name is getting index peering [0] like coming
}


resource "aws_route" "private_peering" {
 count =var.is_peering_required ? 1:0 #when peering rquired only it executed so we kept this statement
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id    #here name is getting index peering [0] like coming
}

resource "aws_route" "database_peering" {
 count =var.is_peering_required ? 1:0 #when peering rquired only it executed so we kept this statement
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id    #here name is getting index peering [0] like coming
}

#default vpc peering now route table

resource "aws_route" "default" {
 count =var.is_peering_required ? 1:0 #when peering rquired only it executed so we kept this statement
  route_table_id            = data.aws_route_table.main.route_table_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id    #here name is getting index peering [0] like coming
}