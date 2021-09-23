# Capítulo 3: Primeira aplicação no OCI

## 3.5 - MySQL: Banco de Dados do Wordpress

### __Visão Geral__

O _[Banco de Dados MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ é um serviço presente no _[OCI](https://www.oracle.com/cloud/)_ totalmente gerenciado, e suportado pela equipe _[MySQL da Oracle](https://www.oracle.com/mysql/)_. 

Neste capítulo, irei apresentar o básico sobre o _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ para que a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_ funcione. Existe um capítulo mais completo sobre o tema que contém questões mais detalhadas e completas. Sugiro sua consulta caso necessite conhecer mais detalhes.

Existem diversas vantagens ao se utilizar o _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ como serviço, começando pelo provisionamento automático das instâncias, aplicação de patches, atualizações, facilidade para realizar backups e restaurações, fácil escalabilidade e monitoração incluída.

Antes de disparar a criação do _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_, irei exibir e explicar sobre algumas informações básicas necessárias para compor o comando de criação do serviço.

### __Listando os shapes disponíveis__

Começaremos listando quais os _[shapes](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/db-systems.html#GUID-E2A83218-9700-4A49-B55D-987867D81871)_ que temos disponíveis para criar o _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_.

```
darmbrust@hoodwink:~$ oci mysql shape list \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --all \
> --output table  
+----------------+-----------------------------------------------------+--------------------+--------------------------------+
| cpu-core-count | is-supported-for                                    | memory-size-in-gbs | name                           |
+----------------+-----------------------------------------------------+--------------------+--------------------------------+
| 1              | ['DBSYSTEM']                                        | 8                  | VM.Standard.E2.1               |
| 2              | ['DBSYSTEM']                                        | 16                 | VM.Standard.E2.2               |
| 4              | ['DBSYSTEM']                                        | 32                 | VM.Standard.E2.4               |
| 8              | ['DBSYSTEM']                                        | 64                 | VM.Standard.E2.8               |
| 1              | ['DBSYSTEM']                                        | 8                  | MySQL.VM.Standard.E3.1.8GB     |
| 1              | ['DBSYSTEM']                                        | 16                 | MySQL.VM.Standard.E3.1.16GB    |
| 2              | ['DBSYSTEM']                                        | 32                 | MySQL.VM.Standard.E3.2.32GB    |
| 4              | ['DBSYSTEM']                                        | 64                 | MySQL.VM.Standard.E3.4.64GB    |
| 8              | ['DBSYSTEM']                                        | 128                | MySQL.VM.Standard.E3.8.128GB   |
| 16             | ['DBSYSTEM']                                        | 256                | MySQL.VM.Standard.E3.16.256GB  |
| 24             | ['DBSYSTEM']                                        | 384                | MySQL.VM.Standard.E3.24.384GB  |
| 32             | ['DBSYSTEM']                                        | 512                | MySQL.VM.Standard.E3.32.512GB  |
| 48             | ['DBSYSTEM']                                        | 768                | MySQL.VM.Standard.E3.48.768GB  |
| 64             | ['DBSYSTEM']                                        | 1010               | MySQL.VM.Standard.E3.64.1024GB |
| 16             | ['ANALYTICSCLUSTER', 'HEATWAVECLUSTER', 'DBSYSTEM'] | 512                | MySQL.HeatWave.VM.Standard.E3  |
| 128            | ['DBSYSTEM']                                        | 2048               | MySQL.HeatWave.BM.Standard.E3  |
+----------------+-----------------------------------------------------+--------------------+--------------------------------+
```

Por hora, ficaremos com o _[shape](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/db-systems.html#GUID-E2A83218-9700-4A49-B55D-987867D81871)_ _VM.Standard.E2.2_.

### __Listando as configurações disponíveis__

As configurações são coleções de variáveis e valores que definem a operação do _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_. 

São análogos aos arquivos _my.ini_ ou _my.cnf_ usados em instalações locais. 

Para cada tipo de _[shape](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/db-systems.html#GUID-E2A83218-9700-4A49-B55D-987867D81871)_ há uma _"configuração"_ disponível para uso que é aplicado ao sistema como um todo e aos usuários que fazem conexão e usam o serviço.

Abaixo, irei listar a _"configuração"_ disponível para o _[shape](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/db-systems.html#GUID-E2A83218-9700-4A49-B55D-987867D81871)_ _VM.Standard.E2.2_. escolhido:

```
darmbrust@hoodwink:~$ oci mysql configuration list \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --query "data[?\"shape-name\"=='VM.Standard.E2.2']"
[
  {
    "compartment-id": null,
    "defined-tags": null,
    "description": "Default Standalone configuration for the VM.Standard.E2.2 MySQL Shape",
    "display-name": "VM.Standard.E2.2.Standalone",
    "freeform-tags": null,
    "id": "ocid1.mysqlconfiguration.oc1..aaaaaaaah6o6qu3gdbxnqg6aw56amnosmnaycusttaa7abyq2tdgpgubvsgj",
    "lifecycle-state": "ACTIVE",
    "shape-name": "VM.Standard.E2.2",
    "time-created": "2018-09-21T10:00:00+00:00",
    "time-updated": null,
    "type": "DEFAULT"
  }
]
```

### __Manutenção e Backup__

#### Janela de Manutenção

A _"janela de manutenção"_ é o horário que você especifica de acordo com suas necessidades, para aplicação de patches e manutenção geral do _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_. Isto é necessário para garantir o funcionamento e a disponibilidade do serviço.

Tanto patches do sistema operacional, do próprio _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ e de qualquer hardware subjacente são executados durante _"janela de manutenção"_ de forma automática. É recomendado você definir este horário, caso contrário o serviço escolherá um horário de início para você.

Essas manutenções são realizadas raramente e somente quando for absolutamente necessário. Normalmente quando há problemas de segurança ou confiabilidade.

Quando a manutenção é executada, o status do serviço _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ muda para _UPDATING_ e o banco de dados pode ficar indisponível por um curto período de tempo, até que a manutenção seja concluída.

Para a _"janela de manutenção"_, irei especificar _DOMINGO (SUNDAY)_ com início as _04:30 AM_ _[horário de Brasília](https://pt.wikipedia.org/wiki/Fusos_hor%C3%A1rios_no_Brasil#Hor%C3%A1rio_de_Bras%C3%ADlia)_ _(07:30 UTC)_.

#### Backup

O serviço _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ suporta a execução de _[Backups Automáticos](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/backing-db-system.html)_. Se você não especificar um horário de início para os backups automáticos, deverá gerenciá-los manualmente. É altamente recomendável ativar os _[backups automáticos](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/backing-db-system.html)_.  

O _[backup automático](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/backing-db-system.html)_ é definido através de um _horário de início_ e um _período de retenção_ em dias. O padrão é sete dias e uma vez definido, não é possível editar este _período de retenção_. Seu backup começa a ser processado nos 30 minutos seguintes à hora inicial definida. 

Além do _[backup automático](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/backing-db-system.html)_, você pode iniciar uma ação de _backup_ a qualquer momento.

Para os _[backup automático](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/backing-db-system.html)_ do nosso exemplo, iremos especificar o horário de início as _05:50 AM_ _[horário de Brasília](https://pt.wikipedia.org/wiki/Fusos_hor%C3%A1rios_no_Brasil#Hor%C3%A1rio_de_Bras%C3%ADlia)_ _(08:50 UTC)_.

>_**__NOTA:__** Como já foi dito, todo horário no [OCI](https://www.oracle.com/cloud/) deve ser especificado em [UTC+0](https://pt.wikipedia.org/wiki/UTC%2B0)_.

### __Criando um Banco de Dados MySQL__