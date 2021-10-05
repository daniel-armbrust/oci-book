# Capítulo 5: Mais sobre Redes no OCI

## 5.1 - Conectando múltiplas VCNs na mesma região

### __Local Peering Gateway (LPG)__

_[Local Peering Gateway (LPG)](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ é um recurso que permite conectar duas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ na mesma região possiblitando comunicação via endereços IP privados e sem rotear o tráfego pela internet. As _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ podem estar no mesmo _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_ ou em _[tenancies](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_ distintos. 

Lembrando que se não houver pareamento via _[LGP](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ entre duas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_, é necessário a utilização de um _[Internet Gateway](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingIGs.htm#Internet_Gateway)_ e endereços IP públicos para que os recursos se comuniquem. Porém, isto acaba expondo a comunicação deles de forma indevia pela internet.

Demonstraremos a criação do _[Local Peering Gateway (LPG)](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ conforme o desenho abaixo:

![alt_text](./images/ch5-1_lpg-1.jpg "Local Peering Gateway (LGP)")

Lembre-se que as duas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ que se conectam via _[LPG](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_, necessitam ter blocos _[CIDRs](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)_ diferentes (sem sobreposição) e estar na mesma região.


#### VCN de Produção (vcn-prd) 

Começaremos pela criação da _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ de produção:

```
darmbrust@hoodwink:~$ oci network vcn create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" 
> --cidr-blocks '["10.0.0.0/16"]' \
> --display-name "vcn-prd" \
> --dns-label "vcnprd" \
> --is-ipv6-enabled false \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "cidr-block": "10.0.0.0/16",
    "cidr-blocks": [
      "10.0.0.0/16"
    ],
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "default-dhcp-options-id": "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaaobne6utiqo6ri6mbajytx2o2gibdtlxir5oujcedlwtwghjmhq3q",
    "default-route-table-id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaazkbucct2vc522pcye6jcldcrrqjm7kdcjlsvkyvosaopbmlywr7q",
    "default-security-list-id": "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaacczjrwz7gftbl46vhm5a3b3rd2ntuu7dvwawc3zc5zc6pn4gav7a",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-22T18:41:26.573Z"
      }
    },
    "display-name": "vcn-prd",
    "dns-label": "vcnprd",
    "freeform-tags": {},
    "id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qapu7nhvarjqmxzj4323rvn55flsj2salguah54hjuipva",
    "ipv6-cidr-blocks": null,
    "lifecycle-state": "AVAILABLE",
    "time-created": "2021-09-22T18:41:26.732000+00:00",
    "vcn-domain-name": "vcnprd.oraclevcn.com"
  },
  "etag": "a49a4af8"
}
```

Para a subrede pública de produção, usaremos os recursos _[dhcp options](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDHCP.htm)_, _[tabela de roteamento](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingroutetables.htm)_ e _[security lists](https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/datatypes/IngressSecurityRule)_ que foram criados por padrão no momento em que a _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ foi criada.

```
darmbrust@hoodwink:~$ oci network subnet create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qapu7nhvarjqmxzj4323rvn55flsj2salguah54hjuipva" \
> --dhcp-options-id "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaaobne6utiqo6ri6mbajytx2o2gibdtlxir5oujcedlwtwghjmhq3q" \
> --route-table-id "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaazkbucct2vc522pcye6jcldcrrqjm7kdcjlsvkyvosaopbmlywr7q" \
> --security-list-ids '["ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaacczjrwz7gftbl46vhm5a3b3rd2ntuu7dvwawc3zc5zc6pn4gav7a"]' \
> --display-name "subnpub_vcn-prd" \
> --dns-label "subnpub" \
> --cidr-block "10.0.50.0/24" \
> --prohibit-public-ip-on-vnic false \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "availability-domain": null,
    "cidr-block": "10.0.50.0/24",
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-22T19:01:26.495Z"
      }
    },
    "dhcp-options-id": "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaaobne6utiqo6ri6mbajytx2o2gibdtlxir5oujcedlwtwghjmhq3q",
    "display-name": "subnpub_vcn-prd",
    "dns-label": "subnpub",
    "freeform-tags": {},
    "id": "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaakopvvmb5eyqcz4bupfsxhztoiixhbskhli4zrrzevbdxfgwhzyfq",
    "ipv6-cidr-block": null,
    "ipv6-virtual-router-ip": null,
    "lifecycle-state": "AVAILABLE",
    "prohibit-internet-ingress": false,
    "prohibit-public-ip-on-vnic": false,
    "route-table-id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaazkbucct2vc522pcye6jcldcrrqjm7kdcjlsvkyvosaopbmlywr7q",
    "security-list-ids": [
      "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaacczjrwz7gftbl46vhm5a3b3rd2ntuu7dvwawc3zc5zc6pn4gav7a"
    ],
    "subnet-domain-name": "subnpub.vcnprd.oraclevcn.com",
    "time-created": "2021-09-22T19:01:26.551000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qapu7nhvarjqmxzj4323rvn55flsj2salguah54hjuipva",
    "virtual-router-ip": "10.0.50.1",
    "virtual-router-mac": "00:00:17:66:FE:43"
  },
  "etag": "773e861b"
}
```

#### VCN de Banco de Dados (vcn-db)

O processo de criação da _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ para banco de dados segue o mesmo padrão.

```
darmbrust@hoodwink:~$ oci network vcn create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaaie4exnvj2ktkjlliahl2bxmdnteu2xmn27oc5cy5mdcmocl4vd7q" \
> --cidr-blocks '["172.16.30.0/24"]' \
> --display-name "vcn-db" \
> --dns-label "vcndb" \
> --is-ipv6-enabled false \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "cidr-block": "172.16.30.0/24",
    "cidr-blocks": [
      "172.16.30.0/24"
    ],
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaaie4exnvj2ktkjlliahl2bxmdnteu2xmn27oc5cy5mdcmocl4vd7q",
    "default-dhcp-options-id": "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaal25rtfga7lidrfwcxgrbhxbkl7fik2jsxxvo5j6da7nuar7yxl4q",
    "default-route-table-id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaap5aco4nbigwa4fz2nlda3er2lp4jhccq3gyq4bsx7qloqumg5faa",
    "default-security-list-id": "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaaolot54cbhbw4fmm62rcx4u4ayidxicm2y4s7dw7mj6osboa5qvvq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-22T18:43:56.895Z"
      }
    },
    "display-name": "vcn-db",
    "dns-label": "vcndb",
    "freeform-tags": {},
    "id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qahidmpliuijfn6mum4maic3nhtgqlofvfdsl6hpfg3d3q",
    "ipv6-cidr-blocks": null,
    "lifecycle-state": "AVAILABLE",
    "time-created": "2021-09-22T18:43:57.136000+00:00",
    "vcn-domain-name": "vcndb.oraclevcn.com"
  },
  "etag": "cb1b5107"
}
```

```
darmbrust@hoodwink:~$ oci network subnet create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaaie4exnvj2ktkjlliahl2bxmdnteu2xmn27oc5cy5mdcmocl4vd7q" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qahidmpliuijfn6mum4maic3nhtgqlofvfdsl6hpfg3d3q" \
> --dhcp-options-id "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaal25rtfga7lidrfwcxgrbhxbkl7fik2jsxxvo5j6da7nuar7yxl4q" \
> --route-table-id "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaap5aco4nbigwa4fz2nlda3er2lp4jhccq3gyq4bsx7qloqumg5faa" \
> --security-list-ids '["ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaaolot54cbhbw4fmm62rcx4u4ayidxicm2y4s7dw7mj6osboa5qvvq"]' \
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
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaaie4exnvj2ktkjlliahl2bxmdnteu2xmn27oc5cy5mdcmocl4vd7q",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-22T19:34:44.016Z"
      }
    },
    "dhcp-options-id": "ocid1.dhcpoptions.oc1.sa-saopaulo-1.aaaaaaaal25rtfga7lidrfwcxgrbhxbkl7fik2jsxxvo5j6da7nuar7yxl4q",
    "display-name": "subnprv_vcn-db",
    "dns-label": "subnprv",
    "freeform-tags": {},
    "id": "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaagniylqruzn35iv3n7ntxnix6ew3t5z3kwj5ey72fpwrablass65q",
    "ipv6-cidr-block": null,
    "ipv6-virtual-router-ip": null,
    "lifecycle-state": "AVAILABLE",
    "prohibit-internet-ingress": true,
    "prohibit-public-ip-on-vnic": true,
    "route-table-id": "ocid1.routetable.oc1.sa-saopaulo-1.aaaaaaaap5aco4nbigwa4fz2nlda3er2lp4jhccq3gyq4bsx7qloqumg5faa",
    "security-list-ids": [
      "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaaolot54cbhbw4fmm62rcx4u4ayidxicm2y4s7dw7mj6osboa5qvvq"
    ],
    "subnet-domain-name": "subnprv.vcndb.oraclevcn.com",
    "time-created": "2021-09-22T19:34:44.078000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qahidmpliuijfn6mum4maic3nhtgqlofvfdsl6hpfg3d3q",
    "virtual-router-ip": "172.16.30.1",
    "virtual-router-mac": "00:00:17:C1:12:B0"
  },
  "etag": "7a9ef2e5"
}
```

#### VCN de Banco de Dados (vcn-db)

```
darmbrust@hoodwink:~$ oci network local-peering-gateway create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qapu7nhvarjqmxzj4323rvn55flsj2salguah54hjuipva" \
> --display-name "lpg_vcn-prd" \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
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
    "peer-advertised-cidr": null,
    "peer-advertised-cidr-details": null,
    "peer-id": null,
    "peering-status": "NEW",
    "peering-status-details": "Not connected to a peer.",
    "route-table-id": null,
    "time-created": "2021-09-22T19:48:15.875000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qapu7nhvarjqmxzj4323rvn55flsj2salguah54hjuipva"
  },
  "etag": "d316556c"
}
```

#### Conexão através do Local Peering Gateway (LPG)

É necessário criar um _[LPG](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_ do lado de cada _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_:

- **vcn-prd**

```
darmbrust@hoodwink:~$ oci network local-peering-gateway create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qapu7nhvarjqmxzj4323rvn55flsj2salguah54hjuipva" \
> --display-name "lpg_vcn-prd" \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
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
    "peer-advertised-cidr": null,
    "peer-advertised-cidr-details": null,
    "peer-id": null,
    "peering-status": "NEW",
    "peering-status-details": "Not connected to a peer.",
    "route-table-id": null,
    "time-created": "2021-09-22T19:48:15.875000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qapu7nhvarjqmxzj4323rvn55flsj2salguah54hjuipva"
  },
  "etag": "d316556c"
}
```

- **vcn-db**

```
darmbrust@hoodwink:~$ oci network local-peering-gateway create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --vcn-id "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qahidmpliuijfn6mum4maic3nhtgqlofvfdsl6hpfg3d3q" \
> --display-name "lpg_vcn-db" \
> --wait-for-state AVAILABLE
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-22T19:52:02.559Z"
      }
    },
    "display-name": "lpg_vcn-db",
    "freeform-tags": {},
    "id": "ocid1.localpeeringgateway.oc1.sa-saopaulo-1.aaaaaaaa7ntl6vzave2qrlmmpx5ynbmjnnn7xsmh76zzg4ihdwsq5mzqxaoa",
    "is-cross-tenancy-peering": false,
    "lifecycle-state": "AVAILABLE",
    "peer-advertised-cidr": null,
    "peer-advertised-cidr-details": null,
    "peer-id": null,
    "peering-status": "NEW",
    "peering-status-details": "Not connected to a peer.",
    "route-table-id": null,
    "time-created": "2021-09-22T19:52:02.598000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaa6noke4qahidmpliuijfn6mum4maic3nhtgqlofvfdsl6hpfg3d3q"
  },
  "etag": "2f1e88ec"
}
```

A conexão das duas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ é feita pelo _[LPG](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_  _solicitante (--local-peering-gateway-id)_ com o _aceitador (--peer-id)_:

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
