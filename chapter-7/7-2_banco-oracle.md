# Capítulo 7: Banco de Dados

## 7.2 - Banco de Dados Oracle

### __Visão Geral__

O serviço de _Banco de Dados Oracle_ do _[OCI](https://www.oracle.com/cloud/)_, também conhecido como _[DBCS (Database Cloud Service)](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/databaseoverview.htm)_ ou _[DBaaS (Database as a Service)](https://en.wikipedia.org/wiki/Data_as_a_service)_, permite que você crie _Banco de Dados Oracle_ de uma maneira simples e rápida, eliminando qualquer necessidade de instalação ou configuração manual do software. Além disto, o serviço já disponibiliza de forma integrada o gerenciamento de backups, restores e aplicação de patches.

O _Banco de Dados Oracle_ criado no _[OCI](https://www.oracle.com/cloud/)_, pode ser classificado como _"cogerenciadas" (co-managed)_ ou _"autônomo"_. Vale destacar que ambos se _"encaixam"_ no modelo _[PaaS](https://pt.wikipedia.org/wiki/Plataforma_como_servi%C3%A7o)_. Ou seja, você recebe acesso total aos recursos e operações disponíveis do banco de dados, mas é a _Oracle_ quem possui e gerencia toda a sua infraestrutura.

Um ambiente _autônomo_ ou _[Autonomous Database](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/adboverview.htm#Overview_of_Autonomous_Databases)_, são ambientes já pré-configurados _(oltp ou data warehouse)_ e totalmente gerenciados. Já os ambientes _cogerenciadas_, são sistemas de _Banco de Dados Oracle_ prontos para uso sobre diferentes tipos de hardwares:

- _[Máquinas Virtuais](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/overview.htm#Virtual)_
- _[Bare Metal](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/overview.htm#baremetal)_
- _[Exadata Cloud Service (ExaCS)](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/exaoverview.htm)_
- _[Exadata Cloud@Customer (ExaCC)](https://docs.oracle.com/pt-br/iaas/exadata/index.html)_

_Banco de Dados Oracle_ criados no _[OCI](https://www.oracle.com/cloud/)_ suportam dois tipos de licença:

- **Licença incluída (License included)**
    - O custo total do serviço já inclui o licenciamento.
    
- **Bring Your Own License (BYOL)**
    - Clientes do _Oracle Database_ podem usar suas licenças existentes ao migrar seu banco de dados on-premises para a nuvem. 

Neste capítulo, irei apresentar os detalhes que envolvem _Banco de Dados Oracle_ _"cogerenciados"_ em _[máquinas virtuais](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/overview.htm#Virtual)_ e _[bare metal](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/overview.htm#baremetal)_. Teremos capítulos especificos que tratam sobre _[Autonomous Database](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/adboverview.htm#Overview_of_Autonomous_Databases)_ e _[Exadata Cloud Service (ExaCS)](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/exaoverview.htm)_.

### __Oracle DB em Máquina Virtual__

```
darmbrust@hoodwink:~$ oci db system-shape list \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --all \
> --query "data[?\"shape-family\"=='VIRTUALMACHINE'].shape" \
> --output table
+-----------------+
| Column1         |
+-----------------+
| VM.Standard2.16 |
| VM.Standard2.4  |
| VM.Standard1.4  |
| VM.Standard2.1  |
| VM.Standard1.2  |
| VM.Standard2.2  |
| VM.Standard1.8  |
| VM.Standard1.16 |
| VM.Standard1.1  |
| VM.Standard2.24 |
| VM.Standard2.8  |
+-----------------+
```