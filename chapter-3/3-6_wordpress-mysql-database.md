# Capítulo 3: Primeira aplicação no OCI

## 3.6 - MySQL: Banco de Dados do Wordpress

### __Visão Geral__

O _[Banco de Dados MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ é um serviço presente no _[OCI](https://www.oracle.com/cloud/)_ totalmente gerenciado, e suportado pela equipe _[MySQL da Oracle](https://www.oracle.com/mysql/)_. 

Neste capítulo, irei apresentar o básico sobre o _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ para que a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_ funcione. Existe um capítulo mais completo sobre o tema que contém questões mais detalhadas e completas. Sugiro sua consulta caso necessite conhecer mais detalhes.

Existem diversas vantagens ao se utilizar o _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ como serviço, começando pelo provisionamento automático das instâncias, aplicação de patches, atualizações, facilidade para realizar backups, restaurações e monitoração incluída.

Antes de disparar a criação do _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_, irei exibir e explicar sobre algumas informações básicas necessárias para compor todo o comando de criação do serviço.

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

Por hora, ficaremos com o _[shape](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/db-systems.html#GUID-E2A83218-9700-4A49-B55D-987867D81871)_ _MySQL.VM.Standard.E3.1.8GB_ que é equipado com _1 vCPU_ e _8 GB de RAM_.

### __Listando as configurações disponíveis__

As configurações são coleções de variáveis e valores que definem a operação do _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_. 

São análogos aos arquivos _my.ini_ ou _my.cnf_ usados em instalações locais. 

Para cada tipo de _[shape](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/db-systems.html#GUID-E2A83218-9700-4A49-B55D-987867D81871)_ há uma _"configuração"_ disponível para uso que é aplicado ao sistema como um todo, e aos usuários que fazem conexão e usam o serviço.

Abaixo, irei listar as _"configurações"_ disponíveis para o _[shape](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/db-systems.html#GUID-E2A83218-9700-4A49-B55D-987867D81871)_ _MySQL.VM.Standard.E3.1.8GB_:

```
darmbrust@hoodwink:~$ oci mysql configuration list \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --query "data[?\"shape-name\"=='MySQL.VM.Standard.E3.1.8GB']"
[
  {
    "compartment-id": null,
    "defined-tags": null,
    "description": "Default Standalone configuration for the MySQL.VM.Standard.E3.1.8GB MySQL Shape",
    "display-name": "MySQL.VM.Standard.E3.1.8GB.Standalone",
    "freeform-tags": null,
    "id": "ocid1.mysqlconfiguration.oc1..aaaaaaaalwzc2a22xqm56fwjwfymixnulmbq3v77p5v4lcbb6qhkftxf2trq",
    "lifecycle-state": "ACTIVE",
    "shape-name": "MySQL.VM.Standard.E3.1.8GB",
    "time-created": "2018-09-21T10:00:00+00:00",
    "time-updated": null,
    "type": "DEFAULT"
  },
  {
    "compartment-id": null,
    "defined-tags": null,
    "description": "Default HA configuration for the MySQL.VM.Standard.E3.1.8GB MySQL Shape",
    "display-name": "MySQL.VM.Standard.E3.1.8GB.HA",
    "freeform-tags": null,
    "id": "ocid1.mysqlconfiguration.oc1..aaaaaaaantprksu6phqfgr5xvyut46wdfesdszonbclybfwvahgysfjbrb4q",
    "lifecycle-state": "ACTIVE",
    "shape-name": "MySQL.VM.Standard.E3.1.8GB",
    "time-created": "2018-09-21T10:00:00+00:00",
    "time-updated": null,
    "type": "DEFAULT"
  }
]
```

Perceba que há duas _"configurações"_ para o _[shape](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/db-systems.html#GUID-E2A83218-9700-4A49-B55D-987867D81871)_ escolhido. Usaremos a configuração _MySQL.VM.Standard.E3.1.8GB.HA_ no qual especifica _"Alta Disponibilidade"_, criando três instâncias, uma principal e duas secundárias do _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_.

### __Manutenção e Backup__

#### Janela de Manutenção

A _"janela de manutenção"_ é o horário que você especifica de acordo com suas necessidades, para aplicação de patches e manutenção geral do _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_. A definição da _"janela"_ é necessária, para garantir o funcionamento e a disponibilidade do serviço.

Tanto patches do sistema operacional, do próprio _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ e de qualquer hardware subjacente, são executados durante a _"janela de manutenção"_ de forma automática. É recomendado você definir este horário, caso contrário o serviço escolherá um horário de início para você.

Essas manutenções são realizadas raramente e somente quando for absolutamente necessário, normalmente quando há problemas de segurança ou confiabilidade.

Essa é a vantagem de se utilizar uma configuração em _"Alta Disponibilidade"_. Quando existe a necessidade de executar qualquer manutenção, não há indisponibilidade do _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_. Diferente de uma configuração _"Standalone"_, quando uma manutenção é executada, o status do serviço _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ muda para _UPDATING_, e o banco de dados fica indisponível por um curto período de tempo até que a manutenção seja concluída.

Para a _"janela de manutenção"_, irei especificar _DOMINGO (SUNDAY)_ com início as _04:30 AM_ _[horário de Brasília](https://pt.wikipedia.org/wiki/Fusos_hor%C3%A1rios_no_Brasil#Hor%C3%A1rio_de_Bras%C3%ADlia)_ _(07:30 UTC)_.

#### Backup

O serviço _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ suporta a execução de _[Backups Automáticos](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/backing-db-system.html)_. Se você não especificar um horário de início para os backups automáticos, deverá gerenciá-los manualmente. É altamente recomendável ativar os _[backups automáticos](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/backing-db-system.html)_.  

O _[backup automático](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/backing-db-system.html)_ é definido através de um _horário de início_ e um _período de retenção_ em dias. O padrão é sete dias e uma vez definido, não é possível editar este _período de retenção_. Seu backup começa a ser processado nos 30 minutos seguintes à hora inicial definida. 

Além do _[backup automático](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/backing-db-system.html)_, você pode iniciar uma ação manual de _backup_ a qualquer momento.

Para os _[backup automático](https://docs.oracle.com/pt-br/iaas/mysql-database/doc/backing-db-system.html)_ do nosso exemplo, irei especificar o horário de início as _05:50 AM_ _[horário de Brasília](https://pt.wikipedia.org/wiki/Fusos_hor%C3%A1rios_no_Brasil#Hor%C3%A1rio_de_Bras%C3%ADlia)_ _(08:50 UTC)_ e um _período de retenção_ de _10 dias_.

>_**__NOTA:__** Como já foi dito, todo horário no [OCI](https://www.oracle.com/cloud/) deve ser especificado em [UTC+0](https://pt.wikipedia.org/wiki/UTC%2B0)_.

### __Criando um Banco de Dados MySQL__

Juntando as informações, iremos criar nosso _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_ em _"Alta Disponibilidade" (--is-highly-available true)_ inicialmente com _100 GB_ disponível para armazenamento de dados _(--data-storage-size-in-gbs)_. Iremos definir também o nome do _usuário administrador (--admin-username)_ e uma senha inicial _(--admin-password)_, necessários para acesso ao banco de dados.

```
darmbrust@hoodwink:~$ oci mysql db-system create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaa6d2s5sgmxmyxu2vca3pn46y56xisijjyhdjwgqg3f6goh3obj4qq" \
> --availability-domain "ynrK:SA-SAOPAULO-1-AD-1" \
> --subnet-id "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaagyg2sk2c4j46ky3lngceejohdzswlffsavqqybepekbean3gytba" \
> --shape-name "VM.Standard.E2.2" \
> --configuration-id "ocid1.mysqlconfiguration.oc1..aaaaaaaantprksu6phqfgr5xvyut46wdfesdszonbclybfwvahgysfjbrb4q" \
> --hostname-label "mysql-wordpress" \
> --is-highly-available true \
> --admin-username admin \
> --admin-password Sup3rS3cr3t0# \
> --data-storage-size-in-gbs 100 \
> --display-name "mysql-wordpress_subnprv-db_vcn-prd" \
> --description "MySQL para o Wordpress" \
> --backup-policy '{"isEnabled": true, "retentionInDays": 10, "windowStartTime": "08:50"}' \
> --maintenance '{"window-start-time": "SUNDAY 07:30"}' 
{
  "data": {
    "analytics-cluster": null,
    "availability-domain": "ynrK:SA-SAOPAULO-1-AD-1",
    "backup-policy": {
      "defined-tags": null,
      "freeform-tags": null,
      "is-enabled": true,
      "retention-in-days": 10,
      "window-start-time": "08:50"
    },
    "channels": [],
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaa6d2s5sgmxmyxu2vca3pn46y56xisijjyhdjwgqg3f6goh3obj4qq",
    "configuration-id": "ocid1.mysqlconfiguration.oc1..aaaaaaaantprksu6phqfgr5xvyut46wdfesdszonbclybfwvahgysfjbrb4q",
    "current-placement": {
      "availability-domain": null,
      "fault-domain": null
    },
    "data-storage-size-in-gbs": 100,
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-11-30T16:04:03.187Z"
      }
    },
    "description": "MySQL para o Wordpress",
    "display-name": "mysql-wordpress_subnprv-db_vcn-prd",
    "endpoints": [],
    "fault-domain": null,
    "freeform-tags": {},
    "heat-wave-cluster": null,
    "hostname-label": "mysql-wordpress",
    "id": "ocid1.mysqldbsystem.oc1.sa-saopaulo-1.aaaaaaaagec23mzhxhwfwzduofjj346lh5qbkvncamtv6cucyt5wvs52kwzq",
    "ip-address": null,
    "is-analytics-cluster-attached": false,
    "is-heat-wave-cluster-attached": false,
    "is-highly-available": true,
    "lifecycle-details": null,
    "lifecycle-state": "CREATING",
    "maintenance": {
      "window-start-time": "SUNDAY 07:30"
    },
    "mysql-version": null,
    "port": null,
    "port-x": null,
    "shape-name": "MySQL.VM.Standard.E3.1.8GB",
    "source": null,
    "subnet-id": "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaagyg2sk2c4j46ky3lngceejohdzswlffsavqqybepekbean3gytba",
    "time-created": "2021-11-30T16:04:05.676000+00:00",
    "time-updated": "2021-11-30T16:04:05.676000+00:00"
  },
  "etag": "b00deef38bdccf19c0ebb32db2724e7c0573d7d5088ca39db650a4b063ac0844",
  "opc-work-request-id": "ocid1.mysqlworkrequest.oc1.sa-saopaulo-1.f606d2aa-bf0f-4b55-a055-22115c8dd2d6.aaaaaaaa5vofgtfiggb2fyggeh57fvuznsl63b2t5wdkf5yqvbciqtmovgqa"
}
```

Após alguns minutos, podemos ver que o serviço foi corretamente provisionado:

```
darmbrust@hoodwink:~$ oci mysql db-system get \
> --db-system-id "ocid1.mysqldbsystem.oc1.sa-saopaulo-1.aaaaaaaagec23mzhxhwfwzduofjj346lh5qbkvncamtv6cucyt5wvs52kwzq"
{
  "data": {
    "analytics-cluster": null,
    "availability-domain": "ynrK:SA-SAOPAULO-1-AD-1",
    "backup-policy": {
      "defined-tags": null,
      "freeform-tags": null,
      "is-enabled": true,
      "retention-in-days": 10,
      "window-start-time": "08:50"
    },
    "channels": [],
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaa6d2s5sgmxmyxu2vca3pn46y56xisijjyhdjwgqg3f6goh3obj4qq",
    "configuration-id": "ocid1.mysqlconfiguration.oc1..aaaaaaaantprksu6phqfgr5xvyut46wdfesdszonbclybfwvahgysfjbrb4q",
    "current-placement": {
      "availability-domain": "ynrK:SA-SAOPAULO-1-AD-1",
      "fault-domain": "FAULT-DOMAIN-3"
    },
    "data-storage-size-in-gbs": 100,
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-11-30T16:04:03.187Z"
      }
    },
    "description": "MySQL para o Wordpress",
    "display-name": "mysql-wordpress_subnprv-db_vcn-prd",
    "endpoints": [
      {
        "hostname": "mysql-wordpress.subnprvdb.vcnprd.oraclevcn.com",
        "ip-address": "10.0.20.242",
        "modes": [
          "READ",
          "WRITE"
        ],
        "port": 3306,
        "port-x": 33060,
        "status": "ACTIVE",
        "status-details": null
      }
    ],
    "fault-domain": "FAULT-DOMAIN-3",
    "freeform-tags": {},
    "heat-wave-cluster": null,
    "hostname-label": "mysql-wordpress",
    "id": "ocid1.mysqldbsystem.oc1.sa-saopaulo-1.aaaaaaaagec23mzhxhwfwzduofjj346lh5qbkvncamtv6cucyt5wvs52kwzq",
    "ip-address": "10.0.20.242",
    "is-analytics-cluster-attached": false,
    "is-heat-wave-cluster-attached": false,
    "is-highly-available": true,
    "lifecycle-details": null,
    "lifecycle-state": "ACTIVE",
    "maintenance": {
      "window-start-time": "SUNDAY 07:30"
    },
    "mysql-version": "8.0.27-u1-cloud",
    "port": 3306,
    "port-x": 33060,
    "shape-name": "MySQL.VM.Standard.E3.1.8GB",
    "source": null,
    "subnet-id": "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaagyg2sk2c4j46ky3lngceejohdzswlffsavqqybepekbean3gytba",
    "time-created": "2021-11-30T16:04:05.676000+00:00",
    "time-updated": "2021-11-30T16:18:35.229000+00:00"
  },
  "etag": "08cdef5cfdef824de611f196a4ec2d297ce4aea11d7f3c11e6c457ab93d20759--gzip"
}
```

### __Conclusão__

Aqui concluímos o provisionamento do primeiro _[MySQL](https://docs.oracle.com/pt-br/iaas/mysql-database/index.html)_. Simples e rápido.