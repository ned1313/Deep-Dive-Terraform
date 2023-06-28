##################################################################################
# IMPORTS
##################################################################################

import {
  to = module.main.aws_vpc.this[0]
  id = "VPC" #VPC
}

import {
  to = module.main.aws_subnet.public[0]
  id = "PublicSubnet1" #PublicSubnet1
}

import {
  to = module.main.aws_subnet.public[1]
  id = "PublicSubnet2" #PublicSubnet2
}

import {
  to = module.main.aws_internet_gateway.this[0]
  id = "InternetGateway" #InternetGateway
}

import {
  to = module.main.aws_route.public_internet_gateway[0]
  id = "DefaultPublicRoute" #DefaultPublicRoute
}

import {
  to = module.main.aws_route_table.public[0]
  id = "PublicRouteTable" #PublicRouteTable
}

import {
  to = module.main.aws_route_table_association.public[0]
  id = "PublicSubnet1/PublicRouteTable" #PublicSubnet1/PublicRouteTable
}

import {
  to = module.main.aws_route_table_association.public[1]
  id = "PublicSubnet2/PublicRouteTable" #PublicSubnet2/PublicRouteTable
}

import {
  to = aws_security_group.ingress
  id = "NoIngressSecurityGroup" #NoIngressSecurityGroup
}
