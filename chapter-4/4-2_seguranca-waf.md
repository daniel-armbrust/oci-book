# Capítulo 4: Melhorias na aplicação Wordpress

## 4.1 - Adicionando segurança. Seja bem-vindo WAF!

### __Visão Geral__

O _[Serviço Web Application Firewall](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm)_ ou _[WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm)_, é um serviço de segurança global, gerenciado pelo _[OCI](https://www.oracle.com/cloud/)_ e compatível com o padrão _[PCI (Payment Card Industry)](https://en.wikipedia.org/wiki/Payment_card_industry)_ que protege aplicativos do tráfego malicioso e indesejado existente na internet. Ele pode proteger qualquer aplicação exposta na internet e que faça uso dos protocolos _[HTTP](https://pt.wikipedia.org/wiki/Hypertext_Transfer_Protocol)_ e/ou _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_.

Para você ter uma ideia, qualquer empresa que aceita pagamentos com cartão de crédito/débito, que processa ou armazena dados de cartões, precisa se preocupar em estar em conformidade com o _[PCI](https://en.wikipedia.org/wiki/Payment_card_industry)_. Para maiores informações, consulte este _[link aqui](https://pt.pcisecuritystandards.org/minisite/env2/)_.

Já falamos aqui sobre a _[Camada 7](https://pt.wikipedia.org/wiki/Camada_de_aplica%C3%A7%C3%A3o)_ e seus protocolos quando foi explicado sobre o serviço de _[Load Balancing](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-3/3-5_fundamentos-load-balancing.md)_. Visto isto, dizemos então que o _[WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm)_ é um _["Firewall de Camada 7"](https://pt.wikipedia.org/wiki/Web_Application_Firewall)_ ou um _["Firewall de Aplicação"](https://pt.wikipedia.org/wiki/Web_Application_Firewall)_, pois ele ajuda a proteger aplicações web, filtrando e monitorando o tráfego _[HTTP](https://pt.wikipedia.org/wiki/Hypertext_Transfer_Protocol)_ e _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_ usados por sua aplicação. 

Com a implementação do _[Serviço WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm)_ à frente de uma aplicação web, é possível impedir diversos ataques como _[cross-site request forgery](https://pt.wikipedia.org/wiki/Cross-site_request_forgery)_, _[cross-site scripting (XSS)](https://pt.wikipedia.org/wiki/Cross-site_scripting)_, _[file inclusion](https://en.wikipedia.org/wiki/File_inclusion_vulnerability)_, _[SQL injection](https://pt.wikipedia.org/wiki/Inje%C3%A7%C3%A3o_de_SQL)_ e outras vulnerabilidades definidas pelo _[OWASP](https://pt.wikipedia.org/wiki/OWASP)_ além de detectar, bloquear ou permitir tráfego vindo de _[bots](https://pt.wikipedia.org/wiki/Bot)_.

O _[OWASP (Open Web Application Security Project)](https://pt.wikipedia.org/wiki/OWASP)_ ou _Projeto Aberto de Segurança em Aplicações Web_, é uma fundação sem fins lucrativos dedicada a melhorar a segurança do software. Ele cria e disponibiliza de forma gratuita artigos, metodologias, documentação, ferramentas e tecnologias no campo da segurança para aplicações. 

Há também o _[OWASP Top 10](https://owasp.org/www-project-top-ten/)_ que é um documento online que fornece classificação e orientação de remediação, para os dez principais riscos de segurança em aplicações Web. Seu objetivo é oferecer aos desenvolvedores e profissionais de segurança, uma visão dos riscos de segurança mais prevalentes.

### __Criando uma Política WAF__

O _[Serviço WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm)_ é um serviço já existente e disponível globalmente, sem a necessidade de realizar provisionamento da sua infraestrutura. Para começar a usar, cria-se primeiramente uma _[Política WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Tasks/managingwaf.htm)_. Basicamente esta incluí o nome do seu _[domínio DNS](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio) principal_ e o _[servidor de origem](https://docs.oracle.com/pt-br/iaas/Content/WAF/Tasks/originmanagement.htm)_ no qual reside sua aplicação que você quer proteger contra _[ciberataques](https://pt.wikipedia.org/wiki/Ciberataque)_. Uma _[origem](https://docs.oracle.com/pt-br/iaas/Content/WAF/Tasks/originmanagement.htm)_ pode ser um endereço IP público de um _[balanceador de carga (LBaaS)](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-3/3-5_fundamentos-load-balancing.md)_ ou qualquer outro _endpoint_.

A partir de um _[domínio DNS](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio) principal_, pode-se especificar um ou mais _subdomínios_ deste _[domínio](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio)_ para _proteção_. O nome do _[domínio](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio)_ deve ser diferente das _[origens](https://docs.oracle.com/pt-br/iaas/Content/WAF/Tasks/originmanagement.htm)_ especificadas, e uma _[origem](https://docs.oracle.com/pt-br/iaas/Content/WAF/Tasks/originmanagement.htm)_ deve ser definida para que se possa principalmente, configurar as _[regras de proteção](https://docs.oracle.com/pt-br/iaas/Content/WAF/Tasks/wafprotectionrules.htm)_.

Lembrando que o _[Serviço WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm)_ só consegue _proteger_ aplicações que utilizem os protocolos _[HTTP](https://pt.wikipedia.org/wiki/Hypertext_Transfer_Protocol)_ e/ou _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_, e é limitado por padrão a _50 políticas_ por tenant. É possível solicitar _[aumento](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/servicelimits.htm#Requesti)_ destes limites, caso necessário.

Vamos começar criando uma _[política](https://docs.oracle.com/pt-br/iaas/Content/WAF/Tasks/managingwaf.htm)_ para proteger o _[domínio](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio)_ _"ocibook.com.br"_ e suas aplicações. Por enquanto, temos somente a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_ disponível e publicada em _"wordpress.ocibook.com.br"_.

```
darmbrust@hoodwink:~$ oci waas waas-policy create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --display-name "waf-policy_ocibook-com-br" \
> --domain "ocibook.com.br" \
> --additional-domains '["wordpress.ocibook.com.br"]' \
> --origins '{"wordpress_origin":{"uri": "lb-1.ocibook.com.br", "httpPort":80}}' \
> --waf-config '{"origin": "wordpress_origin"}'
{
  "etag": "W/\"2021-09-27T16:41:24.513Z\"",
  "opc-work-request-id": "ocid1.waasworkrequest.oc1..aaaaaaaafglvy67fvrsgl6hhsot4pma6vyxj2vp57ulp6tgn5vt6bp5622qq"
}
```

>_**__NOTA:__** O progresso de criação (work request) do [WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm) pode ser consultado pelo comando "oci waas work-request get --work-request-id \<id\>"._

Depois de alguns minutos, já é possível ver a _[política](https://docs.oracle.com/pt-br/iaas/Content/WAF/Tasks/managingwaf.htm)_ criada:

```
darmbrust@hoodwink:~$ oci waas waas-policy list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --display-name "waf-policy_ocibook-com-br"
{
  "data": [
    {
      "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
      "defined-tags": {
        "Oracle-Tags": {
          "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
          "CreatedOn": "2021-09-27T16:41:23.621Z"
        }
      },
      "display-name": "waf-policy_ocibook-com-br",
      "domain": "ocibook.com.br",
      "freeform-tags": null,
      "id": "ocid1.waaspolicy.oc1..aaaaaaaa7wiktkcmtupkhosmngsmqums6i2whpwl5oq4634ofeul5nvit7sq",
      "lifecycle-state": "ACTIVE",
      "time-created": "2021-09-27T16:41:24.514000+00:00"
    }
  ]
}
```

### __Utilizando o WAF na aplicação Wordpress__

Há algumas etapas a cumprir antes de aplicarmos _proteção_ ao _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_.

Após a _[política WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Tasks/managingwaf.htm)_ ser criada, ela disponibiliza um _CNAME_:

```
darmbrust@hoodwink:~$ oci waas waas-policy get \
> --waas-policy-id "ocid1.waaspolicy.oc1..aaaaaaaa7wiktkcmtupkhosmngsmqums6i2whpwl5oq4634ofeul5nvit7sq" | grep cname | cut -f2 -d':' | tr -d '", '
ocibook-com-br.o.waas.oci.oraclecloud.net
```

Irei utilizar este _nome (CNAME)_ que foi disponibilizado pelo _[WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm)_ como valor para o nome _"wordpress.ocibook.com.br"_, que criamos no capítulo passado. 

Sabemos que até agora, toda vez que um usuário for acessar a aplicação, o nome _"wordpress.ocibook.com.br"_ é _[resolvido](https://en.wikipedia.org/wiki/Domain_Name_System#DNS_resolvers)_ pelo DNS para o nome _"lb-1.ocibook.com.br"_, que por sua vez _[resolve](https://en.wikipedia.org/wiki/Domain_Name_System#DNS_resolvers)_ para o endereço IP do _[balancedor de carga](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_ _152.70.221.188_.

A ideia é que o nome _"wordpress.ocibook.com.br"_ _[resolva](https://en.wikipedia.org/wiki/Domain_Name_System#DNS_resolvers)_ para _CNAME "ocibook-com-br.o.waas.oci.oraclecloud.net"_ que foi disponibilizado pelo _[WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm)_.

Primeiramente, irei excluir o registro para o nome _"wordpress.ocibook.com.br"_:

```
darmbrust@hoodwink:~$ oci dns record domain delete \
> --zone-name-or-id "ocibook.com.br" \
> --domain "wordpress.ocibook.com.br"
Are you sure you want to delete this resource? [y/N]: y
```

Feito isto, irei inserir um novo _CNAME_ para que o tráfego dos usuários possam passar pelo _[WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm)_:

```
darmbrust@hoodwink:~$ oci dns record domain patch \
> --zone-name-or-id "ocibook.com.br" \
> --domain "wordpress.ocibook.com.br" \
> --scope "GLOBAL" \
> --items '[{"domain":"wordpress.ocibook.com.br", "rdata": "ocibook-com-br.o.waas.oci.oraclecloud.net", "rtype": "CNAME", "ttl": 3600}]'
{
  "data": {
    "items": [
      {
        "domain": "wordpress.ocibook.com.br",
        "is-protected": false,
        "rdata": "ocibook-com-br.o.waas.oci.oraclecloud.net.",
        "record-hash": "bf36492cdef44548e5548a5c03e2dd92",
        "rrset-version": "10",
        "rtype": "CNAME",
        "ttl": 3600
      }
    ]
  },
  "etag": "\"10ocid1.dns-zone.oc1..3b872f6da34a452ebd1c36678002acc3#application/json\"",
  "opc-total-items": "1"
}
```

Após esta alteração, é possível verificar que o nome _"wordpress.ocibook.com.br"_ já resolve para o _CNAME_ do _[WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm)_:

```
darmbrust@hoodwink:~$ nslookup wordpress.ocibook.com.br
Server:         192.168.88.1
Address:        192.168.88.1#53

Non-authoritative answer:
wordpress.ocibook.com.br        canonical name = ocibook-com-br.o.waas.oci.oraclecloud.net.
ocibook-com-br.o.waas.oci.oraclecloud.net       canonical name = tm.inregion.waas.oci.oraclecloud.net.
tm.inregion.waas.oci.oraclecloud.net    canonical name = sa-brazil.inregion.waas.oci.oraclecloud.net.
Name:   sa-brazil.inregion.waas.oci.oraclecloud.net
Address: 192.29.143.64
Name:   sa-brazil.inregion.waas.oci.oraclecloud.net
Address: 192.29.139.253
Name:   sa-brazil.inregion.waas.oci.oraclecloud.net
Address: 192.29.139.68
```

O outro detalhe importante, é permitir tráfego de rede ao _[balancedor de carga](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_ do _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_, somente das redes que fazem parte do _[Serviço WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm)_.

Para exibir as redes do _[Serviço WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm)_, usamos o comando abaixo:

```
darmbrust@hoodwink:~$ oci waas edge-subnet list --query 'data[].cidr'
[
  "138.1.112.0/20",
  "192.29.140.0/22",
  "130.35.228.0/22",
  "129.148.156.0/22",
  "192.157.18.0/24",
  "192.157.19.0/24",
  "205.147.88.0/21",
  "192.69.118.0/23",
  "198.181.48.0/21",
  "199.195.6.0/23"
]
WARNING: This operation supports pagination and not all resources were returned.  Re-run using the --all option to auto paginate and list all resources.
```

>_**__NOTA:__** Utilize a opção --all ao comando acima para exibir todas as redes. Foi poupado espaço por aqui._

Irei permitir somente tráfego dessas redes, inserindo uma a uma, na _[Security List](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/securitylists.htm)_ do _[balancedor de carga](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_ do _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_.

Primeiro, irei obter o correto OCID da _[Security List](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/securitylists.htm)_:

```
darmbrust@hoodwink:~$ oci network security-list list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --display-name "secl-1_subnpub_vcn-prd" \
> --query 'data[].id'
[
  "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaaggezvwdk66j5xq7fesq27z3xohmwsu4bluf7m2rrr7taa6fmdwxq"
]
```

Logo após, vou remover toda regra existente de _entrada (INGRESS)_:

```
darmbrust@hoodwink:~$ oci network security-list update \
> --security-list-id "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaaggezvwdk66j5xq7fesq27z3xohmwsu4bluf7m2rrr7taa6fmdwxq" \
> --ingress-security-rules '[]' \
> --force
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-09-07T22:23:53.782Z"
      }
    },
    "display-name": "secl-1_subnpub_vcn-prd",
    "egress-security-rules": [
      {
        "description": null,
        "destination": "0.0.0.0/0",
        "destination-type": "CIDR_BLOCK",
        "icmp-options": null,
        "is-stateless": false,
        "protocol": "all",
        "tcp-options": null,
        "udp-options": null
      }
    ],
    "freeform-tags": {},
    "id": "ocid1.securitylist.oc1.sa-saopaulo-1.aaaaaaaaggezvwdk66j5xq7fesq27z3xohmwsu4bluf7m2rrr7taa6fmdwxq",
    "ingress-security-rules": [],
    "lifecycle-state": "AVAILABLE",
    "time-created": "2021-09-07T22:23:53.875000+00:00",
    "vcn-id": "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahcglxkaabicl4jiikcavz2h2nvazibxp4rdiwziqsce4h5wksz2a"
  },
  "etag": "bcf611f5"
}
```