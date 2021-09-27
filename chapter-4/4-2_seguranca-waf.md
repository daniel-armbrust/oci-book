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

A partir de um _[domínio DNS](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio) principal_, pode-se especificar um ou mais _subdomínios_ deste _[domínio](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio)_ para _proteção_. O nome do _[domínio](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio)_ deve ser diferente das _[origens](https://docs.oracle.com/pt-br/iaas/Content/WAF/Tasks/originmanagement.htm)_ especificadas e uma _[origem](https://docs.oracle.com/pt-br/iaas/Content/WAF/Tasks/originmanagement.htm)_ deve ser definida para que se possa configurar as _[regras de proteção](https://docs.oracle.com/pt-br/iaas/Content/WAF/Tasks/wafprotectionrules.htm)_.

Lembrando que o _[Serviço WAF](https://docs.oracle.com/pt-br/iaas/Content/WAF/Concepts/overview.htm)_ só consegue _proteger_ aplicações que utilizem os protocolos _[HTTP](https://pt.wikipedia.org/wiki/Hypertext_Transfer_Protocol)_ e/ou _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_, e é limitado por padrão a _50 políticas_ por tenant. É possível solicitar _[aumento](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/servicelimits.htm#Requesti)_ destes limites, caso necessário.

Vamos começar criando uma _[política](https://docs.oracle.com/pt-br/iaas/Content/WAF/Tasks/managingwaf.htm)_ para proteger o _[domínio](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio)_ _"ocibook.com.br"_ e suas aplicações. Por enquanto, temos somente a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_ disponível e publicada em _"wordpress.ocibook.com.br"_.

```
darmbrust@hoodwink:~$ oci waas waas-policy create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --display-name "waf-policy_wordpress" \
> --domain "ocibook.com.br" \
> --additional-domains '["wordpress.ocibook.com.br"]' \
> --origins '{"wordpress_origin": {"uri": "lb-1.ocibook.com.br", "httpPort":80}}' \
> --wait-for-state "SUCCEEDED"
Action completed. Waiting until the work request has entered state: ('SUCCEEDED',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq",
    "errors": [],
    "id": "ocid1.waasworkrequest.oc1..aaaaaaaafxs3mdownv3htrics6lyetskhk54lfswsb36nxpjsq3fxw7yjkya",
    "logs": [
      {
        "message": "Work request complete",
        "timestamp": "2021-09-27T13:41:02.508000+00:00"
      },
      {
        "message": "FinishCreateWaasPolicyOp: start",
        "timestamp": "2021-09-27T13:41:02.499000+00:00"
      },
      {
        "message": "FinishCreateWaasPolicyOp: finished (100% of request completed)",
        "timestamp": "2021-09-27T13:41:02.499000+00:00"
      },
      {
        "message": "GetOrCreateTenantOp: start",
        "timestamp": "2021-09-27T13:41:02.473000+00:00"
      },
      {
        "message": "GetOrCreateTenantOp: finished (50% of request completed)",
        "timestamp": "2021-09-27T13:41:02.473000+00:00"
      },
      {
        "message": "Starting Work Request",
        "timestamp": "2021-09-27T13:41:02.409000+00:00"
      }
    ],
    "operation-type": "CREATE_WAAS_POLICY",
    "percent-complete": 100,
    "resources": [
      {
        "action-type": "CREATED",
        "entity-type": "waas",
        "entity-uri": "/20181116/waasPolicies/ocid1.waaspolicy.oc1..aaaaaaaammvt67mdwbbaohs6smikws2j33zlypt354gj37y3zwng3h7uv6mq",
        "identifier": "ocid1.waaspolicy.oc1..aaaaaaaammvt67mdwbbaohs6smikws2j33zlypt354gj37y3zwng3h7uv6mq"
      }
    ],
    "status": "SUCCEEDED",
    "time-accepted": "2021-09-27T13:40:58.544000+00:00",
    "time-finished": "2021-09-27T13:41:02+00:00",
    "time-started": "2021-09-27T13:41:02+00:00"
  },
  "etag": "W/\"2021-09-27T13:40:58.521Z\""
}
```
