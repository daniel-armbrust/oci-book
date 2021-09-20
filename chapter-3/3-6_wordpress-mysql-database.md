# Capítulo 3: Primeira aplicação no OCI

## 3.5 - Banco de Dados do Wordpress: MySQL

### __Visão Geral__

O _[Banco de Dados MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ é um serviço presente no _[OCI](https://www.oracle.com/cloud/)_ totalmente gerenciado, e suportado pela equipe _[MySQL da Oracle](https://www.oracle.com/mysql/)_.

Neste capítulo, irei apresentar o básico sobre o _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ para que a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_ funcione. Existe um capítulo mais completo sobre o tema que contém questões mais detalhadas e completas. Sugiro a consulta caso necessite conhecer mais detalhes.

Vamos ao básico.

### __Provisionamento básico do MySQL__

Existem diversas vantagens ao se utilizar o _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ como serviço. Começando pelo provisionamento automático das instâncias, aplicação de patches e atualizações, facilidade para realizar backups e restaurações, escalabilidade e monitoração incluída.

Vamos ao passo a passo ...

#### __Listando os Shapes disponíveis__

O comando abaixo lista quais os _[shapes](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/db-systems.html#GUID-E2A83218-9700-4A49-B55D-987867D81871)_ disponíveis para criarmos o _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_:

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

Por hora, vamos escolher o _[shape](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/db-systems.html#GUID-E2A83218-9700-4A49-B55D-987867D81871)_ _VM.Standard.E2._.

#### __Listando versões disponíveis__

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