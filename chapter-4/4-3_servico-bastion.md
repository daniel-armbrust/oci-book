# Capítulo 4: Primeira aplicação no OCI

## 4.3 - Apresentando o Serviço Bastion

### __Visão Geral__

O _[Serviço Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_ do OCI permite você acessar de forma segura, através de sessões SSH e por tempo limitado, os recursos da sua infraestrutura que não possuem endereço IP público. Ele é um meio rápido e simples de implementar um acesso seguro, até seus recursos privados. Um Bastion é uma entidade lógica, gerenciada pela Oracle que ao ser provisionado, ele cria a infraestrutura de rede necessária para se conectar aos recursos existentes em uma subrede.

Através do _[Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_ você pode acessar seus recursos sem a necessidade de ter um _["jump server"](https://pt.wikipedia.org/wiki/Jump_server)_ na rede. Este pode ser usado a vontade, de acordo com os _[limites](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/servicelimits.htm)_ disponíveis no seu _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_, além de não gerar custos extras. É um serviço gratuito.

_[OCI Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_ se integra ao _[IAM (Identity and Access Management)](https://docs.oracle.com/pt-br/iaas/Content/Identity/Concepts/overview.htm)_ e permite que você controle quem pode acessar o serviço ou uma sessão, e o que pode ser feito com esses recursos. 

Iremos utilizar o _[Serviço Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_, para concluír algumas tarefas necessárias diretamente no servidor que irá hospedar a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_.

Veja abaixo a atualização:

![alt_text](./images/servico-bastion-wordpress.jpg  "Serviço Bastion + Wordpress")

Para termos êxito no acesso a instância privada da aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_, precisamos concluír o "passo a passo" abaixo:

- Habilitar o _[plug-in Bastion](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm)_ através do _[Oracle Cloud Agent](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm)_ em execução na instância _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_.
- Criar um _[Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_ na infraestrutura.
- Criar uma _[Sessão SSH](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm#session_types)_.
- Estabelecer a comunicação SSH usando o _[Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_ até a instância _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_.

### __Plug-in Bastion do Oracle Cloud Agent__

```
darmbrust@hoodwink:~$ oci instance-agent plugin list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaamcff6exkhvp4aq3ubxib2wf74v7cx22b3yj56jnfkazoissdzefq" \
> --instanceagent-id "ocid1.instance.oc1.sa-saopaulo-1.antxeljr6noke4qcf4yilvaofwpt5aiavnsx7cfev3fhp2bpc3xfcxo5k6zq" \
> --name "Bastion"
{
  "data": [
    {
      "name": "Bastion",
      "status": "STOPPED",
      "time-last-updated-utc": "2021-09-08T13:55:39.250000+00:00"
    }`
  ]
}
```

```
darmbrust@hoodwink:~$ oci compute instance update \
> --instance-id "ocid1.instance.oc1.sa-saopaulo-1.antxeljr6noke4qcf4yilvaofwpt5aiavnsx7cfev3fhp2bpc3xfcxo5k6zq" \
> --agent-config '{"pluginsConfig": [{"name": "Bastion", "desiredState": "ENABLED"}]}'
WARNING: Updates to defined-tags and freeform-tags and agent-config and metadata and extended-metadata and shape-config and instance-options and launch-options and availability-config will replace any existing values. Are you sure you want to continue? [y/N]: y

```

```
darmbrust@hoodwink:~$ oci network subnet list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaauvqvbbx3oridcm5d2ztxkftwr362u2vl5zdsayzbehzwbjs56soq" \
> --query "data[?\"display-name\"=='subnpub_vcn-prd'].id"
[
  "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaax6arj6ccrzlm7fxb4pl4ggrsgig4bwnbvtqaayosdulsyoaliuka"
]
```


