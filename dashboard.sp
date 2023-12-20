dashboard "FedRAMP-Inventory-Dashboard" {
	title = "FedRAMP Inventory Dashboard"


  

card {
  sql = <<-EOQ
WITH
  vnets as (
    SELECT
      frontend_ip_configurations -> 0 -> 'properties' -> 'subnet' ->> 'id' as "VNet",
      id as "lb_id"
    FROM
      azure_lb
  ),
  public_ips as (
    SELECT
      *
    FROM
      azure_public_ip
  ),
  vnet_subnet as (
    SELECT
      subnets -> 0 ->> 'id' as "VNet",
      id as "gateway_id"
    FROM
      azure_nat_gateway
  ),
  vnet_subnet_vng as (
    SELECT
      ip_configurations -> 0 -> 'properties' -> 'subnet' ->> 'id' as "VNet",
      id as "gateway_id"
    FROM
      azure_virtual_network_gateway
  ),
  all_ips as (
    select
      vm_id,
      name as "Unique Asset Identifier",
      jsonb_array_elements_text(private_ips) as "IP",
      'Private' as "IP_Type"
    from
      azure_compute_virtual_machine
    where
      power_state = 'running'
    UNION ALL
    select
      vm_id,
      name as "Unique Asset Identifier",
      jsonb_array_elements_text(public_ips) as "IP",
      'Public' as "IP_Type"
    from
      azure_compute_virtual_machine
    where
      power_state = 'running'
  )
  -- Azure App Service Web App
  --added virtual field
SELECT
  title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  '' as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --region as "Location",
   cloud_environment || '-' || region as "Location",
  'Azure App Service Web App' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_app_service_web_app
UNION
--Azure CosmosDB Database
SELECT
  title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  '' as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --region as "Location",
   cloud_environment || '-' || region as "Location",
  'Azure CosmosDB Database' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_cosmosdb_sql_database
UNION
--Azure Front Door Inventory
SELECT
  title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  '' as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --region as "Location",
   cloud_environment || '-' || region as "Location",
  'Azure Front Door' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_frontdoor
UNION
--Kubertes Cluster Inventory
SELECT
  title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  '' as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --region as "Location",
   cloud_environment || '-' || region as "Location",
  'Azure AKS' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_kubernetes_cluster
UNION
-- Load Balancer Inventory
--Commented out "Comments" tag so fields length can match
SELECT
  azure_lb.title as "Unique Asset Identifier",
  frontend_ip_configurations -> 0 -> 'properties' ->> 'privateIPAddress' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  text(ip_address) as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  azure_lb.tags ->> 'Authenticated Scan' as "Authenticated Scan",
  azure_lb.tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --azure_lb.region as "Location",
   --cloud_environment || '-' || region as "Location",
   	      azure_lb.cloud_environment || '-' || azure_lb.region as "Location",
  'Azure Load Balancer' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  --azure_lb.tags ->> 'Comments' as "Comments",
  '' as "Serial #/Asset Tag#",
  --When position is greater than 0, vnet string contains subnet
  substring(
    vnets."VNet",
    strpos(vnets."VNet", '/virtualNetworks/') + length('/virtualNetworks/'),
    strpos(vnets."VNet", '/subnets/') - strpos(vnets."VNet", '/virtualNetworks/') - length('/virtualNetworks/')
  ) as "VLAN/Network ID",
  azure_lb.tags ->> 'Application Owner' as "Application Owner",
  azure_lb.tags ->> 'System Owner' as "System Owner",
  azure_lb.tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_lb
  left join vnets on vnets.lb_id = azure_lb.id
  left join public_ips ON public_ips.id = frontend_ip_configurations -> 0 -> 'properties' -> 'publicIPAddress' ->> 'id'
UNION
--Nat Gatewat Inventory
select
  azure_nat_gateway.title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  text(ip_address) as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  azure_nat_gateway.tags ->> 'Authenticated Scan' as "Authenticated Scan",
  azure_nat_gateway.tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --azure_nat_gateway.region as "Location",
   azure_nat_gateway.cloud_environment || '-' || azure_nat_gateway.region as "Location",
  'Azure NAT Gateway' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  --azure_nat_gateway.tags ->> 'Comments' as "Comments",
  '' as "Serial #/Asset Tag#",
  substring(
    vnet_subnet."VNet",
    strpos(vnet_subnet."VNet", '/virtualNetworks/') + length('/virtualNetworks/'),
    strpos(vnet_subnet."VNet", '/subnets/') - strpos(vnet_subnet."VNet", '/virtualNetworks/') - length('/virtualNetworks/')
  ) as "VLAN/Network ID",
  azure_nat_gateway.tags ->> 'Application Owner' as "Application Owner",
  azure_nat_gateway.tags ->> 'System Owner' as "System Owner",
  azure_nat_gateway.tags ->> 'Function' as "Function",
  '' as "End-of-Life"
from
  azure_nat_gateway
  left join vnet_subnet ON vnet_subnet."gateway_id" = azure_nat_gateway.id
  left join public_ips ON public_ips.id = public_ip_addresses -> 0 ->> 'id'
UNION
--Azure SQL Database Inventory
SELECT
  title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  '' as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --region as "Location",
      cloud_environment || '-' || region as "Location",
  'Azure SQL Database' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_sql_database
UNION
--Azure SQL Server Inventory  
SELECT
  title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  '' as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --region as "Location",
      cloud_environment || '-' || region as "Location",
  'Azure SQL Server' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_sql_server
UNION
--Virtual Network gateway Inventory
SELECT
  azure_virtual_network_gateway.title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  text(ip_address) as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  azure_virtual_network_gateway.tags ->> 'Authenticated Scan' as "Authenticated Scan",
  azure_virtual_network_gateway.tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --azure_virtual_network_gateway.region as "Location",
     azure_virtual_network_gateway.cloud_environment || '-' || azure_virtual_network_gateway.region as "Location",

  'Azure VNet Gateway' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  azure_virtual_network_gateway.type || ':' || azure_virtual_network_gateway.sku_name as "Software/Database Vendor",
  vpn_gateway_generation || ':' || sku_tier as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  azure_virtual_network_gateway.id as "Serial #/Asset Tag#",
  substring(
    vnet_subnet_vng."VNet",
    strpos(vnet_subnet_vng."VNet", '/virtualNetworks/') + length('/virtualNetworks/'),
    strpos(vnet_subnet_vng."VNet", '/subnets/') - strpos(vnet_subnet_vng."VNet", '/virtualNetworks/') - length('/virtualNetworks/')
  ) as "VLAN/Network ID",
  azure_virtual_network_gateway.tags ->> 'Application Owner' as "Application Owner",
  azure_virtual_network_gateway.tags ->> 'System Owner' as "System Owner",
  azure_virtual_network_gateway.tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_virtual_network_gateway
  left join vnet_subnet_vng ON vnet_subnet_vng."gateway_id" = azure_virtual_network_gateway.id
  left join public_ips ON public_ips.id = ip_configurations -> 0 -> 'properties' -> 'publicIPAddress' ->> 'id'
UNION
--Azure VM Fedramp Inventory
select
  name as "Unique Asset Identifier",
  CASE
    WHEN "IP_Type" = 'Private' THEN "IP"
  END as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  CASE
    WHEN "IP_Type" = 'Public' THEN "IP"
  END as "Public",
  '' as "DNS Name or URL",
  computer_name as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  os_name as "OS Name and Version",
  cloud_environment || '-' || region as "Location",
  'Azure VM' as "Asset Type",
  size as "Hardware Make/Model",
  '' as "In Latest Scan",
  image_offer as "Software/ Database Vendor",
  image_sku as "Software/ Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
from
  azure_compute_virtual_machine cvm
  left join all_ips ON all_ips.vm_id = cvm.vm_id
where
  power_state = 'running'
	




  EOQ
  title = "FedRAMP Inventory - Azure"
  width = 8
}
























table {
  title = "FedRAMP Inventory - Azure"
  width = 8

  sql   = <<-EOQ
WITH
  vnets as (
    SELECT
      frontend_ip_configurations -> 0 -> 'properties' -> 'subnet' ->> 'id' as "VNet",
      id as "lb_id"
    FROM
      azure_lb
  ),
  public_ips as (
    SELECT
      *
    FROM
      azure_public_ip
  ),
  vnet_subnet as (
    SELECT
      subnets -> 0 ->> 'id' as "VNet",
      id as "gateway_id"
    FROM
      azure_nat_gateway
  ),
  vnet_subnet_vng as (
    SELECT
      ip_configurations -> 0 -> 'properties' -> 'subnet' ->> 'id' as "VNet",
      id as "gateway_id"
    FROM
      azure_virtual_network_gateway
  ),
  all_ips as (
    select
      vm_id,
      name as "Unique Asset Identifier",
      jsonb_array_elements_text(private_ips) as "IP",
      'Private' as "IP_Type"
    from
      azure_compute_virtual_machine
    where
      power_state = 'running'
    UNION ALL
    select
      vm_id,
      name as "Unique Asset Identifier",
      jsonb_array_elements_text(public_ips) as "IP",
      'Public' as "IP_Type"
    from
      azure_compute_virtual_machine
    where
      power_state = 'running'
  )
  -- Azure App Service Web App
  --added virtual field
SELECT
  title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  '' as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --region as "Location",
   cloud_environment || '-' || region as "Location",
  'Azure App Service Web App' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_app_service_web_app
UNION
--Azure CosmosDB Database
SELECT
  title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  '' as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --region as "Location",
   cloud_environment || '-' || region as "Location",
  'Azure CosmosDB Database' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_cosmosdb_sql_database
UNION
--Azure Front Door Inventory
SELECT
  title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  '' as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --region as "Location",
   cloud_environment || '-' || region as "Location",
  'Azure Front Door' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_frontdoor
UNION
--Kubertes Cluster Inventory
SELECT
  title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  '' as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --region as "Location",
   cloud_environment || '-' || region as "Location",
  'Azure AKS' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_kubernetes_cluster
UNION
-- Load Balancer Inventory
--Commented out "Comments" tag so fields length can match
SELECT
  azure_lb.title as "Unique Asset Identifier",
  frontend_ip_configurations -> 0 -> 'properties' ->> 'privateIPAddress' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  text(ip_address) as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  azure_lb.tags ->> 'Authenticated Scan' as "Authenticated Scan",
  azure_lb.tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --azure_lb.region as "Location",
   --cloud_environment || '-' || region as "Location",
   	      azure_lb.cloud_environment || '-' || azure_lb.region as "Location",
  'Azure Load Balancer' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  --azure_lb.tags ->> 'Comments' as "Comments",
  '' as "Serial #/Asset Tag#",
  --When position is greater than 0, vnet string contains subnet
  substring(
    vnets."VNet",
    strpos(vnets."VNet", '/virtualNetworks/') + length('/virtualNetworks/'),
    strpos(vnets."VNet", '/subnets/') - strpos(vnets."VNet", '/virtualNetworks/') - length('/virtualNetworks/')
  ) as "VLAN/Network ID",
  azure_lb.tags ->> 'Application Owner' as "Application Owner",
  azure_lb.tags ->> 'System Owner' as "System Owner",
  azure_lb.tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_lb
  left join vnets on vnets.lb_id = azure_lb.id
  left join public_ips ON public_ips.id = frontend_ip_configurations -> 0 -> 'properties' -> 'publicIPAddress' ->> 'id'
UNION
--Nat Gatewat Inventory
select
  azure_nat_gateway.title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  text(ip_address) as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  azure_nat_gateway.tags ->> 'Authenticated Scan' as "Authenticated Scan",
  azure_nat_gateway.tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --azure_nat_gateway.region as "Location",
   azure_nat_gateway.cloud_environment || '-' || azure_nat_gateway.region as "Location",
  'Azure NAT Gateway' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  --azure_nat_gateway.tags ->> 'Comments' as "Comments",
  '' as "Serial #/Asset Tag#",
  substring(
    vnet_subnet."VNet",
    strpos(vnet_subnet."VNet", '/virtualNetworks/') + length('/virtualNetworks/'),
    strpos(vnet_subnet."VNet", '/subnets/') - strpos(vnet_subnet."VNet", '/virtualNetworks/') - length('/virtualNetworks/')
  ) as "VLAN/Network ID",
  azure_nat_gateway.tags ->> 'Application Owner' as "Application Owner",
  azure_nat_gateway.tags ->> 'System Owner' as "System Owner",
  azure_nat_gateway.tags ->> 'Function' as "Function",
  '' as "End-of-Life"
from
  azure_nat_gateway
  left join vnet_subnet ON vnet_subnet."gateway_id" = azure_nat_gateway.id
  left join public_ips ON public_ips.id = public_ip_addresses -> 0 ->> 'id'
UNION
--Azure SQL Database Inventory
SELECT
  title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  '' as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --region as "Location",
      cloud_environment || '-' || region as "Location",
  'Azure SQL Database' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_sql_database
UNION
--Azure SQL Server Inventory  
SELECT
  title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  '' as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --region as "Location",
      cloud_environment || '-' || region as "Location",
  'Azure SQL Server' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  '' as "Software/Database Vendor",
  '' as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_sql_server
UNION
--Virtual Network gateway Inventory
SELECT
  azure_virtual_network_gateway.title as "Unique Asset Identifier",
  '' as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  text(ip_address) as "Public",
  '' as "DNS Name or URL",
  '' as "NetBIOS Name",
  '' as "MAC Address",
  azure_virtual_network_gateway.tags ->> 'Authenticated Scan' as "Authenticated Scan",
  azure_virtual_network_gateway.tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  '' as "OS Name and Version",
  --azure_virtual_network_gateway.region as "Location",
     azure_virtual_network_gateway.cloud_environment || '-' || azure_virtual_network_gateway.region as "Location",

  'Azure VNet Gateway' as "Asset Type",
  '' as "Hardware Make/Model",
  '' as "In Latest Scan",
  azure_virtual_network_gateway.type || ':' || azure_virtual_network_gateway.sku_name as "Software/Database Vendor",
  vpn_gateway_generation || ':' || sku_tier as "Software/Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  azure_virtual_network_gateway.id as "Serial #/Asset Tag#",
  substring(
    vnet_subnet_vng."VNet",
    strpos(vnet_subnet_vng."VNet", '/virtualNetworks/') + length('/virtualNetworks/'),
    strpos(vnet_subnet_vng."VNet", '/subnets/') - strpos(vnet_subnet_vng."VNet", '/virtualNetworks/') - length('/virtualNetworks/')
  ) as "VLAN/Network ID",
  azure_virtual_network_gateway.tags ->> 'Application Owner' as "Application Owner",
  azure_virtual_network_gateway.tags ->> 'System Owner' as "System Owner",
  azure_virtual_network_gateway.tags ->> 'Function' as "Function",
  '' as "End-of-Life"
FROM
  azure_virtual_network_gateway
  left join vnet_subnet_vng ON vnet_subnet_vng."gateway_id" = azure_virtual_network_gateway.id
  left join public_ips ON public_ips.id = ip_configurations -> 0 -> 'properties' -> 'publicIPAddress' ->> 'id'
UNION
--Azure VM Fedramp Inventory
select
  name as "Unique Asset Identifier",
  CASE
    WHEN "IP_Type" = 'Private' THEN "IP"
  END as "IPv4 or IPv6 Address",
  'Yes' as "Virtual",
  CASE
    WHEN "IP_Type" = 'Public' THEN "IP"
  END as "Public",
  '' as "DNS Name or URL",
  computer_name as "NetBIOS Name",
  '' as "MAC Address",
  tags ->> 'Authenticated Scan' as "Authenticated Scan",
  tags ->> 'Baseline Configuration Name' as "Baseline Configuration Name",
  os_name as "OS Name and Version",
  cloud_environment || '-' || region as "Location",
  'Azure VM' as "Asset Type",
  size as "Hardware Make/Model",
  '' as "In Latest Scan",
  image_offer as "Software/ Database Vendor",
  image_sku as "Software/ Database Name & Version",
  '' as "Patch Level",
  '' as "Diagram Label",
  id as "Serial #/Asset Tag#",
  '' as "VLAN/Network ID",
  tags ->> 'Application Owner' as "Application Owner",
  tags ->> 'System Owner' as "System Owner",
  tags ->> 'Function' as "Function",
  '' as "End-of-Life"
from
  azure_compute_virtual_machine cvm
  left join all_ips ON all_ips.vm_id = cvm.vm_id
where
  power_state = 'running'


	


  EOQ
}

}

