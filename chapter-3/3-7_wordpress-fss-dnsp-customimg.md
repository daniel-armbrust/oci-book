# Capítulo 3: Primeira aplicação no OCI

## 3.7 - File Storage, DNS privado e Custom Image

### __Visão Geral__

Como sabemos, o _[OCI](https://www.oracle.com/cloud/)_ disponibiliza uma série de recursos que nos possibilita construir aplicações _[tolerantes à falhas](https://pt.wikipedia.org/wiki/Toler%C3%A2ncia_%C3%A0_falha)_. Neste capítulo, irei apresentar alguns serviços úteis para a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_, com o intuíto de evitar o chamado _"[ponto único de falha](https://pt.wikipedia.org/wiki/Ponto_%C3%BAnico_de_falha)"_.

Evitar o _"[ponto único de falha](https://pt.wikipedia.org/wiki/Ponto_%C3%BAnico_de_falha)"_, reduz o _tempo de indisponibilidade_, seja ele planejado ou não. Lembrando que uma _indisponibilidade_ pode vir de uma _manutenção programada_, exigida para manter a aplicação operando _(patches, novo deploy, fix de segurança, etc)_, ou de uma _falha de hardware_, _software_, ou mesmo um _"erro humano"_.

Contornamos essas _indisponibilidades_, através dos serviços disponíveis no _[OCI](https://www.oracle.com/cloud/)_. 

Vamos começar...

### __O Serviço File Storage__

O _[Serviço File Storage](https://docs.oracle.com/pt-br/iaas/Content/File/Concepts/filestorageoverview.htm)_ fornece um _[sistema de arquivos](https://pt.wikipedia.org/wiki/Sistema_de_ficheiros)_ de rede, compatível com o protocolo _[NFS](https://pt.wikipedia.org/wiki/Network_File_System)_ e gerenciado pelo _[OCI](https://www.oracle.com/cloud/)_. Por ser um _[sistema de arquivos](https://pt.wikipedia.org/wiki/Sistema_de_ficheiros)_ gerenciado, seus ajustes de capacidade, atualizações e proteção contra falhas, são feitos de forma automática. 

Você pode se conectar a um _[sistema de arquivos](https://pt.wikipedia.org/wiki/Sistema_de_ficheiros)_ criado pelo _[Serviço File Storage](https://docs.oracle.com/pt-br/iaas/Content/File/Concepts/filestorageoverview.htm)_ a partir de qualquer instância computacional em sua _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_, ou a partir do seu data center local _(on-premises)_ via _[FastConnect](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/fastconnectoverview.htm#FastConnect_Overview)_ ou _[VPN](https://pt.wikipedia.org/wiki/Rede_privada_virtual)_.

A ideia em utilizar este serviço é por conta de que o _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_ armazena as imagens que vem via _[upload](https://en.wikipedia.org/wiki/Upload)_, em um diretório na instância _(/var/www/html/wp-content/uploads)_.

Para começar, precisamos do nome do _[availability domain (AD)](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm#top)_ dentro da _[região](https://www.oracle.com/cloud/data-regions/)_ no qual iremos criar o _[File Storage](https://docs.oracle.com/pt-br/iaas/Content/File/Concepts/filestorageoverview.htm)_:

```
darmbrust@hoodwink:~$ oci iam availability-domain list \
> --region "sa-saopaulo-1" \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --all \
> --query "data[].name"
[
  "ynrK:SA-SAOPAULO-1-AD-1"
]
```

Tendo o _[availability domain (AD)](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm#top)_, é possível criar o _[sistema de arquivos](https://pt.wikipedia.org/wiki/Sistema_de_ficheiros)_:

```
darmbrust@hoodwink:~$ oci fs file-system create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --region "sa-saopaulo-1" \
> --availability-domain "ynrK:SA-SAOPAULO-1-AD-1" \
> --display-name "fss-wordpress_subnprv-app_vcn-prd" \
> --wait-for-state "ACTIVE"
Action completed. Waiting until the resource has entered state: ('ACTIVE',)
{
  "data": {
    "availability-domain": "ynrK:SA-SAOPAULO-1-AD-1",
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-12-01T17:43:31.054Z"
      }
    },
    "display-name": "fss-wordpress_subnprv-app_vcn-prd",
    "freeform-tags": {},
    "id": "ocid1.filesystem.oc1.sa_saopaulo_1.aaaaaaaaaaac4dpmm5zhkllqojxwiottmewxgylpobqxk3dpfuys2ylefuyqaaaa",
    "is-clone-parent": false,
    "is-hydrated": true,
    "kms-key-id": "",
    "lifecycle-details": "",
    "lifecycle-state": "ACTIVE",
    "metered-bytes": 0,
    "source-details": {
      "parent-file-system-id": "",
      "source-snapshot-id": ""
    },
    "time-created": "2021-12-01T17:43:31.737000+00:00"
  },
  "etag": "eaa65659cb0201d8ee1f7487aa9b0ae593f349100ec6f5168b05feaf2eda33a4--gzip"
}
```

Um _[sistema de arquivos](https://pt.wikipedia.org/wiki/Sistema_de_ficheiros)_ criado pelo _[File Storage](https://docs.oracle.com/pt-br/iaas/Content/File/Concepts/filestorageoverview.htm)_, necessita de _[Mount Target](https://docs.oracle.com/en-us/iaas/Content/File/Tasks/managingmounttargets.htm)_, conhecido também como _"ponto-de-montagem NFS"_. 

O _[Mount Target](https://docs.oracle.com/en-us/iaas/Content/File/Tasks/managingmounttargets.htm)_ ao ser criado, recebe um _endereço IP_ e um _hostname_, para que os clientes da rede possam se conectar. Por conta disto, o _[Mount Target](https://docs.oracle.com/en-us/iaas/Content/File/Tasks/managingmounttargets.htm)_ necessita residir em uma subrede. Para o nosso caso, a subrede será a mesma das instâncias da aplicação.

```
darmbrust@hoodwink:~$ oci fs mount-target create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --availability-domain "ynrK:SA-SAOPAULO-1-AD-1" \
> --subnet-id "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaajb4wma763mz6uowun3pfeltobe4fmiegdeyma5ehvnf3kzy3jvxa" \
> --display-name "mt-fss-wordpress_subnprv-app_vcn-prd" \
> --hostname-label "fss-wordpress" \
> --wait-for-state "ACTIVE"
Action completed. Waiting until the resource has entered state: ('ACTIVE',)
{
  "data": {
    "availability-domain": "ynrK:SA-SAOPAULO-1-AD-1",
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-12-02T12:19:16.238Z"
      }
    },
    "display-name": "mt-fss-wordpress_subnprv-app_vcn-prd",
    "export-set-id": "ocid1.exportset.oc1.sa_saopaulo_1.aaaaaa4np2s2rg76m5zhkllqojxwiottmewxgylpobqxk3dpfuys2ylefuyqaaaa",
    "freeform-tags": {},
    "id": "ocid1.mounttarget.oc1.sa_saopaulo_1.aaaaaa4np2s2rg77m5zhkllqojxwiottmewxgylpobqxk3dpfuys2ylefuyqaaaa",
    "lifecycle-details": "",
    "lifecycle-state": "ACTIVE",
    "nsg-ids": [],
    "private-ip-ids": [
      "ocid1.privateip.oc1.sa-saopaulo-1.aaaaaaaahmvcco6gba3ocvwpk3sagbfy6fxuusossgaio4gqfzgrd4awayha"
    ],
    "subnet-id": "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaajb4wma763mz6uowun3pfeltobe4fmiegdeyma5ehvnf3kzy3jvxa",
    "time-created": "2021-12-02T12:19:17.892000+00:00"
  },
  "etag": "8ff6cec6bcc678b6a6238598977f449e3407ebdf74db8e5b9825c41b4230d034--gzip"
}
```

Para finalizar, é necessário criar um _"[export](https://docs.oracle.com/pt-br/iaas/Content/File/Tasks/managingmounttargets.htm#Overview)"_. Um _[sistema de arquivos](https://pt.wikipedia.org/wiki/Sistema_de_ficheiros)_ pode ser exportado por meio de um ou mais _"pontos de acesso NFS"_. É necessário pelo menos um _"[export](https://docs.oracle.com/pt-br/iaas/Content/File/Tasks/managingmounttargets.htm#Overview)"_ para que os clientes da rede possam _"montar"_ o _[sistema de arquivos](https://pt.wikipedia.org/wiki/Sistema_de_ficheiros)_.

Para criar o _"[export](https://docs.oracle.com/pt-br/iaas/Content/File/Tasks/managingmounttargets.htm#Overview)"_, especificamos um caminho qualquer _(--path)_, junto com os _OCIDs_ do _[sistema de arquivos](https://pt.wikipedia.org/wiki/Sistema_de_ficheiros)_ e _[Mount Target](https://docs.oracle.com/en-us/iaas/Content/File/Tasks/managingmounttargets.htm)_ que criamos:

```
darmbrust@hoodwink:~$ oci fs export create \
> --file-system-id "ocid1.filesystem.oc1.sa_saopaulo_1.aaaaaaaaaaac4dpmm5zhkllqojxwiottmewxgylpobqxk3dpfuys2ylefuyqaaaa" \
> --export-set-id "ocid1.exportset.oc1.sa_saopaulo_1.aaaaaa4np2s2rg76m5zhkllqojxwiottmewxgylpobqxk3dpfuys2ylefuyqaaaa" \
> --path "/wordpress-uploads" \
> --wait-for-state "ACTIVE"
Action completed. Waiting until the resource has entered state: ('ACTIVE',)
{
  "data": {
    "export-options": [
      {
        "access": "READ_WRITE",
        "anonymous-gid": 65534,
        "anonymous-uid": 65534,
        "identity-squash": "NONE",
        "require-privileged-source-port": false,
        "source": "0.0.0.0/0"
      }
    ],
    "export-set-id": "ocid1.exportset.oc1.sa_saopaulo_1.aaaaaa4np2s2rg76m5zhkllqojxwiottmewxgylpobqxk3dpfuys2ylefuyqaaaa",
    "file-system-id": "ocid1.filesystem.oc1.sa_saopaulo_1.aaaaaaaaaaac4dpmm5zhkllqojxwiottmewxgylpobqxk3dpfuys2ylefuyqaaaa",
    "id": "ocid1.export.oc1.sa_saopaulo_1.aaaaaa4np2s2rhhnm5zhkllqojxwiottmewxgylpobqxk3dpfuys2ylefuyqaaaa",
    "lifecycle-state": "ACTIVE",
    "path": "/wordpress-uploads",
    "time-created": "2021-12-02T14:15:55+00:00"
  },
  "etag": "11b046bd750b736f4d7f9b495e1e03b88ae26d8eba7c6c961e4c7d82d15d1814--gzip"
}
```
