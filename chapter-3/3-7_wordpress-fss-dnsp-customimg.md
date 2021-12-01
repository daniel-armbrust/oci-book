# Capítulo 3: Primeira aplicação no OCI

## 3.7 - File Storage, DNS privado e Custom Image

### __Visão Geral__

Como sabemos, o _[OCI](https://www.oracle.com/cloud/)_ disponibiliza uma série de recursos que nos possibilita construir aplicações _[tolerantes à falhas](https://pt.wikipedia.org/wiki/Toler%C3%A2ncia_%C3%A0_falha)_. Neste capítulo, irei apresentar alguns serviços úteis para a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_, com o intuíto de evitar o chamado _"[ponto único de falha](https://pt.wikipedia.org/wiki/Ponto_%C3%BAnico_de_falha)"_.

Evitar o _"[ponto único de falha](https://pt.wikipedia.org/wiki/Ponto_%C3%BAnico_de_falha)"_, reduz o _tempo de indisponibilidade_, seja ele planejado ou não. Lembrando que uma _indisponibilidade_ pode vir de uma _manutenção programada_, exigida para manter a aplicação operando _(patches, novo deploy, fix de segurança, etc)_, ou de uma _falha de hardware_, _software_, ou mesmo um _"erro humano"_.

Contornamos essas _indisponibilidades_, através dos serviços disponíveis pelo _[OCI](https://www.oracle.com/cloud/)_. 

Vamos começar...

### __O Serviço File Storage__

O _[Serviço File Storage](https://docs.oracle.com/pt-br/iaas/Content/File/Concepts/filestorageoverview.htm)_ fornece um _[sistema de arquivos](https://pt.wikipedia.org/wiki/Sistema_de_ficheiros)_ de rede, compatível com o protocolo _[NFS](https://pt.wikipedia.org/wiki/Network_File_System)_ e gerenciado pelo _[OCI](https://www.oracle.com/cloud/)_. Por ser um _[sistema de arquivos](https://pt.wikipedia.org/wiki/Sistema_de_ficheiros)_ gerenciado, seus ajustes de capacidade, atualizações e proteção contra falhas de hardware, são feitas de forma automática. 

Você pode se conectar a um _[sistema de arquivos](https://pt.wikipedia.org/wiki/Sistema_de_ficheiros)_ criado pelo _[Serviço File Storage](https://docs.oracle.com/pt-br/iaas/Content/File/Concepts/filestorageoverview.htm)_ a partir de qualquer instância computacional em sua _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_, ou a partir do seu data center local _(on-premises)_ via _[FastConnect](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/fastconnectoverview.htm#FastConnect_Overview)_ ou _[VPN](https://pt.wikipedia.org/wiki/Rede_privada_virtual)_.

A ideia de usar este serviço é poder disponibilizar um _[sistema de arquivos](https://pt.wikipedia.org/wiki/Sistema_de_ficheiros)_ acessível pela rede, à múltiplas instâncias da aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_. Isto por conta de que o _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_ armazena as imagens que vem via _[upload](https://en.wikipedia.org/wiki/Upload)_, em um diretório na instância _(/var/www/html/wp-content/uploads)_.

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

```
darmbrust@hoodwink:~$ oci fs file-system create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
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