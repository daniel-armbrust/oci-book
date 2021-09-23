# Capítulo 3: Primeira aplicação no OCI

## 3.5 - MySQL: Banco de Dados do Wordpress

### __Visão Geral__

O _[Banco de Dados MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ é um serviço presente no _[OCI](https://www.oracle.com/cloud/)_ totalmente gerenciado, e suportado pela equipe _[MySQL da Oracle](https://www.oracle.com/mysql/)_.

Neste capítulo, irei apresentar o básico sobre o _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ para que a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_ funcione. Existe um capítulo mais completo sobre o tema que contém questões mais detalhadas e completas. Sugiro sua consulta caso necessite conhecer mais detalhes.

Vamos ao básico.

### __Criando um Banco de Dados MySQL__

Existem diversas vantagens ao se utilizar o _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ como serviço, começando pelo provisionamento automático das instâncias, aplicação de patches, atualizações, facilidade para realizar backups e restaurações, fácil escalabilidade e monitoração incluída.

Vamos ao passo a passo ...

#### __Listando os shapes disponíveis__

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

#### __Listando as versões disponíveis__

```
darmbrust@hoodwink:~$ oci mysql version list \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --all \
> --output table
+----------------+--------------------------------------------------+
| version-family | versions                                         |
+----------------+--------------------------------------------------+
| 8.0            | [{'version': '8.0.26', 'description': '8.0.26'}] |
+----------------+--------------------------------------------------+
```

#### __Listando as configurações disponíveis__

As configurações são coleções de variáveis e valores que definem a operação do _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_. São análogos aos arquivos _my.ini_ ou _my.cnf_ usados em instalações locais. Para cada tipo de _[shape](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/db-systems.html#GUID-E2A83218-9700-4A49-B55D-987867D81871)_ há uma _"configuração"_ disponível para uso aplicado ao sistema como um todo e aos usuários que fazem conexão e usam o serviço.

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