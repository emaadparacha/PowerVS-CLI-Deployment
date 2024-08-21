#!/bin/bash

### --- Variables --- ###
# IBM Cloud Defines
IBM_CLOUD_API_KEY="ENTER_API_KEY"
REGION="ca-tor OR ENTER REGION"

# Create PowerVS workspace defines
WORKSPACE_NAME="ENTER_POWERVS_WORKSPACE_NAME"
DATACENTER="tor01 OR ENTER DATACENTER"
RESOURCE_GROUP="ENTER_RESOURCE_GROUP_NAME"
PLAN="public"

### --- Commands --- ###
# Login to IBM Cloud
LOGIN_CMD="ibmcloud login --apikey $IBM_CLOUD_API_KEY -r $REGION"
CREATE_RG_GROUP="ibmcloud resource group-create $RESOURCE_GROUP"
GET_RG_GROUP_ID="ibmcloud resource group $RESOURCE_GROUP --id"
CREATE_PVS_WS="ibmcloud pi workspace create $WORKSPACE_NAME --datacenter $DATACENTER --plan $PLAN --group"


### --- Run --- ###

# Function to display the menu
show_menu() {
    echo "Choose an option:"
    echo "1) Create a Power VS Workspace"
    echo "2) Delete a Power VS Workspace"
    echo "3) Exit"
    echo -n "Enter your choice: "
}

# Function to handle the user input
read_choice() {
    local choice
    read choice
    case $choice in
        1)
            echo "You chose Option 1"
            # Write a script that will login, create a resource group, get the resource group ID, and create a workspace

            # Login, then create a resource group and then get the resource group ID, save it to a variable
            eval "$LOGIN_CMD && $CREATE_RG_GROUP"

            # Get the resource group ID
            RG_GROUP_ID=$(eval "$GET_RG_GROUP_ID")

            # Create a PowerVS workspace
            eval "$CREATE_PVS_WS $RG_GROUP_ID"
            ;;
        2)

            # Login, then get the workspace ID, and delete the workspace
            eval "$LOGIN_CMD"

            # Output list of workspaces
            eval "ibmcloud pi workspace list"

            # Get user to input the ID of the workspace to delete and save to variable
            echo "Enter the ID of the workspace you want to delete: "
            read ID

            # Delete the workspace
            echo "Are you sure you want to delete the workspace with the ID '$ID'? (y/n)"
            read confirm
            if [[ "$confirm" == "y" ]]; then
                eval "ibmcloud pi workspace delete $ID"
            else
                echo "Exiting..."
                exit 0
            fi
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
}

show_menu
read_choice
    
