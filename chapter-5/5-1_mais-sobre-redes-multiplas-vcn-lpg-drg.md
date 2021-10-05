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
> --wait-for-state AVAILABLE
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
> --wait-for-state AVAILABLE
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
> --wait-for-state AVAILABLE
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
> --wait-for-state AVAILABLE
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
> --wait-for-state AVAILABLE
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
> --wait-for-state AVAILABLE
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

Em nosso caso quem _solicita a conexão_ é o _[LPG](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ que foi plugado na _vcn-prd_, sendo que quem _aceita_ é _[LPG](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ que foi plugado na _vcn-db_.

```
darmbrust@hoodwink:~$ oci network local-peering-gateway connect \
> --local-peering-gateway-id "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaajtpagmjpddmhrqfvp6w6jsqvdhx3nmijhmblq3sgbnrkmefuaaza" \
> --peer-id "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa7ntl6vzave2qrlmmpx5ynbmjnnn7xsmh76zzg4ihdwsq5mzqxaoa"
{
  "etag": "48472ecc"
}
```

Para verificar o status da conexão, usamos o comando abaixo:

```
darmbrust@hoodwink:~$ oci network local-peering-gateway get \
> --local-peering-gateway-id "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaajtpagmjpddmhrqfvp6w6jsqvdhx3nmijhmblq3sgbnrkmefuaaza"
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-22T19:48:15.835Z"
      }
    },
    "display-name": "lpg_vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaajtpagmjpddmhrqfvp6w6jsqvdhx3nmijhmblq3sgbnrkmefuaaza",
    "is-cross-tenancy-peering": false,
    "lifecycle-state": "AVAILABLE",
    "peer-advertised-cidr": "172.16.30.0/24",
    "peer-advertised-cidr-details": [
      "172.16.30.0/24"
    ],
    "peer-id": "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa7ntl6vzave2qrlmmpx5ynbmjnnn7xsmh76zzg4ihdwsq5mzqxaoa",
    "peering-status": "PEERED",
    "peering-status-details": "Connected to a peer.",
    "route-table-id": null,
    "time-created": "2021-09-22T19:48:15.875000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qapu7nhvarjqmxzj4323rvn55flsj2salguah54hjuipva"
  },
  "etag": "48472ecc"
}
```

É possível confirmar a conectividade pela propriedade _"peering-status"_ com valor _"PEERED"_, além do anúncio do bloco _[CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)_ vindo da _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ de banco de dados (vcn-db) através da propriedade _"peer-advertised-cidr"_ contendo o valor _"172.16.30.0/24"_.
