locals {
  location         = "brazilsouth"
  name             = "clubcloudwill"
  rg_name          = "rg"
  vnet_name        = "vnet"
  subnet_name      = "subnet"
  ambiente         = ["ti", "tu"]
  address_space    = ["10.1.0.0/16"]
  address_space_tu = ["10.2.0.0/16"]
  cidr_ti          = "10.1.0.0/16"
  cidr_tu          = "10.2.0.0/16"
  next_bits_ahead  = 8
  net_num          = 0
  subnet_ti = {
    subnet1 = {
      name   = "APIM",
      subnet = cidrsubnet(local.cidr_ti, 8, local.net_num)
    },
    subnet2 = {
      name   = "VM_Subnet",
      subnet = cidrsubnet(local.cidr_ti, 8, local.net_num + 1)
  } }
  subnet_tu = {
    subnet1 = {
      name   = "APIM",
      subnet = cidrsubnet(local.cidr_tu, 8, local.net_num)
    },
    subnet2 = {
      name   = "VM_Subnet",
      subnet = cidrsubnet(local.cidr_tu, 8, local.net_num + 1)
  } }
}
module "rg_ti" {
  source = "./Modulos/RG"

  location = local.location
  rg_name  = "${local.name}-${local.ambiente[0]}-${local.rg_name}"
}
module "vnet_ti" {
  source = "./Modulos/VNET"

  location      = local.location
  vnet_name     = "${local.name}-${local.ambiente[0]}-${local.vnet_name}"
  rg_name       = module.rg_ti.rg_name
  address_space = local.address_space
  depends_on = [
    module.rg_ti
  ]
}
module "subnet_ti" {
  source = "./Modulos/Subnet"

  location    = local.location
  subnet_name = "${local.name}-${local.ambiente[0]}-${local.subnet_name}"
  vnet_name   = module.vnet_ti.vnet_name
  rg_name     = module.rg_ti.rg_name
  subnet_ti   = local.subnet_ti
  depends_on = [
    module.vnet_ti
  ]
}
module "rt_ti" {
  source = "./Modulos/Route_table"

  location  = local.location
  rt_name   = "${local.name}-${local.ambiente[0]}-route_table"
  subnet_id = module.subnet_ti.subnet1_id
  rg_name   = module.rg_ti.rg_name
  depends_on = [
    module.subnet_ti
  ]
}

module "nic_ti" {
  source = "./Modulos/NIC"

  location  = local.location
  nic_name  = "${local.name}-${local.ambiente[0]}-nic"
  subnet_id = module.subnet_ti.subnet1_id
  rg_name   = module.rg_ti.rg_name
  depends_on = [
    module.subnet_ti
  ]
}

module "nsg_ti" {
  source = "./Modulos/NSG"

  location    = local.location
  nsg_name    = "${local.name}-${local.ambiente[0]}-nsg"
  subnet_name = module.subnet_ti.subnet1_id
  rg_name     = module.rg_ti.rg_name
  depends_on = [
    module.subnet_ti
  ]
}

### TU ###

module "rg_tu" {
  source = "./Modulos/RG"

  location = local.location
  rg_name  = "${local.name}-${local.ambiente[1]}-${local.rg_name}"
}
module "vnet_tu" {
  source = "./Modulos/VNET"

  location      = local.location
  vnet_name     = "${local.name}-${local.ambiente[1]}-${local.vnet_name}"
  rg_name       = module.rg_tu.rg_name
  address_space = local.address_space_tu
  depends_on = [
    module.rg_tu
  ]
}
module "subnet_tu" {
  source = "./Modulos/Subnet"

  location    = local.location
  subnet_name = "${local.name}-${local.ambiente[1]}-${local.subnet_name}"
  vnet_name   = module.vnet_tu.vnet_name
  rg_name     = module.rg_tu.rg_name
  subnet_ti   = local.subnet_tu
  depends_on = [
    module.vnet_tu
  ]
}
module "rt_tu" {
  source = "./Modulos/Route_table"

  location  = local.location
  rt_name   = "${local.name}-${local.ambiente[1]}-route_table"
  subnet_id = module.subnet_tu.subnet1_id
  rg_name   = module.rg_tu.rg_name
  depends_on = [
    module.subnet_tu
  ]
}

module "nic_tu" {
  source = "./Modulos/NIC"

  location  = local.location
  nic_name  = "${local.name}-${local.ambiente[1]}-nic"
  subnet_id = module.subnet_tu.subnet1_id
  rg_name   = module.rg_tu.rg_name
  depends_on = [
    module.subnet_tu
  ]
}

module "nsg_tu" {
  source = "git::https://github.com/WilliamRocha30/Azure_NSG.git"

  location = local.location
  nsg_name = "${local.name}-${local.ambiente[1]}-nsg"
  subnet_name = module.subnet_tu.subnet1_id
  rg_name   = module.rg_tu.rg_name
  depends_on = [
    module.subnet_tu
  ]
}
