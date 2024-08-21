#!/bin/bash

### --- Variables --- ###
# IBM Cloud Defines
IBM_CLOUD_API_KEY="8Syv9TcSjRkSXUnEnBq8M0rxJ1Izmct9B3syCV_PlF9S"
REGION="ca-tor"

# Create PowerVS workspace defines
VPC_NAME="my-vpc"
RESOURCE_GROUP="testingTX"
SUBNET_NAME="demo-subnet"
DEFAULT_NETWORK_ACL="demo-acl"
DEFAULT_ROUTING_TABLE="demo-routing-table"
DEFAULT_SECURITY_GROUP="demo-security-group"
PUBLIC_GATEWAY="demo-public-gateway"
TRANSIT_GATEWAY="demo-transit-gateway"

# ***************** for VSI configuration
VSI_NAME="my-vsi"
PROFILE="bx2-2x8"
IMAGE="r038-71990366-f9e3-4d69-bfff-0084d79eb201"

# ***************** don't change
VPC_ID=""
ZONE1=""
ZONE2=""
ZONE3=""
DEFAULT_NETWORK_ACL_ID=""
DEFAULT_ROUTING_TABLE_ID=""
DEFAULT_SECURITY_GROUP_ID=""
TMP_VPC_CONFIG=tmp-vpc-configuration.json
TMP_SUBNETS=tmp-subnets.json
TMP_ZONE=tmp-zone.json
TMP_DEFAULT_NETWORK_ACL=""
TMP_DEFAULT_ROUTING_TABLE=""
TMP_DEFAULT_SECURITY_GROUP=""



# # Login to IBM Cloud
# LOGIN_CMD="ibmcloud login --apikey $IBM_CLOUD_API_KEY -r $REGION"
# eval $LOGIN_CMD

# # Create VPC
# echo "Create a Virtual Private Cloud: $VPC_NAME"
# VPC_CREATE_CMD="ibmcloud is vpc-create $VPC_NAME --resource-group-name $RESOURCE_GROUP"
# eval $VPC_CREATE_CMD

# #end program
# exit 0




### --- Functions --- ###
# Function to create VPC
function createVPC() {
    echo "Logging in to IBM Cloud"
    LOGIN_CMD="ibmcloud login --apikey $IBM_CLOUD_API_KEY -r $REGION"

    echo "Create a Virtual Private Cloud: $VPC_NAME"
    ibmcloud is vpc-create $VPC_NAME --resource-group-name $RESOURCE_GROUP
    ibmcloud is vpc $VPC_NAME --output JSON > $TMP_VPC_CONFIG
     
    VPC_ID=$(cat ./$TMP_VPC_CONFIG | jq '.id' | sed 's/"//g')
    echo "Extract Virtual Private Cloud ID : $VPC_ID" 

    echo "Extract default names"

    TMP_DEFAULT_NETWORK_ACL=$(cat ./$TMP_VPC_CONFIG | jq '.default_network_acl.name' | sed 's/"//g')
    DEFAULT_NETWORK_ACL_ID=$(cat ./$TMP_VPC_CONFIG | jq '.default_network_acl.id' | sed 's/"//g')
    echo "- Access control list: "$TMP_DEFAULT_NETWORK_ACL
    
    TMP_DEFAULT_ROUTING_TABLE=$(cat ./$TMP_VPC_CONFIG | jq '.default_routing_table.name' | sed 's/"//g')
    DEFAULT_ROUTING_TABLE_ID=$(cat ./$TMP_VPC_CONFIG | jq '.default_routing_table.id' | sed 's/"//g')
    echo "- Routing table: " $TMP_DEFAULT_ROUTING_TABLE
    
    TMP_DEFAULT_SECURITY_GROUP=$(cat ./$TMP_VPC_CONFIG | jq '.default_security_group.name' | sed 's/"//g')
    DEFAULT_SECURITY_GROUP_ID=$(cat ./$TMP_VPC_CONFIG | jq '.default_security_group.id' | sed 's/"//g')
    echo "- Security group: " $TMP_DEFAULT_SECURITY_GROUP

    ZONE1="$(cat ./$TMP_VPC_CONFIG | jq '.cse_source_ips[].zone.name' | sed 's/"//g' | awk '/1/ {print $0}')"
    ZONE2="$(cat ./$TMP_VPC_CONFIG | jq '.cse_source_ips[].zone.name' | sed 's/"//g' | awk '/2/ {print $1}'))"
    ZONE3="$(cat ./$TMP_VPC_CONFIG | jq '.cse_source_ips[].zone.name' | sed 's/"//g' | awk '/3/{print $2}'))"
    
    echo "- Zones: $ZONE1 ; $ZONE2 ; $ZONE3"

    rm -f $TMP_VPC_CONFIG
}

# Function to rename the default names
function renameDefaultNames () {
  echo "Rename default names"
  ibmcloud is vpc-routing-table-update $VPC_ID $DEFAULT_ROUTING_TABLE_ID --name $DEFAULT_ROUTING_TABLE
  ibmcloud is network-acl-update  $DEFAULT_NETWORK_ACL_ID --vpc $VPC_ID --name $DEFAULT_NETWORK_ACL
  ibmcloud is security-group-update $DEFAULT_SECURITY_GROUP_ID --vpc $VPC_ID --name $DEFAULT_SECURITY_GROUP
}

# Function to create a subnet 
function createSubnet () { 
  echo "Create Subnet: Bind VPC $VPC_ID and zone $ZONES[0]"
  ibmcloud is subnet-create "$SUBNET_NAME" "$VPC_ID" --ipv4-address-count 256 --zone "$ZONE1" --resource-group-name "$RESOURCE_GROUP"
  ibmcloud is subnet $SUBNET_NAME --vpc $VPC_ID
}

# Function to create a VSI instance in the VPC
function createVSI () {
  echo "Create VSI: Bind VPC $VPC_ID and zone $ZONES[0]"
  eval "ibmcloud is instance-create $VSI_NAME $VPC_ID $ZONE1 $PROFILE $SUBNET_NAME --image $IMAGE --resource-group-name $RESOURCE_GROUP"
}

# Function to create a transit gateway
function createTransitGateway () {
  echo "Create Transit Gateway: $TRANSIT_GATEWAY"
  ibmcloud tg gateway-create --name $TRANSIT_GATEWAY --location $REGION
}

# Combine all these functions and run
createVPC
renameDefaultNames
createSubnet
createVSI
createTransitGateway