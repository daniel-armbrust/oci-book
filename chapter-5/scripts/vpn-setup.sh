#!/bin/bash
#
# vpn-setup.sh 
# Performs setup of "VPN Site-To-Site" components in OCI. 
#
# Site.........: https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-2_mais-sobre-redes-vpn.md
# Author.......: Daniel Armbrust (darmbrust@gmail.com) 
# License .....: AGPL-3.0 
#
#

# Network Compartment
NET_CMP_OCID='ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq'

# CPE Public IP
CPE_PUBLIC_IP='201.33.196.77'
CPE_VENDOR='Libreswan'

function show_help {
    echo "help"
}

function cpe_list {
    #
    # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/cpe-device-shape/list.html
    #

    echo 'Listing the CPE device types supported on OCI ...'

    oci network cpe-device-shape list \
        --all \
        --query "data[].{vendor: \"cpe-device-info\".vendor, version: \"cpe-device-info\".\"platform-software-version\"}" \
        --output table       
}

function get_tunnel_status {
    #
    # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/ip-sec-connection/get-status.html
    #
}

function gen_shared_secret {
    #
    # Return a random SHARED SECRET string.
    #
    local max_length=62

    local shared_secret=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-$max_length} | head -n 1)

    echo -n "$shared_secret"
}

function create_vcn_hub {
   #
   # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/vcn.html 
   #
   local vcn_display_name='vcn-hub'
   local vcn_dns_label='vcnhub'
   local vcn_cidr='192.168.20.0/26'

   echo -e "Creating VCN \"$vcn_display_name ($vcn_cidr)\" ...\n"

   oci network vcn create \
       --compartment-id "$NET_CMP_OCID" \
       --cidr-blocks "[\"$vcn_cidr\"]" 
       --display-name "$vcn_display_name" \
       --dns-label "$vcn_dns_label" \
       --is-ipv6-enabled false \
       --wait-for-state "AVAILABLE"

   local vcn_ocid=$(oci network vcn list \
       --compartment-id "$NET_CMP_OCID" \
       --all \
       --display-name "$vcn_display_name" \
       --query "data[0].id" --raw-output)

   echo -e "\n"

   echo -n "$vcn_ocid"  
}

function create_subnet {
   #
   # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/subnet.html
   #
   local vcn_ocid="$1"

   local subnet_display_name='subprv_vcn-hub'
   local subnet_dns_label='subprvvcnhub'
   local subnet_cidr='192.168.20.0/28'
   
   echo -e "Creating SUBNET \"$subnet_display_name ($subnet_cidr)\" ...\n"

   oci network subnet create \
       --compartment-id "$NET_CMP_OCID" \
       --cidr-block "$subnet_cidr" \
       --vcn-id "$vcn_ocid" \
       --display-name "$subnet_display_name" \       
       --dns-label "$subnet_dns_label" \
       --prohibit-public-ip-on-vnic true
       --wait-for-state "AVAILABLE"
    
   echo -e "\n"
}

function adjust_security_list {
   #
   # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/security-list.html
   #
   local vcn_ocid="$1" 

   local seclist_ocid=$(oci network vcn get \
        --vcn-id "$vcn_ocid" | grep "default-security-list-id" | awk '{print $2}' | tr -d '",')
   
   echo -e "Adjusting the default Security List ...\n"

   oci network security-list update \
       --security-list-id "$seclist_ocid" \
       --egress-security-rules '[{"destination": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
       --ingress-security-rules '[{"source": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
       --force \
       --wait-for-state "AVAILABLE"

   echo -e "\n"     
}

function create_drg {
    #
    # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/drg.html
    # 
    local drg_display_name='drg-saopaulo'

    echo -e "Creating DRG \"$drg_display_name\" ...\n"
    
    oci network drg create \
        --compartment-id "$NET_CMP_OCID" \
        --display-name "drg-saopaulo" \
        --wait-for-state "AVAILABLE"
    
    drg_ocid=$(oci network drg list --compartment-id "$NET_CMP_OCID" \
        --all \
        --query "data[?\"display-name\"=='drg-saopaulo'] | [0].id" \
        --raw-output)     

    echo -n "$drg_ocid"
}

function drg_attach_vcn {
    #
    # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/drg-attachment.html
    #
    local vcn_ocid="$1"
    local drg_ocid="$2"

    local attach_display_name='vcn-hub_attch_drg-saopaulo'

    echo -e "Attaching the VCN to DRG ...\n"
    
    oci network drg-attachment create \
        --drg-id "$drg_ocid" \
        --vcn-id "$vcn_ocid" \
        --display-name "$attach_display_name" \
        --wait-for-state "ATTACHED"
    
    echo -e "\n"    
}

function create_cpe {
    #
    # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/cpe.html
    #
    local cpe_display_name='cpe-1'
    
    local cpe_vendor_id=$(oci network cpe-device-shape list \
        --all \
        --query "data[?\"cpe-device-info\".vendor=='$CPE_VENDOR'] | [0].id" \
        --raw-output)
    
    echo -e "Creating CPE with public ip \"$CPE_PUBLIC_IP\" and vendor \"$CPE_VENDOR\" ...\n"

    oci network cpe create \
        --compartment-id "$NET_CMP_OCID" \
        --ip-address "$CPE_PUBLIC_IP" \
        --cpe-device-shape-id "$cpe_vendor_id" \
        --display-name "$cpe_display_name"
    
    local cpe_ocid=$(oci network cpe list --compartment-id "$NET_CMP_OCID" \
        --all \
        --query "data[?\"display-name\"=='$cpe_display_name'] | [0].id" \
        --raw-output)

    echo -e "\n"

    echo -n "$cpe_ocid"
}

function create_ipsec {
    #
    # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/ip-sec-connection.html
    #
    local cpe_ocid="$1"
    local drg_ocid="$2"

    local ipsec_display_name='vpn-1'
    local static_route_list='"10.34.0.0/24"'
    local cpe_identifier_type='IP_ADDRESS'
    local cpe_identifier='10.34.0.82'

    local tunnel_1_display_name='tunnel-1_vpn-1'
    local tunnel_2_display_name='tunnel-2_vpn-1'

    local shared_secret="$(gen_shared_secret)"

    echo -e "Creating IPSec Connection ...\n"

    oci network ip-sec-connection create \
        --compartment-id "$NET_CMP_OCID" \
        --cpe-id "$cpe_ocid" \
        --drg-id "$drg_ocid" \
        --display-name "$ipsec_display_name" \
        --static-routes "[$static_route_list]" \
        --cpe-local-identifier-type "$cpe_identifier_type" \
        --cpe-local-identifier "$cpe_identifier" \
        --tunnel-configuration "[{\"displayName\": \"$tunnel_1_display_name\", \"routing\": \"STATIC\", \"sharedSecret\": \"$shared_secret\"},
             {\"displayName\": \"$tunnel_2_display_name\", \"routing\": \"STATIC\", \"sharedSecret\": \"$shared_secret\"}]" \
        --wait-for-state "AVAILABLE"
    
    echo -e "\n"
}

function vpn_setup {
    
    # Create VCN-HUB
    local vcn_ocid=$(create_vcn_hub)

    # Create SUBNET and adjust INGRESS/EGRESS from the default SECURITY LIST
    create_subnet "$vcn_ocid"
    adjust_security_list "$vcn_ocid"

    # Create DRG
    local drg_ocid=$(create_drg)
    
    # Attach VCN to DRG
    drg_attach_vcn "$vcn_ocid" "$drg_ocid"

    # Create CPE
    local cpe_ocid=$(create_cpe)
}

case "$1" in
  '-h')
        show_help
        ;;
  '-cl')
        cpe_list 
        ;;
   '-d')
        destroy
        ;; 
     *)
        show_help
        exit 1
        ;;
esac

exit 0