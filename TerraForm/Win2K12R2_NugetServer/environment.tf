module "nugetserver" {
  source = "./nugetserver"
  tag_environment = "Production"
  tag_owner = "tbc"
  tag_cost_code = ""
  vpc_id = "vpc-0f808f6a"
  subnet_id = "subnet-3e7e4f67"
  nuget_api_key = "MySuperWeakKey"
  packagesPath = ""
  nuget_instance_type = "t2.micro"
  nuget_server_keypair = "Tr"
}


