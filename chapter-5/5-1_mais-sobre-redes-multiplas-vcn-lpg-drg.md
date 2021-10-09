# Capítulo 5: Mais sobre Redes no OCI

## 5.1 - Conectando múltiplas VCNs na mesma região

### __Local Peering Gateway (LPG)__

_[Local Peering Gateway (LPG)](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ é um recurso que permite conectar duas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ na mesma região possiblitando comunicação via endereços IP privados e sem rotear o tráfego pela internet. As _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ podem estar no mesmo _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_ ou em _[tenancies](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_ distintos. 

Lembrando que se não houver pareamento via _[LGP](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ entre duas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_, é necessário a utilização de um _[Internet Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingIGs.htm#Internet_Gateway)_ e endereços IP públicos para que os recursos se comuniquem. Porém, isto acaba expondo a comunicação deles de forma indevia pela internet.

Demonstraremos a criação do _[Local Peering Gateway (LPG)](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ conforme o desenho abaixo:

![alt_text](./images/ch5-1_lpg-1.jpg "Local Peering Gateway (LGP)")

Duas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ que se comunicam necessitam ter blocos _[CIDRs](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)_ diferentes (sem sobreposição).


#### VCN de Produção (vcn-prd) 

Começaremos pela criação da _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ de produção:

```
darmbrust@hoodwink:~$ oci network vcn create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --cidr-blocks '["192.168.0.0/16"]' \
> --display-name "vcn-prd" \
> --dns-label "vcnprd" \
> --is-ipv6-enabled false \
> --wait-for-state "AVAILABLE"
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "cidr-block": "192.168.0.0/16",
    "cidr-blocks": [
      "192.168.0.0/16"
    ],
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "default-dhcp-options-id": "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaaiy5nysqze6m47rsj3guzmpkksjnlzp6oudk6rgc2b4du2wgetnra",
    "default-route-table-id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaae2rhesecc4amfji763v3m324abufiml5asyxd64xfn57e7veipaq",
    "default-security-list-id": "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaass5hvduram6ehbzrzo6fyhflw7zewdsji45w5t3aq2m3agvsqnkq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-05T17:21:31.182Z"
      }
    },
    "display-name": "vcn-prd",
    "dns-label": "vcnprd",
    "freeform-tags": {},
    "id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qaasugozouqxfpwajtaj3oymelmqwv2i2chmuil5ttesma",
    "ipv6-cidr-blocks": null,
    "lifecycle-state": "AVAILABLE",
    "time-created": "2021-10-05T17:21:31.275000+00:00",
    "vcn-domain-name": "vcnprd.oraclevcn.com"
  },
  "etag": "589e1d66"
}
```

Para a subrede privada de produção, usaremos os recursos _[dhcp options](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDHCP.htm)_, _[tabela de roteamento](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingroutetables.htm)_ e _[security lists](https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/datatypes/IngressSecurityRule)_ que foram criados por padrão no momento em que a _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ foi criada.

```
darmbrust@hoodwink:~$ oci network subnet create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qaasugozouqxfpwajtaj3oymelmqwv2i2chmuil5ttesma" \
> --dhcp-options-id "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaaiy5nysqze6m47rsj3guzmpkksjnlzp6oudk6rgc2b4du2wgetnra" \
> --route-table-id "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaae2rhesecc4amfji763v3m324abufiml5asyxd64xfn57e7veipaq" \
> --security-list-ids '["ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaass5hvduram6ehbzrzo6fyhflw7zewdsji45w5t3aq2m3agvsqnkq"]' \
> --display-name "subnprv_vcn-prd" \
> --dns-label "subnprv" \
> --cidr-block "192.168.20.0/24" \
> --prohibit-public-ip-on-vnic true \
> --wait-for-state "AVAILABLE"
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "availability-domain": null,
    "cidr-block": "192.168.20.0/24",
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-05T17:49:24.203Z"
      }
    },
    "dhcp-options-id": "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaaiy5nysqze6m47rsj3guzmpkksjnlzp6oudk6rgc2b4du2wgetnra",
    "display-name": "subnprv_vcn-prd",
    "dns-label": "subnprv",
    "freeform-tags": {},
    "id": "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaary7wcifmwmmmavtfbjp45fxivvvisigjw76fr6pmyopulcbmjugq",
    "ipv6-cidr-block": null,
    "ipv6-virtual-router-ip": null,
    "lifecycle-state": "AVAILABLE",
    "prohibit-internet-ingress": true,
    "prohibit-public-ip-on-vnic": true,
    "route-table-id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaae2rhesecc4amfji763v3m324abufiml5asyxd64xfn57e7veipaq",
    "security-list-ids": [
      "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaass5hvduram6ehbzrzo6fyhflw7zewdsji45w5t3aq2m3agvsqnkq"
    ],
    "subnet-domain-name": "subnprv.vcnprd.oraclevcn.com",
    "time-created": "2021-10-05T17:49:24.257000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qaasugozouqxfpwajtaj3oymelmqwv2i2chmuil5ttesma",
    "virtual-router-ip": "192.168.20.1",
    "virtual-router-mac": "00:00:17:92:3D:E4"
  },
  "etag": "7868c9e5"
}
```

#### VCN de Banco de Dados (vcn-db)

O processo de criação da _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ para banco de dados segue o mesmo padrão.

```
darmbrust@hoodwink:~$ oci network vcn create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --cidr-blocks '["172.16.0.0/16"]' \
> --display-name "vcn-db" \
> --dns-label "vcndb" \
> --is-ipv6-enabled false \
> --wait-for-state "AVAILABLE"
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "cidr-block": "172.16.0.0/16",
    "cidr-blocks": [
      "172.16.0.0/16"
    ],
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "default-dhcp-options-id": "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaali3ocb5hxqhpohgv5ml52yiue2ugvwyicprorfoplgbks6uoxuea",
    "default-route-table-id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaamv5sy4life5tbektd6wnkgcqwzqcj5yk2pnkdnavqhacgj5buonq",
    "default-security-list-id": "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaakiuso7lpjmfgbqeopmc75vusixj3cwkrpycc5356d7h36nrdxmcq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-05T17:53:07.934Z"
      }
    },
    "display-name": "vcn-db",
    "dns-label": "vcndb",
    "freeform-tags": {},
    "id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qauzzbffpcd7xtcpxk7i3njt44gmurmaxvizr6mfz6eibq",
    "ipv6-cidr-blocks": null,
    "lifecycle-state": "AVAILABLE",
    "time-created": "2021-10-05T17:53:08.037000+00:00",
    "vcn-domain-name": "vcndb.oraclevcn.com"
  },
  "etag": "30115019"
}
```

Agora a subrede privada:

```
darmbrust@hoodwink:~$ oci network subnet create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qauzzbffpcd7xtcpxk7i3njt44gmurmaxvizr6mfz6eibq" \
> --dhcp-options-id "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaali3ocb5hxqhpohgv5ml52yiue2ugvwyicprorfoplgbks6uoxuea" \
> --route-table-id "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaamv5sy4life5tbektd6wnkgcqwzqcj5yk2pnkdnavqhacgj5buonq" \
> --security-list-ids '["ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaakiuso7lpjmfgbqeopmc75vusixj3cwkrpycc5356d7h36nrdxmcq"]' \
> --display-name "subnprv_vcn-db" \
> --dns-label "subnprv" \
> --cidr-block "172.16.30.0/24" \
> --prohibit-public-ip-on-vnic true \
> --wait-for-state "AVAILABLE"
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "availability-domain": null,
    "cidr-block": "172.16.30.0/24",
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-05T17:57:54.610Z"
      }
    },
    "dhcp-options-id": "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaali3ocb5hxqhpohgv5ml52yiue2ugvwyicprorfoplgbks6uoxuea",
    "display-name": "subnprv_vcn-db",
    "dns-label": "subnprv",
    "freeform-tags": {},
    "id": "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaa5v2vsetv73xem2hlxf25uibpwcvci6nifidj3b6enf52m6bgy7ua",
    "ipv6-cidr-block": null,
    "ipv6-virtual-router-ip": null,
    "lifecycle-state": "AVAILABLE",
    "prohibit-internet-ingress": true,
    "prohibit-public-ip-on-vnic": true,
    "route-table-id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaamv5sy4life5tbektd6wnkgcqwzqcj5yk2pnkdnavqhacgj5buonq",
    "security-list-ids": [
      "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaakiuso7lpjmfgbqeopmc75vusixj3cwkrpycc5356d7h36nrdxmcq"
    ],
    "subnet-domain-name": "subnprv.vcndb.oraclevcn.com",
    "time-created": "2021-10-05T17:57:54.682000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qauzzbffpcd7xtcpxk7i3njt44gmurmaxvizr6mfz6eibq",
    "virtual-router-ip": "172.16.30.1",
    "virtual-router-mac": "00:00:17:24:D6:D8"
  },
  "etag": "114e5e57"
}
```

#### Conexão através do Local Peering Gateway (LPG)

Para que as _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ se comuniquem, é necessário criar um _[LPG](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ do lado de cada _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_:

- **vcn-prd**

```
darmbrust@hoodwink:~$ oci network local-peering-gateway create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qaasugozouqxfpwajtaj3oymelmqwv2i2chmuil5ttesma" \
> --display-name "lpg_vcn-prd" \
> --wait-for-state "AVAILABLE"
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-05T18:17:48.461Z"
      }
    },
    "display-name": "lpg_vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa7yc6nig6frgdcl2rpqsblbmotvbda3onjkmxdsbcra4ztmkbvs2a",
    "is-cross-tenancy-peering": false,
    "lifecycle-state": "AVAILABLE",
    "peer-advertised-cidr": null,
    "peer-advertised-cidr-details": null,
    "peer-id": null,
    "peering-status": "NEW",
    "peering-status-details": "Not connected to a peer.",
    "route-table-id": null,
    "time-created": "2021-10-05T18:17:48.548000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qaasugozouqxfpwajtaj3oymelmqwv2i2chmuil5ttesma"
  },
  "etag": "92011d8"
}
```

- **vcn-db**

```
darmbrust@hoodwink:~$ oci network local-peering-gateway create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qauzzbffpcd7xtcpxk7i3njt44gmurmaxvizr6mfz6eibq" \
> --display-name "lpg_vcn-db" \
> --wait-for-state "AVAILABLE"
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-05T18:21:16.171Z"
      }
    },
    "display-name": "lpg_vcn-db",
    "freeform-tags": {},
    "id": "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa6j6l2svl5eesdetjkggyohypxqtzbqfv5qeqa7p7xkdbhdg7qfsa",
    "is-cross-tenancy-peering": false,
    "lifecycle-state": "AVAILABLE",
    "peer-advertised-cidr": null,
    "peer-advertised-cidr-details": null,
    "peer-id": null,
    "peering-status": "NEW",
    "peering-status-details": "Not connected to a peer.",
    "route-table-id": null,
    "time-created": "2021-10-05T18:21:16.220000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qauzzbffpcd7xtcpxk7i3njt44gmurmaxvizr6mfz6eibq"
  },
  "etag": "85632e9f"
}
```

Após cada _[Local Peering Gateway](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ estar criado, devemos conectá-los. Isto é feito através do _solicitante (--local-peering-gateway-id)_ com um _aceitador (--peer-id)_. 

Em nosso caso quem _solicita a conexão_ é o _[LPG](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ que foi _"plugado"_ na _vcn-prd_, sendo que quem _aceita_ é _[LPG](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ que foi _"plugado"_ na _vcn-db_.

```
darmbrust@hoodwink:~$ oci network local-peering-gateway connect \
> --local-peering-gateway-id "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaajtpagmjpddmhrqfvp6w6jsqvdhx3nmijhmblq3sgbnrkmefuaaza" \
> --peer-id "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa7ntl6vzave2qrlmmpx5ynbmjnnn7xsmh76zzg4ihdwsq5mzqxaoa"
{
  "etag": "48472ecc"
}
```

Para verificar o _status_ desta conectividade, usamos o comando abaixo:

```
darmbrust@hoodwink:~$ oci network local-peering-gateway get \
> --local-peering-gateway-id "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa7yc6nig6frgdcl2rpqsblbmotvbda3onjkmxdsbcra4ztmkbvs2a"
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-05T18:17:48.461Z"
      }
    },
    "display-name": "lpg_vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa7yc6nig6frgdcl2rpqsblbmotvbda3onjkmxdsbcra4ztmkbvs2a",
    "is-cross-tenancy-peering": false,
    "lifecycle-state": "AVAILABLE",
    "peer-advertised-cidr": "172.16.0.0/16",
    "peer-advertised-cidr-details": [
      "172.16.0.0/16"
    ],
    "peer-id": "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa6j6l2svl5eesdetjkggyohypxqtzbqfv5qeqa7p7xkdbhdg7qfsa",
    "peering-status": "PEERED",
    "peering-status-details": "Connected to a peer.",
    "route-table-id": null,
    "time-created": "2021-10-05T18:17:48.548000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qaasugozouqxfpwajtaj3oymelmqwv2i2chmuil5ttesma"
  },
  "etag": "49890a12"
}
```

É possível confirmar a conectividade pela propriedade _"peering-status"_ com o valor _"PEERED"_. Também é possível ver o anúncio do bloco _[CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)_ vindo da _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ de banco de dados (vcn-db) através da propriedade _"peer-advertised-cidr"_ e que contém o valor _"172.16.0.0/16"_.

#### Ajustes no roteamento

Não é novidade que toda _[VNIC](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVNICs.htm)_ reside em uma subrede, e que uma subrede reside dentro de uma _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_. Para existir comunicação entre _[VNICs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVNICs.htm)_ que residem em _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ diferentes, devemos instruir esta ação através da _[tabela de roteamento](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingroutetables.htm)_ de cada subrede. Ou seja, criamos uma regra de roteamento que utiliza o gateway mais próximo da rede de destino que queremos alcançar.

Para o nosso exemplo, começarei ajustando a _[tabela de roteamento](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingroutetables.htm)_ da subrede _"subnprv_vcn-prd"_:

```
darmbrust@hoodwink:~$ oci network route-table update \
> --rt-id "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaae2rhesecc4amfji763v3m324abufiml5asyxd64xfn57e7veipaq" \
> --route-rules '[{"cidrBlock": "172.16.30.0/24", "networkEntityId": "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa7yc6nig6frgdcl2rpqsblbmotvbda3onjkmxdsbcra4ztmkbvs2a"}]' \
> --force \
> --wait-for-state "AVAILABLE"
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-05T17:21:31.182Z"
      }
    },
    "display-name": "Default Route Table for vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaae2rhesecc4amfji763v3m324abufiml5asyxd64xfn57e7veipaq",
    "lifecycle-state": "AVAILABLE",
    "route-rules": [
      {
        "cidr-block": "172.16.30.0/24",
        "description": null,
        "destination": "172.16.30.0/24",
        "destination-type": "CIDR_BLOCK",
        "network-entity-id": "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa7yc6nig6frgdcl2rpqsblbmotvbda3onjkmxdsbcra4ztmkbvs2a"
      }
    ],
    "time-created": "2021-10-05T17:21:31.275000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qaasugozouqxfpwajtaj3oymelmqwv2i2chmuil5ttesma"
  },
  "etag": "1ed3f051"
}
```

Logo após, vem a _[tabela de roteamento](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingroutetables.htm)_ da subrede _"subnprv_vcn-db"_:

```
darmbrust@hoodwink:~$ oci network route-table update \
> --rt-id "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaamv5sy4life5tbektd6wnkgcqwzqcj5yk2pnkdnavqhacgj5buonq" \
> --route-rules '[{"cidrBlock": "192.168.20.0/24", "networkEntityId": "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa6j6l2svl5eesdetjkggyohypxqtzbqfv5qeqa7p7xkdbhdg7qfsa"}]' \
> --force \
> --wait-for-state "AVAILABLE"
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-05T17:53:07.934Z"
      }
    },
    "display-name": "Default Route Table for vcn-db",
    "freeform-tags": {},
    "id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaamv5sy4life5tbektd6wnkgcqwzqcj5yk2pnkdnavqhacgj5buonq",
    "lifecycle-state": "AVAILABLE",
    "route-rules": [
      {
        "cidr-block": "192.168.20.0/24",
        "description": null,
        "destination": "192.168.20.0/24",
        "destination-type": "CIDR_BLOCK",
        "network-entity-id": "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa6j6l2svl5eesdetjkggyohypxqtzbqfv5qeqa7p7xkdbhdg7qfsa"
      }
    ],
    "time-created": "2021-10-05T17:53:08.037000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qauzzbffpcd7xtcpxk7i3njt44gmurmaxvizr6mfz6eibq"
  },
  "etag": "2694d619"
}
```

Pronto! Agora as redes já se _"falam"_.

#### Teste de conectividade

Para demonstrar a conectividade entre essas duas redes, irei criar na subrede de produção _"subnprv_vcn-prd"_ uma instância, e na subrede _"subnprv_vcn-db"_ um banco de dados _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_.

Antes de qualquer provisionamento, irei ajustas ambas as _[security list](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/securitylists.htm)_ para permitir tráfego total:

```
darmbrust@hoodwink:~$ oci network security-list update \
> --security-list-id "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaass5hvduram6ehbzrzo6fyhflw7zewdsji45w5t3aq2m3agvsqnkq" \
> --egress-security-rules '[{"destination": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
> --ingress-security-rules '[{"source": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
> --force \
> --wait-for-state "AVAILABLE"
```

```
darmbrust@hoodwink:~$ oci network security-list update \
> --security-list-id "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaakiuso7lpjmfgbqeopmc75vusixj3cwkrpycc5356d7h36nrdxmcq" \
> --egress-security-rules '[{"destination": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
> --ingress-security-rules '[{"source": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
> --force \
> --wait-for-state "AVAILABLE"
```

>_**__NOTA:__** O propósito aqui é o teste de conectividade entre as [VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm). Ajuste as [security list](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/securitylists.htm) de acordo com as exigências de segurança do seu ambiente. Evite escancarar o acesso desta forma._

Irei criar um _[NAT Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/NATgateway.htm)_ e ajustar a _[tabela de roteamento](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingroutetables.htm)_ da subrede _"subnprv_vcn-prd"_ para poder usar este recurso. Isto também é necessário por conta do plugin _Bastion_ que será habilitado na instância a ser criada.

```
darmbrust@hoodwink:~$ oci network nat-gateway create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qaasugozouqxfpwajtaj3oymelmqwv2i2chmuil5ttesma" \
> --block-traffic false \
> --display-name "ntgw_vcn-prd" \
> --wait-for-state "AVAILABLE"
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "block-traffic": false,
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-06T16:35:53.633Z"
      }
    },
    "display-name": "ntgw_vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.natgateway.oc1.sa-saopaulo-1.aaaaaaaaldivjb67v6fbb54yx5pgtkebseejjgjn6kw3zu6fusxvspcchyaa",
    "lifecycle-state": "AVAILABLE",
    "nat-ip": "140.238.237.44",
    "public-ip-id": "ocid1.publicip.oc1.sa-saopaulo-1.aaaaaaaaumw77elrmpp5xgwvovvqwxjfmfu5lb5zmcpguv567jsag5matjqa",
    "time-created": "2021-10-06T16:35:54.088000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qaasugozouqxfpwajtaj3oymelmqwv2i2chmuil5ttesma"
  },
  "etag": "69083304--gzip"
}
```

```
darmbrust@hoodwink:~$ oci network route-table update \
> --rt-id "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaae2rhesecc4amfji763v3m324abufiml5asyxd64xfn57e7veipaq" \
> --route-rules '[{"cidrBlock": "0.0.0.0/0", "networkEntityId": "ocid1.natgateway.oc1.sa-saopaulo-1.aaaaaaaaldivjb67v6fbb54yx5pgtkebseejjgjn6kw3zu6fusxvspcchyaa"},
> {"cidrBlock": "172.16.30.0/24", "networkEntityId": "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa7yc6nig6frgdcl2rpqsblbmotvbda3onjkmxdsbcra4ztmkbvs2a"}]' \
> --force \
> --wait-for-state "AVAILABLE"
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-05T17:21:31.182Z"
      }
    },
    "display-name": "Default Route Table for vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaae2rhesecc4amfji763v3m324abufiml5asyxd64xfn57e7veipaq",
    "lifecycle-state": "AVAILABLE",
    "route-rules": [
      {
        "cidr-block": "0.0.0.0/0",
        "description": null,
        "destination": "0.0.0.0/0",
        "destination-type": "CIDR_BLOCK",
        "network-entity-id": "ocid1.natgateway.oc1.sa-saopaulo-1.aaaaaaaaldivjb67v6fbb54yx5pgtkebseejjgjn6kw3zu6fusxvspcchyaa"
      },
      {
        "cidr-block": "172.16.30.0/24",
        "description": null,
        "destination": "172.16.30.0/24",
        "destination-type": "CIDR_BLOCK",
        "network-entity-id": "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa7yc6nig6frgdcl2rpqsblbmotvbda3onjkmxdsbcra4ztmkbvs2a"
      }
    ],
    "time-created": "2021-10-05T17:21:31.275000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qaasugozouqxfpwajtaj3oymelmqwv2i2chmuil5ttesma"
  },
  "etag": "4e515a83"
}
```

Perceba que atualizar um recurso é no modo _"tudo ou nada"_. Não há atualização incremental. Neste caso, eu tive que inserir as duas regras na _[tabela de roteamento](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingroutetables.htm)_.

Abaixo os comandos que criam a instância e em seguida o banco de dados:

```
darmbrust@hoodwink:~$ oci compute instance launch \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaamcff6exkhvp4aq3ubxib2wf74v7cx22b3yj56jnfkazoissdzefq" \
> --availability-domain "ynrK:SA-SAOPAULO-1-AD-1" \
> --shape "VM.Standard.E2.1" \
> --subnet-id "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaary7wcifmwmmmavtfbjp45fxivvvisigjw76fr6pmyopulcbmjugq" \
> --display-name "vmlnx-1_subnprv_vcn-prd" \
> --fault-domain "FAULT-DOMAIN-1" \
> --hostname-label "vmlnx-1" \
> --image-id "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaasahnls6nmev22raz7ecw6i64d65fu27pmqjn4pgz7zue56ojj7qq" \
> --wait-for-state "RUNNING"
{
  "data": {
    "agent-config": {
      "are-all-plugins-disabled": false,
      "is-management-disabled": false,
      "is-monitoring-disabled": false,
      "plugins-config": null
    },
    "availability-config": {
      "is-live-migration-preferred": null,
      "recovery-action": "RESTORE_INSTANCE"
    },
    "availability-domain": "ynrK:SA-SAOPAULO-1-AD-1",
    "capacity-reservation-id": null,
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaamcff6exkhvp4aq3ubxib2wf74v7cx22b3yj56jnfkazoissdzefq",
    "dedicated-vm-host-id": null,
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-06T18:01:29.361Z"
      }
    },
    "display-name": "vmlnx-1_subnprv_vcn-prd",
    "extended-metadata": {},
    "fault-domain": "FAULT-DOMAIN-1",
    "freeform-tags": {},
    "id": "ocid1.instance.oc1.sa-saopaulo-1.antxeljr6noke4qcjjfy7pwmafgmjy6zfz5mtdbvh7xzsjghzjvw3hhltrmq",
    "image-id": "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaasahnls6nmev22raz7ecw6i64d65fu27pmqjn4pgz7zue56ojj7qq",
    "instance-options": {
      "are-legacy-imds-endpoints-disabled": false
    },
    "ipxe-script": null,
    "launch-mode": "PARAVIRTUALIZED",
    "launch-options": {
      "boot-volume-type": "PARAVIRTUALIZED",
      "firmware": "UEFI_64",
      "is-consistent-volume-naming-enabled": true,
      "is-pv-encryption-in-transit-enabled": false,
      "network-type": "PARAVIRTUALIZED",
      "remote-data-volume-type": "PARAVIRTUALIZED"
    },
    "lifecycle-state": "RUNNING",
    "metadata": {},
    "platform-config": null,
    "preemptible-instance-config": null,
    "region": "sa-saopaulo-1",
    "shape": "VM.Standard.E2.1",
    "shape-config": {
      "baseline-ocpu-utilization": null,
      "gpu-description": null,
      "gpus": 0,
      "local-disk-description": null,
      "local-disks": 0,
      "local-disks-total-size-in-gbs": null,
      "max-vnic-attachments": 2,
      "memory-in-gbs": 8.0,
      "networking-bandwidth-in-gbps": 0.7,
      "ocpus": 1.0,
      "processor-description": "2.0 GHz AMD EPYC\u2122 7551 (Naples)"
    },
    "source-details": {
      "boot-volume-size-in-gbs": null,
      "image-id": "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaasahnls6nmev22raz7ecw6i64d65fu27pmqjn4pgz7zue56ojj7qq",
      "kms-key-id": null,
      "source-type": "image"
    },
    "system-tags": {},
    "time-created": "2021-10-06T18:01:29.952000+00:00",
    "time-maintenance-reboot-due": null
  },
  "etag": "1e671e8d78d8291352edae7504bc096772155c1cc9972fb2f2f3894404d4d86b"
}
```

```
darmbrust@hoodwink:~$ oci mysql db-system create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaa6d2s5sgmxmyxu2vca3pn46y56xisijjyhdjwgqg3f6goh3obj4qq" \
> --availability-domain "ynrK:SA-SAOPAULO-1-AD-1" \
> --subnet-id "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaa5v2vsetv73xem2hlxf25uibpwcvci6nifidj3b6enf52m6bgy7ua" \
> --shape-name "VM.Standard.E2.1" \
> --configuration-id "ocid1.mysqlconfiguration.oc1..aaaaaaaah6o6qu3gdbxnqg6aw56amnosmnaycusttaa7abyq2tdgpgubvsgi" \
> --hostname-label "mysql" \
> --admin-username admin \
> --admin-password Sup3rS3cr3t0# \
> --data-storage-size-in-gbs 50 \
> --display-name "mysql_subnprv_vcn-db" \
> --backup-policy '{"isEnabled": false}'
{
  "data": {
    "analytics-cluster": null,
    "availability-domain": "ynrK:SA-SAOPAULO-1-AD-1",
    "backup-policy": {
      "defined-tags": null,
      "freeform-tags": null,
      "is-enabled": false,
      "retention-in-days": 7,
      "window-start-time": "05:10"
    },
    "channels": [],
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaa6d2s5sgmxmyxu2vca3pn46y56xisijjyhdjwgqg3f6goh3obj4qq",
    "configuration-id": "ocid1.mysqlconfiguration.oc1..aaaaaaaah6o6qu3gdbxnqg6aw56amnosmnaycusttaa7abyq2tdgpgubvsgi",
    "current-placement": {
      "availability-domain": null,
      "fault-domain": null
    },
    "data-storage-size-in-gbs": 50,
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-06T18:12:40.161Z"
      }
    },
    "description": null,
    "display-name": "mysql_subnprv_vcn-db",
    "endpoints": [],
    "fault-domain": null,
    "freeform-tags": {},
    "heat-wave-cluster": null,
    "hostname-label": "mysql",
    "id": "ocid1.mysqldbsystem.oc1.sa-saopaulo-1.aaaaaaaanhtufquzjk4euggk6lbvpkrlaqatztaq2eljxnea3cghuy3vgona",
    "ip-address": null,
    "is-analytics-cluster-attached": false,
    "is-heat-wave-cluster-attached": false,
    "is-highly-available": false,
    "lifecycle-details": null,
    "lifecycle-state": "CREATING",
    "maintenance": {
      "window-start-time": "WEDNESDAY 03:45"
    },
    "mysql-version": null,
    "port": null,
    "port-x": null,
    "shape-name": "VM.Standard.E2.1",
    "source": null,
    "subnet-id": "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaa5v2vsetv73xem2hlxf25uibpwcvci6nifidj3b6enf52m6bgy7ua",
    "time-created": "2021-10-06T18:12:41.376000+00:00",
    "time-updated": "2021-10-06T18:12:41.376000+00:00"
  },
  "etag": "c4b4d22517275d261b1c37d772d53a7c0d42e386372699fad6211b604328662b",
  "opc-work-request-id": "ocid1.mysqlworkrequest.oc1.sa-saopaulo-1.0069bdc4-5198-45e1-8a13-29aa5795336b.aaaaaaaas22kde2dnlgfhz47wh34n77eymldjq3svda6fr2fphb2yqibqtta"
}
```

Após uma _[sessão SSH](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm#session_types)_ ser estabelecida pelo bastion até a instância, é possível confirmar a conectividade entre os recursos:

```
[opc@vmlnx-1 ~]$ ip addr sh ens3
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 02:00:17:02:1f:88 brd ff:ff:ff:ff:ff:ff
    inet 192.168.20.10/24 brd 192.168.20.255 scope global dynamic ens3
       valid_lft 84736sec preferred_lft 84736sec
    inet6 fe80::17ff:fe02:1f88/64 scope link
       valid_lft forever preferred_lft forever

[opc@vmlnx-1 ~]$ ping -c 3 172.16.30.225
PING 172.16.30.225 (172.16.30.225) 56(84) bytes of data.
64 bytes from 172.16.30.225: icmp_seq=1 ttl=64 time=0.334 ms
64 bytes from 172.16.30.225: icmp_seq=2 ttl=64 time=0.467 ms
64 bytes from 172.16.30.225: icmp_seq=3 ttl=64 time=0.435 ms

--- 172.16.30.225 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2067ms
rtt min/avg/max/mdev = 0.334/0.412/0.467/0.056 ms
```

>_**__NOTA:__** Para criar uma [sessão SSH](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm#session_types) através do [serviço bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm) consulte o capítulo "[3.3 - Apresentando o Serviço Bastion](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-3/3-3_servico-bastion.md)"_.

### __Dynamic Routing Gateway (DRG)__

_[DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_ ou _[Dynamic Routing Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_, é uma espécie de _"roteador virtual"_ no qual você pode anexar diferentes recursos de redes, sendo eles:

- _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_
- _[Remote Peering Gateway (RPG)](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/remoteVCNpeering.htm#Remote_VCN_Peering_Across_Regions)_
- _[Túneis IPSec (VPN Site-To-Site)](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/overviewIPsec.htm)_
- _[FastConnect](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/fastconnect.htm)_

É o _[DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_ quem possibilita conectividade do seu _data center local (on-premises)_ ao _[OCI](https://www.oracle.com/cloud/)_, seja via _[VPN](https://pt.wikipedia.org/wiki/Rede_privada_virtual)_ ou através de _link dedicado ([FastConnect](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/fastconnect.htm))_. Uma outra funcionalidade está em possibilitar a conectividade de redes existentes em diferentes _[regiões](https://www.oracle.com/cloud/data-regions/)_, através do _[Remote Peering Gateway (RPG)](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/remoteVCNpeering.htm#Remote_VCN_Peering_Across_Regions)_.

Começaremos demonstrando como conectar diferentes _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ através do _[DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_, que se assemelha a uma _[rede em estrela](https://pt.wikipedia.org/wiki/Rede_em_estrela)_. 

![alt_text](./images/ch5-1_drg-1.jpg "Dynamic Routing Gateway (DRG)")

Em sua _[última atualização](https://blogs.oracle.com/cloud-infrastructure/post/introducing-global-connectivity-and-enhanced-cloud-networking-with-the-dynamic-routing-gateway)_, o _[DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_ ganhou a capacidade de poder anexar até _300 [VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ nele. Anteriormente, a conectividade entre _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ era através do _[Local Peering Gateway (LPG)](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ com um limite máximo de _10 peers_.

>_**__NOTA:__** Um [DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm) criado antes de 17 de maio de 2021 usa software legado. Somente o [DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm) que é criado recentemente consegue anexar múltiplas [VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm). O processo de upgrade é automatizado, ele redefine as sessões BGP existentes para a VPN Site-to-Site e FastConnect, e não há opção de fazer rollback de volta ao legado. De qualquer forma, sua atualização é um processo recomendado. Consulte os detalhes neste [link aqui](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm#upgrading_a_drg)._

A criação do _[DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_ é bem simples e pode ser feita com o comando abaixo:

```
darmbrust@hoodwink:~$ oci network drg create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --display-name "drg-saopaulo" \
> --wait-for-state "AVAILABLE"
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "default-drg-route-tables": {
      "ipsec-tunnel": "ocid1.drgroutetable.oc1.sa-saopaulo-1.aaaaaaaa7uiuayzduvzyrvzbyim6qbezc4twbfxhica6ivs6bpjwxncwb2tq",
      "remote-peering-connection": "ocid1.drgroutetable.oc1.sa-saopaulo-1.aaaaaaaa7uiuayzduvzyrvzbyim6qbezc4twbfxhica6ivs6bpjwxncwb2tq",
      "vcn": "ocid1.drgroutetable.oc1.sa-saopaulo-1.aaaaaaaa52mtpqflbvzt5xhax4tji3n7xt44vsxofd54wmnj5zbcmr3gxf5a",
      "virtual-circuit": "ocid1.drgroutetable.oc1.sa-saopaulo-1.aaaaaaaa7uiuayzduvzyrvzbyim6qbezc4twbfxhica6ivs6bpjwxncwb2tq"
    },
    "default-export-drg-route-distribution-id": "ocid1.drgroutedistribution.oc1.sa-saopaulo-1.aaaaaaaaykfkm3ewktdxp2xyfi4o4wqqghqtpbsmmrtkilguzpmruo5pvgza",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-07T14:32:48.024Z"
      }
    },
    "display-name": "drg-saopaulo",
    "freeform-tags": {},
    "id": "ocid1.drg.oc1.sa-saopaulo-1.aaaaaaaaonbn7qh4no24ublpdxhlu2solzkgkmoivpvg5ayxh45m3qn2puea",
    "lifecycle-state": "AVAILABLE",
    "time-created": "2021-10-07T14:32:48.056000+00:00"
  },
  "etag": "69204645--gzip"
}
```

De acordo com o nosso exemplo, criei três _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_:

```
darmbrust@hoodwink:~$ oci network vcn list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --all \
> --query "data[?contains(\"display-name\", 'vcn-')].{\"display-name\":\"display-name\",id:id,\"cidr-block\":\"cidr-block\"}" \
> --output table
+----------------+--------------+------------------------------------------------------------------------------------------+
| cidr-block     | display-name | id                                                                                       |
+----------------+--------------+------------------------------------------------------------------------------------------+
| 172.16.0.0/16  | vcn-db       | ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qa6jfxe5kay2cqjgo3lvb4mg5prscmpo62t2mk4h6wxsqa |
| 10.0.0.0/16    | vcn-dev      | ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qalaq2ftbdwt3ximh5gxgfrybjoj4xhzirdyka5pmsiysa |
| 192.168.0.0/16 | vcn-prd      | ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qafpwo6g7txowljx2dvdppnavruldbydbi3wvzaxr33d7q |
+----------------+--------------+------------------------------------------------------------------------------------------+
```

Uma _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ é anexada (atachada) ao _[DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_ através do comando abaixo:

```
darmbrust@hoodwink:~$ oci network drg-attachment create \
> --drg-id "ocid1.drg.oc1.sa-saopaulo-1.aaaaaaaaonbn7qh4no24ublpdxhlu2solzkgkmoivpvg5ayxh45m3qn2puea" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qa6jfxe5kay2cqjgo3lvb4mg5prscmpo62t2mk4h6wxsqa" \
> --display-name "vcn-db_attch_drg-saopaulo" \
> --wait-for-state "ATTACHED"
Action completed. Waiting until the resource has entered state: ('ATTACHED',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {},
    "display-name": "vcn-db_attch_drg-saopaulo",
    "drg-id": "ocid1.drg.oc1.sa-saopaulo-1.aaaaaaaaonbn7qh4no24ublpdxhlu2solzkgkmoivpvg5ayxh45m3qn2puea",
    "drg-route-table-id": "ocid1.drgroutetable.oc1.sa-saopaulo-1.aaaaaaaa52mtpqflbvzt5xhax4tji3n7xt44vsxofd54wmnj5zbcmr3gxf5a",
    "export-drg-route-distribution-id": null,
    "freeform-tags": {},
    "id": "ocid1.drgattachment.oc1.sa-saopaulo-1.aaaaaaaadiz5hjhqhjxbiffh533opvg45oua4lysduukklfqlwflopusnjna",
    "is-cross-tenancy": false,
    "lifecycle-state": "ATTACHED",
    "network-details": {
      "id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qa6jfxe5kay2cqjgo3lvb4mg5prscmpo62t2mk4h6wxsqa",
      "route-table-id": null,
      "type": "VCN"
    },
    "route-table-id": null,
    "time-created": "2021-10-07T16:51:50.739000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qa6jfxe5kay2cqjgo3lvb4mg5prscmpo62t2mk4h6wxsqa"
  },
  "etag": "69217292--gzip"
}
```

>_**__NOTA:__** Uma [VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm) só pode ser anexada a apenas um [DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm) por vez, mas um [DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm) pode ser anexado a mais de uma [VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_. 

Será poupado espaço por aqui. A sintaxe geral do comando para anexar as demais _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ é o mesmo, mudando apenas o _OCID_ e _DISPLAY NAME_ correspondentes.

O comando abaixo exibe as _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ que estão anexadas ao _[DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_:

```
darmbrust@hoodwink:~$ oci network drg-attachment list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --drg-id "ocid1.drg.oc1.sa-saopaulo-1.aaaaaaaaonbn7qh4no24ublpdxhlu2solzkgkmoivpvg5ayxh45m3qn2puea" \
> --attachment-type "VCN" \
> --all \
> --query "data[].{\"display-name\":\"display-name\",id:id}" \
> --output table
+----------------------------+----------------------------------------------------------------------------------------------------+
| display-name               | id                                                                                                 |
+----------------------------+----------------------------------------------------------------------------------------------------+
| vcn-prd_attch_drg-saopaulo | ocid1.drgattachment.oc1.sa-saopaulo-1.aaaaaaaavbajhgmvqrdqbquto7icvcv22w4ai5vthzverlbapksov55z4tgq |
| vcn-dev_attch_drg-saopaulo | ocid1.drgattachment.oc1.sa-saopaulo-1.aaaaaaaaucaaicrg7raskilprcboatfyhhap4yfiam7iv2z5fxg2rcaybmya |
| vcn-db_attch_drg-saopaulo  | ocid1.drgattachment.oc1.sa-saopaulo-1.aaaaaaaadiz5hjhqhjxbiffh533opvg45oua4lysduukklfqlwflopusnjna |
+----------------------------+----------------------------------------------------------------------------------------------------+
```

#### Criação dos demais recursos e ajustes no roteamento

Depois das _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ estarem anexadas ao _[DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_, para se ter conectividade é muito simples. A partir da subrede de origem, todo o tráfego de destino que se deseja alcançar, basta que o mesmo _"aponte"_ para o _[DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_.

Abaixo, irei criar os recursos para formar as redes já especificando a correta regra de roteamento de cada subrede.

- **vcn-prd**

Tabela de Roteamento:

```
darmbrust@hoodwink:~$ oci network route-table create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qafpwo6g7txowljx2dvdppnavruldbydbi3wvzaxr33d7q" \
> --display-name "rtb_subnprv_vcn-prd" \
> --route-rules '[{"destination": "172.16.60.0/24", "destinationType": "CIDR_BLOCK", "networkEntityId": "ocid1.drg.oc1.sa-saopaulo-1.aaaaaaaaonbn7qh4no24ublpdxhlu2solzkgkmoivpvg5ayxh45m3qn2puea"}]' \
> --wait-for-state "AVAILABLE"
```

Security List:

```
darmbrust@hoodwink:~$ oci network security-list create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --egress-security-rules '[{"destination": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
> --ingress-security-rules '[{"source": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qafpwo6g7txowljx2dvdppnavruldbydbi3wvzaxr33d7q" \
> --display-name "secl-1_subnprv_vcn-prd" \
> --wait-for-state "AVAILABLE"
```

DHCP Options:

```
darmbrust@hoodwink:~$ oci network dhcp-options create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --options '[{"type": "DomainNameServer", "serverType": "VcnLocalPlusInternet"}]' \
> --display-name "dhcp_vcn-prd" \
> --domain-name-type "VCN_DOMAIN" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qafpwo6g7txowljx2dvdppnavruldbydbi3wvzaxr33d7q" \
> --wait-for-state "AVAILABLE"
```

Subrede:

```
darmbrust@hoodwink:~$ oci network subnet create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qafpwo6g7txowljx2dvdppnavruldbydbi3wvzaxr33d7q" \
> --dhcp-options-id "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaaaezixfnh765nbuzt4evr3dkariexsmh7xmrpx5em5ewbudajdvia" \
> --route-table-id "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaaslzwy7ogyzc555dowwsxiiwtqlejb2vprsivygydqwmcfx7klhja" \
> --security-list-ids '["ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaaakhdinc4rf6uxjp55nrfbp7sxy5lbszmtguitmanq67ck3poo6da"]' \
> --display-name "subnprv_vcn-prd" \
> --dns-label "subnprvprd" \
> --cidr-block "192.168.20.0/24" \
> --prohibit-public-ip-on-vnic true \
> --wait-for-state "AVAILABLE"
```

- **vcn-dev**

Tabela de Roteamento:

```
darmbrust@hoodwink:~$ oci network route-table create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qalaq2ftbdwt3ximh5gxgfrybjoj4xhzirdyka5pmsiysa" \
> --display-name "rtb_subnprv_vcn-dev" \
> --route-rules '[{"destination": "172.16.30.0/24", "destinationType": "CIDR_BLOCK", "networkEntityId": "ocid1.drg.oc1.sa-saopaulo-1.aaaaaaaaonbn7qh4no24ublpdxhlu2solzkgkmoivpvg5ayxh45m3qn2puea"}]' \
> --wait-for-state "AVAILABLE"
```

Security List:

```
darmbrust@hoodwink:~$ oci network security-list create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --egress-security-rules '[{"destination": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
> --ingress-security-rules '[{"source": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
> --display-name "secl-1_subnprv_vcn-dev" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qalaq2ftbdwt3ximh5gxgfrybjoj4xhzirdyka5pmsiysa" \
> --wait-for-state "AVAILABLE"
```

DHCP Options:

```
darmbrust@hoodwink:~$ oci network dhcp-options create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --options '[{"type": "DomainNameServer", "serverType": "VcnLocalPlusInternet"}]' \
> --display-name "dhcp_vcn-dev" \
> --domain-name-type "VCN_DOMAIN" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qalaq2ftbdwt3ximh5gxgfrybjoj4xhzirdyka5pmsiysa" \
> --wait-for-state "AVAILABLE"
```

Subrede:

```
darmbrust@hoodwink:~$ oci network subnet create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qalaq2ftbdwt3ximh5gxgfrybjoj4xhzirdyka5pmsiysa" \
> --dhcp-options-id "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaaeqdywbm5oefqsgozehpojbdcex4t5gpyeqyqvp5bzfl3e6ewszfa" \
> --route-table-id "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaar57jlty5c2bz7hd6zlz7dcn7twfvklh7vstuvevxayy3rvm4vlkq" \
> --security-list-ids '["ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaagxnlxyo7utdqi7cot2iordjhtppaenzezjlfc3i6ryjv2mmi5zua"]' \
> --display-name "subnprv_vcn-dev" \
> --dns-label "subnprvdev" \
> --cidr-block "10.0.10.0/24" \
> --prohibit-public-ip-on-vnic true \
> --wait-for-state "AVAILABLE"
```

- **vcn-db**

Aqui merece uma simples explicação. 

Será criado uma rede para hospedar os bancos de dados de produção _(subnprv-prd_vcn-db)_ e desenvolvimento _(subnprv-dev_vcn-db)_. Cada subrede tem sua própria _[tabela de roteamento](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingroutetables.htm)_ que possibilita a conectividade com seu destino correspondente através do _[DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_.

Tabela de Roteamento:

```
darmbrust@hoodwink:~$ oci network route-table create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qa6jfxe5kay2cqjgo3lvb4mg5prscmpo62t2mk4h6wxsqa" \
> --display-name "rtb_subnprv-prd_vcn-db" \
> --route-rules '[{"destination": "192.168.20.0/24", "destinationType": "CIDR_BLOCK", "networkEntityId": "ocid1.drg.oc1.sa-saopaulo-1.aaaaaaaaonbn7qh4no24ublpdxhlu2solzkgkmoivpvg5ayxh45m3qn2puea"}]' \
> --wait-for-state "AVAILABLE"
```

```
darmbrust@hoodwink:~$ oci network route-table create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qa6jfxe5kay2cqjgo3lvb4mg5prscmpo62t2mk4h6wxsqa" \
> --display-name "rtb_subnprv-dev_vcn-db" \
> --route-rules '[{"destination":"10.0.10.0/24", "destinationType": "CIDR_BLOCK", "networkEntityId": "ocid1.drg.oc1.sa-saopaulo-1.aaaaaaaaonbn7qh4no24ublpdxhlu2solzkgkmoivpvg5ayxh45m3qn2puea"}]' \
> --wait-for-state "AVAILABLE"
```

Security List:

```
darmbrust@hoodwink:~$ oci network security-list create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --egress-security-rules '[{"destination": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
> --ingress-security-rules '[{"source": "10.0.10.0/24", "protocol": "all", "isStateless": false}]' \
> --display-name "secl-1_subnprv-dev_vcn-db" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qa6jfxe5kay2cqjgo3lvb4mg5prscmpo62t2mk4h6wxsqa" \
> --wait-for-state "AVAILABLE"
```

```
darmbrust@hoodwink:~$  oci network security-list create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --egress-security-rules '[{"destination": "0.0.0.0/0", "protocol": "all", "isStateless": false}]' \
> --ingress-security-rules '[{"source": "192.168.20.0/24", "protocol": "all", "isStateless": false}]' \
> --display-name "secl-1_subnprv-prd_vcn-db" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qa6jfxe5kay2cqjgo3lvb4mg5prscmpo62t2mk4h6wxsqa" \
> --wait-for-state "AVAILABLE"
```

DHCP Options:

```
darmbrust@hoodwink:~$ oci network dhcp-options create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --options '[{"type": "DomainNameServer", "serverType": "VcnLocalPlusInternet"}]' \
> --display-name "dhcp_vcn-db" \
> --domain-name-type "VCN_DOMAIN" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qa6jfxe5kay2cqjgo3lvb4mg5prscmpo62t2mk4h6wxsqa" \
> --wait-for-state "AVAILABLE"
```

Subrede:

```
darmbrust@hoodwink:~$ oci network subnet create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qa6jfxe5kay2cqjgo3lvb4mg5prscmpo62t2mk4h6wxsqa" \
> --dhcp-options-id "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaawcxysjb7sy5ohcbu4wh2jtyvmdrlrn4rqzbh24tksdazq5njso3a" \
> --route-table-id "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaavui46ym3y24xnyc4h6uzrtbq63ybywu6y33we6k6uy3624btisea" \
> --security-list-ids '["ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaahrs4lcp7a6dlnsqda5u4shdmvfpkd6tsxbc2nqygcrz2pfhwyxna"]' \
> --display-name "subnprv-dev_vcn-db" \
> --dns-label "subnprvdevdb" \
> --cidr-block "172.16.30.0/24" \
> --prohibit-public-ip-on-vnic true \
> --wait-for-state "AVAILABLE"
```

```
darmbrust@hoodwink:~$ oci network subnet create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qa6jfxe5kay2cqjgo3lvb4mg5prscmpo62t2mk4h6wxsqa" \
> --dhcp-options-id "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaawcxysjb7sy5ohcbu4wh2jtyvmdrlrn4rqzbh24tksdazq5njso3a" \
> --route-table-id "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaauhcustvcljfpjocdktkmmijhdznl5eaz4e4enzgnlbez7yslzdfq" \
> --security-list-ids '["ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaafnbfv4scm42ko5vcwztiv457asv2ghcig4l3nju4vjvsim276wsq"]' \
> --display-name "subnprv-prd_vcn-db" \
> --dns-label "subnprvprddb" \
> --cidr-block "172.16.60.0/24" \
> --prohibit-public-ip-on-vnic true \
> --wait-for-state "AVAILABLE"
```

#### Teste de conectividade

Tendo algumas instâncias criadas nas respectivas subredes, é possível realizar um simples teste pelo utilitário _[ping](https://pt.wikipedia.org/wiki/Ping)_ e confirmar a conectividade entre as redes:

- vcn-prd (subnprv_vcn-prd) p/ vcn-db (subnprv-prd_vcn-db)

```
[opc@vmlnx_vcn-prd ~]$ ip addr sh ens3
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 02:00:17:02:1f:88 brd ff:ff:ff:ff:ff:ff
    inet 192.168.20.46/24 brd 192.168.20.255 scope global dynamic ens3
       valid_lft 84736sec preferred_lft 84736sec
    inet6 fe80::17ff:fe02:1f88/64 scope link
       valid_lft forever preferred_lft forever

[opc@vmlnx_vcn-prd ~]$ ping -c 3 172.16.60.2
PING 172.16.60.2 (172.16.60.2) 56(84) bytes of data.
64 bytes from 172.16.60.2: icmp_seq=1 ttl=63 time=0.564 ms
64 bytes from 172.16.60.2: icmp_seq=2 ttl=63 time=0.555 ms
64 bytes from 172.16.60.2: icmp_seq=3 ttl=63 time=0.539 ms

--- 172.16.60.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2074ms
rtt min/avg/max/mdev = 0.539/0.552/0.564/0.029 ms
```

- vcn-dev (subnprv_vcn-dev) p/ vcn-db (subnprv-dev_vcn-db)

```
[opc@vmlnx_vcn-dev ~]$ ip addr sh ens3
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 84:39:be:6c:fa:82 brd ff:ff:ff:ff:ff:ff
    inet 10.0.10.5/24 brd 10.0.10.255 scope global dynamic ens3
       valid_lft 84736sec preferred_lft 84736sec
    inet6 fe80::17ff:fe02:1f88/64 scope link
       valid_lft forever preferred_lft forever

[opc@vmlnx_vcn-dev ~]$ ping -c 3 172.16.30.111
PING 172.16.30.111 (172.16.30.111) 56(84) bytes of data.
64 bytes from 172.16.30.111: icmp_seq=1 ttl=63 time=0.436 ms
64 bytes from 172.16.30.111: icmp_seq=2 ttl=63 time=0.563 ms
64 bytes from 172.16.30.111: icmp_seq=3 ttl=63 time=0.396 ms

--- 172.16.30.111 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2061ms
rtt min/avg/max/mdev = 0.396/0.465/0.563/0.071 ms
```

### __Conclusão__

Aqui encerramos este capítulo que trata a conectividade de várias redes no _[OCI](https://www.oracle.com/cloud/)_. O processo de conectividade é simples, sempre se atentando para não haver sobreposição das redes _(overlap)_ e cuidando bem das suas regras de segurança _([security list](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/securitylists.htm) e [nsg](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/networksecuritygroups.htm))_, são o sucesso de um bom design de redes.

Toda _[security list](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/securitylists.htm)_ _"escancarada"_ aqui, tem o propósito somente de demonstrar a conectividade. Volto a dizer: para o seu ambiente não faça isto!