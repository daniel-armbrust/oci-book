# Capítulo 7: Banco de Dados

## 7.2 - Banco de Dados Oracle

### __Visão Geral__

O serviço de _Banco de Dados Oracle_ do _[OCI](https://www.oracle.com/cloud/)_, também conhecido como _[DBCS (Database Cloud Service)](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/databaseoverview.htm)_ ou _[DBaaS (Database as a Service)](https://en.wikipedia.org/wiki/Data_as_a_service)_, permite que você crie _Banco de Dados Oracle_ de uma maneira simples e rápida, eliminando qualquer necessidade de instalação ou configuração manual do software.

O _Banco de Dados Oracle_ criado no _[OCI](https://www.oracle.com/cloud/)_, pode ser classificado como _"cogerenciadas" (co-managed)_ ou _"autônomo"_. Vale destacar que ambos se _"encaixam"_ no modelo _[PaaS](https://pt.wikipedia.org/wiki/Plataforma_como_servi%C3%A7o)_. Ou seja, você recebe acesso total aos recursos e operações disponíveis do banco de dados, mas é a _Oracle_ quem possui e gerencia toda a sua infraestrutura.

Um ambiente _autônomo_ ou _[Autonomous Database](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/adboverview.htm#Overview_of_Autonomous_Databases)_, são ambientes já pré-configurados _(oltp ou data warehouse)_ e totalmente gerenciados. Já ambientes _cogerenciadas_, são sistemas de _Banco de Dados Oracle_ prontos para uso sobre diferentes hardwares:

- _[Máquinas Virtuais](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/overview.htm#Virtual)_
- _[Bare Metal](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/overview.htm#baremetal)_
- _[Exadata Cloud Service (ExaCS)](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/exaoverview.htm)_
- _[Exadata Cloud@Customer (ExaCC)](https://docs.oracle.com/pt-br/iaas/exadata/index.html)_

Banco de Dados Oracle criados no OCI, sobre o modelo _[PaaS](https://pt.wikipedia.org/wiki/Plataforma_como_servi%C3%A7o)_, suporta dois tipos de licença:

- **Licença incluída (License included)**
    - O custo total do serviço já inclui o licenciamento.
    
- **Bring Your Own License (BYOL)**
    - Clientes do _Oracle Database_ podem usar suas licenças existentes ao migrar seu banco de dados on-premises para a nuvem. 

Neste capítulo, irei apresentar detalhes que envolvem _Banco de Dados Oracle_ _"cogerenciados"_ em _[máquinas virtuais](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/overview.htm#Virtual)_ e _[bare metal](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/overview.htm#baremetal)_. Teremos capítulos especificos que tratam sobre _[Autonomous Database](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/adboverview.htm#Overview_of_Autonomous_Databases)_ e _[Exadata Cloud Service (ExaCS)](https://docs.oracle.com/pt-br/iaas/Content/Database/Concepts/exaoverview.htm)_.

