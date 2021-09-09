# Capítulo 4: Primeira aplicação no OCI

## 4.3 - Apresentando o Serviço Bastion

### __Visão Geral__

O _[Serviço Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_ do OCI permite você acessar de forma segura, através de sessões _[SSH](https://pt.wikipedia.org/wiki/Secure_Shell)_ e por tempo limitado, os recursos da sua infraestrutura que não possuem endereço IP público. Ele é um meio rápido e simples de implementar um acesso seguro, até seus recursos privados. Um Bastion é uma entidade lógica, gerenciada pela Oracle que ao ser provisionado, ele cria a infraestrutura de rede necessária para se conectar aos recursos existentes em uma subrede.

Através do _[Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_ você pode acessar seus recursos sem a necessidade de ter um _["jump server"](https://pt.wikipedia.org/wiki/Jump_server)_ na rede. Este pode ser usado a vontade, de acordo com os _[limites](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/servicelimits.htm)_ disponíveis no seu _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_, além de não gerar custos extras. É um serviço gratuito.

_[OCI Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_ se integra ao _[IAM (Identity and Access Management)](https://docs.oracle.com/pt-br/iaas/Content/Identity/Concepts/overview.htm)_ e permite que você controle quem pode acessar o serviço ou uma sessão, e o que pode ser feito com esses recursos. 

Iremos utilizar o _[Serviço Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_, para concluír algumas tarefas necessárias diretamente no servidor que irá hospedar a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_.

Veja abaixo a atualização:

![alt_text](./images/servico-bastion-wordpress.jpg  "Serviço Bastion + Wordpress")

Para termos êxito no acesso a instância privada da aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_, precisamos concluír o "passo a passo" abaixo:

- Habilitar o _[plugin Bastion](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm)_ através do _[Oracle Cloud Agent (OCA)](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm)_ em execução na instância _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_.
- Criar um _[Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_ na infraestrutura.
- Criar uma _[Sessão SSH](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm#session_types)_.
- Estabelecer a comunicação SSH usando o _[Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_ até a instância _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_.

### __Plugin Bastion do Oracle Cloud Agent (OCA)__

O _[Oracle Cloud Agent (OCA)](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm)_ é um processo que vem instalado nas _[imagens de plataforma](https://docs.oracle.com/pt-br/iaas/Content/Compute/References/images.htm#OracleProvided_Images)_ e sua principal função está no gerenciamento de diversos _[plugins](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm#available-plugins)_. Estes coletam métricas de desempenho, instalam atualizações do sistema operacional, verificam vulnerabilidades de segurança, entre outras tarefas na instância de computação.

Um dos _[plugins](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm#available-plugins)_ disponíveis no _[Oracle Cloud Agent (OCA)](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm)_ é o _[plugin](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm#available-plugins)_ _**Bastion**_ que irá permitir conexões _[SSH (Secure Shell)](https://pt.wikipedia.org/wiki/Secure_Shell)_ a partir do _[Serviço Bastion](https://docs.oracle.com/pt-br/iaas/Content/Bastion/Concepts/bastionoverview.htm)_. Este vem desabilitado por padrão e precisa ser ativado antes de criarmos a sessão _[SSH](https://pt.wikipedia.org/wiki/Secure_Shell)_ até a instância.

>_**__NOTA:__** Os [plugins](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm#available-plugins) do [OCA](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm) disponíveis hoje podem ser consultados neste [link aqui](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm#available-plugins)._

Para listarmos todos os _[plugins](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm#available-plugins)_ em execução na instância, usamos o comando abaixo:

```
darmbrust@hoodwink:~$ oci instance-agent plugin list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaamcff6exkhvp4aq3ubxib2wf74v7cx22b3yj56jnfkazoissdzefq" \
> --instanceagent-id "ocid1.instance.oc1.sa-saopaulo-1.antxeljr6noke4qcf4yilvaofwpt5aiavnsx7cfev3fhp2bpc3xfcxo5k6zq" \
> --output table
+------------------------------+---------+----------------------------------+
| name                         | status  | time-last-updated-utc            |
+------------------------------+---------+----------------------------------+
| Custom Logs Monitoring       | RUNNING | 2021-09-09T18:17:11.772000+00:00 |
| Compute Instance Run Command | RUNNING | 2021-09-09T18:17:11.771000+00:00 |
| OS Management Service Agent  | RUNNING | 2021-09-09T18:17:11.770000+00:00 |
| Vulnerability Scanning       | STOPPED | 2021-09-09T18:17:11.769000+00:00 |
| Management Agent             | STOPPED | 2021-09-09T18:17:11.768000+00:00 |
| Block Volume Management      | STOPPED | 2021-09-09T18:17:11.768000+00:00 |
| Compute Instance Monitoring  | RUNNING | 2021-09-09T18:17:11.766000+00:00 |
| Bastion                      | STOPPED | 2021-09-09T18:17:11.762000+00:00 |
+------------------------------+---------+----------------------------------+
```

Perceba que o _[plugin](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm#available-plugins)_ _**Bastion**_ não está em execução. Iremos ativá-lo com o comando abaixo:

```
darmbrust@hoodwink:~$ oci compute instance update \
> --instance-id "ocid1.instance.oc1.sa-saopaulo-1.antxeljr6noke4qcf4yilvaofwpt5aiavnsx7cfev3fhp2bpc3xfcxo5k6zq" \
> --agent-config '{"pluginsConfig": [{"name": "Bastion", "desiredState": "ENABLED"}]}'
WARNING: Updates to defined-tags and freeform-tags and agent-config and metadata and extended-metadata and shape-config and instance-options and launch-options and availability-config will replace any existing values. Are you sure you want to continue? [y/N]: y
```

Depois de alguns minutos e após confirmarmos as alteração no _[OCA](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm)_ da instância, podemos ver que o _[plugin](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm#available-plugins)_ _**Bastion**_ está ativo e em execução:

```
darmbrust@hoodwink:~$  oci instance-agent plugin list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaamcff6exkhvp4aq3ubxib2wf74v7cx22b3yj56jnfkazoissdzefq" \
> --instanceagent-id "ocid1.instance.oc1.sa-saopaulo-1.antxeljr6noke4qc7l2kyzru2c4ii7h63if4yq6idamh67eojix4vbpfv5qq" \
> --name "Bastion"
{
  "data": [
    {
      "name": "Bastion",
      "status": "RUNNING",
      "time-last-updated-utc": "2021-09-09T18:26:14.737000+00:00"
    }
  ]
}
```

>_**__NOTA:__** O _[Oracle Cloud Agent (OCA)](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm)_ é um processo "auto gerênciável". Você informa um "estado desejado para o plugin" e ele se encarrega de ativá-lo. Além disto, se sua instância puder acessar a internet, o [OCA](https://docs.oracle.com/pt-br/iaas/Content/Compute/Tasks/manage-plugins.htm) verifica periodicamente se há versões mais recentes e o atualiza_. 


### __Criando um Bastion__