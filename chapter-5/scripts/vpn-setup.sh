#!/bin/bash
#
# vpn-setup.sh 
# Performs setup of "VPN Site-To-Site" components in OCI. 
#
# Site.........: https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-3_mais-sobre-redes-vpn.md
# Author.......: Daniel Armbrust (darmbrust@gmail.com) 
# License .....: AGPL-3.0 
#
#

# Network Compartment
NET_CMP_OCID=''

# CPE Public IP
CPE_PUBLIC_IP=''

# CPE Local Identifier
CPE_LOCAL_ID=''

function show_help {
    
    cat <<EOH
Usage: $(basename "$0") [OPTIONS]

This is a sample script from OCI-BOOK to illustrate the commands to create a "VPN Site-To-Site".

Part of the chapter 5.2:
https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-3_mais-sobre-redes-vpn.md

Options:
   -h, --help             Show this help and exit.   
         
   -lc, --list-cpe        List CPE devices supported on OCI.
   -is, --ipsec-status    Get IPSec Tunnel Status.  

   -vc, --vpn-create      Create the VPN and all the related network resources.
   -vd, --vpn-delete      Delete the VPN and all the related network resources.

   -c, --cmp-ocid         The OCID of the compartment to use.

   -cip, --cpe-ip         The CPE Public IP Address.
   -cid, --cpe-id         CPE Local Identifier.
    
Example:

    Create the VPN Site-To-Site:
       $(basename "$0") -vs -c ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq -cpi 201.33.196.77 -cid 10.34.0.82
    
    Delete the VPN and related resources:
       $(basename "$0") -vd -c ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq

EOH
}

function gen_shared_secret() {
    #
    # Return a random SHARED SECRET string.
    #
    local max_length=62

    local shared_secret=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-$max_length} | head -n 1)

    echo -n "$shared_secret"
}

function open_security_list() {
   #
   # Open the INGRESS and EGRESS rules from a Security List
   # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/security-list.html
   #
   local vcn_ocid="$1" 

   local seclist_ocid="$(oci network vcn get \
        --vcn-id "$vcn_ocid" | grep "default-security-list-id" | awk '{print $2}' | tr -d '",')"
   
   echo "Adjusting the default Security List ..."

   oci network security-list update \
       --security-list-id "$seclist_ocid" \
       --egress-security-rules '[{"destination": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
       --ingress-security-rules '[{"source": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
       --force \
       --wait-for-state "AVAILABLE"
}

function vcn() {
    #
    # Create, Delete or Get OCID of a Virtual Cloud Network (VCN)
    # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/vcn.html 
    #
    local cmd="$1"

    local vcn_display_name="$2"
    local vcn_dns_label="$3"
    local vcn_cidr="$4"

    local vcn_ocid=''

    if [ "$cmd" == 'create' ]; then

       echo "+++ Creating VCN \"$vcn_display_name ($vcn_cidr)\" ..." 

       oci network vcn create --compartment-id "$NET_CMP_OCID" \
           --cidr-blocks '["'$vcn_cidr'"]' \
           --display-name "$vcn_display_name" \
           --dns-label "$vcn_dns_label" \
           --is-ipv6-enabled false \
           --wait-for-state "AVAILABLE"

    elif [ "$cmd" == 'get_ocid' ]; then

       vcn_ocid=$(oci network vcn list --compartment-id "$NET_CMP_OCID" \
           --all \
           --display-name "$vcn_display_name" \
           --query "data[0].id" \
           --raw-output)

       echo -n "$vcn_ocid"  

    elif [ "$cmd" == 'delete' ]; then

       echo "--- Deleting VCN \"$vcn_display_name\" ..."
        
       local another_vcn_ocid="$(vcn 'get_ocid' "$vcn_display_name")"

       oci network vcn delete --force \
           --vcn-id "$another_vcn_ocid" \
           --wait-for-state "TERMINATED"

    fi
}

function subnet() {
    #
    # Create, Delete or Get OCID of a Subnet.
    # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/subnet.html
    #
    local cmd="$1"

    local subnet_display_name="$2"
    local subnet_dns_label="$3"
    local subnet_cidr="$4"
    local vcn_ocid="$5"

    local subnet_ocid=''

    if [ "$cmd" == 'create' ]; then
      
       echo "+++ Creating SUBNET \"$subnet_display_name ($subnet_cidr)\" ..."

       oci network subnet create \
           --compartment-id "$NET_CMP_OCID" \
           --cidr-block "$subnet_cidr" \
           --vcn-id "$vcn_ocid" \
           --display-name "$subnet_display_name" \
           --dns-label "$subnet_dns_label" \
           --prohibit-public-ip-on-vnic true \
           --wait-for-state "AVAILABLE"   
    
    elif [ "$cmd" == 'get_ocid' ]; then
        
       subnet_ocid=$(oci network subnet list --compartment-id "$NET_CMP_OCID" \
           --all \
           --query "data[?\"display-name\"=='${subnet_display_name}'] | [0].id" --raw-output)
           
       echo -n "$subnet_ocid"  

    elif [ "$cmd" == 'delete' ]; then

        echo "--- Deleting SUBNET \"$subnet_display_name\" ..."
        
        local another_subnet_ocid="$(subnet 'get_ocid' "$subnet_display_name")"

        oci network subnet delete --force \
           --subnet-id "$another_subnet_ocid" \
           --wait-for-state "TERMINATED"
    fi
}

function drg() {
    #
    # Create, Attach, Delete or Get OCID of a DRG.   
    # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/drg.html
    #
    local cmd="$1"

    local drg_display_name="$2"
    local vcn_display_name="$3"
    local attach_display_name="$4"
    
    local drg_ocid=''
    local vcn_ocid=''
    local attch_ocid=''

    if [ "$cmd" == 'create' ]; then
      
       echo "+++ Creating DRG \"$drg_display_name\" ..."
  
       oci network drg create \
           --compartment-id "$NET_CMP_OCID" \
           --display-name "$drg_display_name" \
           --wait-for-state "AVAILABLE"
    
    elif [ "$cmd" == 'get_ocid' ]; then

       drg_ocid="$(oci network drg list --compartment-id "$NET_CMP_OCID" \
           --all \
           --query "data[?\"display-name\"=='${drg_display_name}'] | [0].id" --raw-output)"

       echo -n "$drg_ocid"

    elif [ "$cmd" == 'attch' ]; then

       echo "+++ Attaching the VCN ($vcn_display_name) to DRG ($drg_display_name) ..."
       
       vcn_ocid="$(vcn 'get_ocid' "$vcn_display_name")"
       drg_ocid="$(drg 'get_ocid' "$drg_display_name")"

       oci network drg-attachment create \
           --drg-id "$drg_ocid" \
           --vcn-id "$vcn_ocid" \
           --display-name "$attach_display_name" \
           --wait-for-state "ATTACHED"  
   
    elif [ "$cmd" == 'attch_delete' ]; then
    
       echo "--- Deleting DRG attachment \"drg_display_name\" ..."
       
       attch_ocid="$(oci network drg-attachment list --compartment-id "$NET_CMP_OCID" \
           --all \
           --query "data[?\"display-name\"=='${drg_display_name}'] | [0].id" --raw-output)"

       oci network drg-attachment delete --force \
           --drg-attachment-id "$attch_ocid" \
           --wait-for-state "DETACHED"

    elif [ "$cmd" == 'delete' ]; then
 
        local another_drg_ocid="$(drg 'get_ocid' "$drg_display_name")"

        echo "--- Deleting DRG \"$drg_display_name\" ..."

        oci network drg delete --force \
           --drg-id "$another_drg_ocid" \
           --wait-for-state "TERMINATED"
    fi
}

function cpe() {
    #
    # Create, List Vendors, Delete or Get OCID of a CPE.  
    # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/cpe.html
    #
    local cmd="$1"

    local cpe_display_name="$2"
    local cpe_public_ip="$3"

    local cpe_vendor='Libreswan'
    local cpe_ocid=''

    if [ "$cmd" == 'create' ]; then

       local cpe_vendor_id=$(oci network cpe-device-shape list \
           --all \
           --query "data[?\"cpe-device-info\".vendor=='${cpe_vendor}'] | [0].id" --raw-output)

       echo "+++ Creating CPE with public ip \"$cpe_public_ip\" and vendor \"$cpe_vendor\" ..." 

       oci network cpe create \
           --compartment-id "$NET_CMP_OCID" \
           --ip-address "$cpe_public_ip" \
           --cpe-device-shape-id "$cpe_vendor_id" \
           --display-name "$cpe_display_name"

    elif [ "$cmd" == 'get_ocid' ]; then

       cpe_ocid=$(oci network cpe list --compartment-id "$NET_CMP_OCID" \
           --all \
           --query "data[?\"display-name\"=='${cpe_display_name}'] | [0].id" --raw-output)

       echo -n "$cpe_ocid"

    elif [ "$cmd" == 'list' ]; then
     
       echo '+++ Listing the CPE device types supported on OCI ...'

       oci network cpe-device-shape list \
           --all \
           --query "data[].{vendor: \"cpe-device-info\".vendor, version: \"cpe-device-info\".\"platform-software-version\"}" \
           --output table       
    
    elif [ "$cmd" == 'delete' ]; then

       local another_cpe_ocid="$(cpe 'get_ocid' "$cpe_display_name")"

       echo "--- Deleting CPE \"$cpe_display_name\" ..."

       oci network cpe delete --force \
           --cpe-id "$another_cpe_ocid" \
           
    fi
}

function ipsec() {
    #
    # Create, Get Tunnel Status, Delete or Get OCID of a IPSec connection.  
    # https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/network/ip-sec-connection.html
    #
    local cmd="$1"

    local ipsec_display_name="$2"
    local tunnel_prefix_display_name="$3"
    local static_route_list="$4"
    local cpe_identifier_type="$5"
    local cpe_identifier="$6"
    local drg_ocid="$7"
    local cpe_ocid="$8"    

    local shared_secret=''

    local tunnel_1_display_name="$(echo -n "$tunnel_prefix_display_name" ; echo -n '-1_' ; echo -n "$ipsec_display_name")"
    local tunnel_2_display_name="$(echo -n "$tunnel_prefix_display_name" ; echo -n '-2_' ; echo -n "$ipsec_display_name")"
   
    local ipsec_ocid=''

    if [ "$cmd" == 'create' ]; then

       shared_secret="$(gen_shared_secret)"
       
       echo "+++ Creating IPSec Connection ..."
       echo "++++ Shared Secret: $shared_secret"

       oci network ip-sec-connection create \
           --compartment-id "$NET_CMP_OCID" \
           --cpe-id "$cpe_ocid" \
           --drg-id "$drg_ocid" \
           --display-name "$ipsec_display_name" \
           --static-routes '["'$static_route_list'"]' \
           --cpe-local-identifier-type "$cpe_identifier_type" \
           --cpe-local-identifier "$cpe_identifier" \
           --tunnel-configuration "[{\"displayName\": \"${tunnel_1_display_name}\", \"routing\": \"STATIC\", \"sharedSecret\": \"${shared_secret}\"},
                {\"displayName\": \"${tunnel_2_display_name}\", \"routing\": \"STATIC\", \"sharedSecret\": \"${shared_secret}\"}]" \
           --wait-for-state "AVAILABLE"  

    elif [ "$cmd" == 'get_ocid' ]; then
        
       ipsec_ocid="$(oci network ip-sec-connection list \
           --compartment-id "$NET_CMP_OCID" \
           --all \
           --query "data[?\"display-name\"=='${ipsec_display_name}'] | [0].id" --raw-output 2>/dev/null)"
       
       echo -n "$ipsec_ocid"        

    elif [ "$cmd" == 'get_tunnel_status' ]; then
        
       local another_ipsec_ocid="$(ipsec 'get_ocid' "$ipsec_display_name")" 

       if [ -z "$another_ipsec_ocid" ]; then
          echo "!!! No IPSec connection available."
       else       
          echo "+++ Getting IPSec Connection Status ($ipsec_display_name) ..."

          oci network ip-sec-connection get-status --ipsc-id "$another_ipsec_ocid"
       fi

    elif [ "$cmd" == 'delete' ]; then
        
        local another_ipsec_ocid="$(ipsec 'get_ocid' "$ipsec_display_name")"
 
        echo "--- Deleting IPSec \"$ipsec_display_name\" ..."

        oci network ip-sec-connection delete --force \
           --ipsc-id "$another_ipsec_ocid" \
           --wait-for-state "TERMINATED"
    fi
}

function vpn() {
    #
    # VPN Main Function.
    #
    local cmd="$1"

    if [ "$cmd" == 'create' ]; then

       vcn 'create' 'vcn-hub' 'vcnhub' '192.168.20.0/26'

       local vcn_ocid="$(vcn 'get_ocid' 'vcn-hub')"

       subnet 'create' 'subprv_vcn-hub' 'subprvvcnhub' '192.168.20.0/28' "$vcn_ocid"
       open_security_list "$vcn_ocid"

       drg 'create' 'drg-saopaulo'
       drg 'attch' 'drg-saopaulo' 'vcn-hub' 'vcn-hub_attch_drg-saopaulo'

       local drg_ocid="$(drg 'get_ocid' 'drg-saopaulo')"

       cpe 'create' 'cpe-1' "$CPE_PUBLIC_IP" 

       local cpe_ocid="$(cpe 'get_ocid' 'cpe-1')"

       ipsec 'create' 'vpn-1' 'tunnel' '10.34.0.0/24' 'IP_ADDRESS' "$CPE_LOCAL_ID" "$drg_ocid" "$cpe_ocid"

    elif [ "$cmd" == 'delete' ]; then
       
       local drg_attch_ocid="$(drg 'get_attch_ocid' 'vcn-hub_attch_drg-saopaulo')"

       ipsec 'delete' 'vpn-1'      

       drg 'attch_delete' 'vcn-hub_attch_drg-saopaulo'
       drg 'delete' 'drg-saopaulo'       

       subnet 'delete' 'subprv_vcn-hub'
       vcn 'delete' 'vcn-hub'

       cpe 'delete' 'cpe-1'

    fi
}

vpn_create=0
vpn_delete=0

while test -n "$1" ; do
  case "$1" in 
     '-h'|'--help')
              show_help
              exit 0
              ;;

     '-lc'|'--list-cpe')
              cpe 'list' 
              exit 0
              ;;

    '-is'|'--ipsec-status')
              ipsec 'get_tunnel_status' 'vpn-1'
              exit 0
              ;;

    '-c'|'--cmp-ocid')
              shift
              NET_CMP_OCID="$1"
              ;;

    '-cip'|'--cpe-ip')
              shift
              CPE_PUBLIC_IP="$1"              
              ;;

    '-cid'|'--cpe-id')
              shift
              CPE_LOCAL_ID="$1" 
              ;;

    '-vc'|'--vpn-create')
              vpn_create=1
              ;;

     '-vd'|'--vpn-delete')
              vpn_delete=1
              ;;

              *)
              show_help
              exit 1
              ;;
  esac

  shift 
done

if [ $vpn_create == 1 ] && [ $vpn_delete == 1 ]; then
   show_help
   exit 1
elif [ "$vpn_create" == 1 ]; then

   if [ -z "$NET_CMP_OCID" ] || [ -z "$CPE_PUBLIC_IP" ] || [ -z "$CPE_LOCAL_ID" ]; then
      echo "[Error] Need a compartment OCID and CPE Public IP to continue!"
      exit 1
   else
      vpn 'create'
   fi

elif [ "$vpn_delete" == 1 ]; then

   if [ -z "$NET_CMP_OCID" ]; then
      echo "[Error] Need a compartment OCID to continue!"
      exit 1
   else
      vpn 'delete'
   fi 

else
   show_help
   exit 1
fi

exit 0