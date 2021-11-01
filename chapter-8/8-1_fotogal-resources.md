# Capítulo 8: A aplicação FotoGal

## 8.1 - Recursos da Aplicação

### __Visão Geral__

A aplicação _FotoGal_ do ponto de vista de arquitetura é bem simples:

![alt_text](./images/fotogal-arch.jpg "FotoGal Arquitetura")

Ela foi desenvolvida com o objetivo de ser executada em um _[cluster Kubernetes](https://pt.wikipedia.org/wiki/Kubernetes)_. Por conta deste requisito, sua execução é feita dentro de um _[contêiner](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-2/2-6_docker-howto.md)_. A partir deste _[contêiner](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-2/2-6_docker-howto.md)_ é possível gerar uma _imagem docker_ e _"transportá-la"_ para o _[OCI](https://www.oracle.com/br/cloud/)_, para que então este seja executado no _[Serviço Container Engine para Kubernetes](https://docs.oracle.com/pt-br/iaas/Content/ContEng/Concepts/contengoverview.htm)_.

Começarei demonstrando a criação dos recursos de infraestrutura via _[OCI CLI](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-1/1-5_ocicli-cloudshell.md)_, seguindo pelos passos necessários que envolvem a construção e execução do _[contêiner](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-2/2-6_docker-howto.md)_ da aplicação.

Antes de seguir, criarei um compartimento de nome _"cmp-fotogal"_ para abrigar todos os recursos que fazem parte da aplicação:

```
darmbrust@hoodwink:~$ oci iam compartment create \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --name "cmp-fotogal" \
> --description "Recursos da aplicação FotoGal"
{
  "data": {
    "compartment-id": "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-28T23:40:09.184Z"
      }
    },
    "description": "Recursos da aplica\u00e7\u00e3o FotoGal",
    "freeform-tags": {},
    "id": "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq",
    "inactive-status": null,
    "is-accessible": true,
    "lifecycle-state": "ACTIVE",
    "name": "cmp-fotogal",
    "time-created": "2021-10-28T23:40:09.417000+00:00"
  },
  "etag": "36737a006f73bfd0acc193dc39cbb8e86de429fc"
}
```

### __Upload de imagens no Object Storage__

A aplicação _FotoGal_ utiliza o serviço _[Object Storage](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-6/6-1_intro-object-storage.md)_ para armazenar todas as _imagens_ dos usuários.

Utilizar um serviço como o _[Object Storage](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-6/6-1_intro-object-storage.md)_ para armazenar _imagens_ ou _dados não estruturados_, é uma boa escolha. Além de ser financeiramente _mais barato_ em comparação ao _[armazenamento em disco](https://docs.oracle.com/pt-br/iaas/Content/Block/Concepts/overview.htm)_, sabemos que este é um serviço _escalável_ no qual permite armazenar uma quantidade ilimitada de dados de qualquer tipo, _durável_ e extremamente confiável.

Para a aplicação _FotoGal_, foi construído uma _camada_ na _"frente"_ do _[Object Storage](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-6/6-1_intro-object-storage.md)_, que permite somente usuários _autenticados_ a realizar _[upload](https://en.wikipedia.org/wiki/Upload)_ das _imagens_ de sua escolha.

Através do comando abaixo, será criado o _[bucket](https://docs.oracle.com/pt-br/iaas/Content/Object/Tasks/managingbuckets.htm)_ _privado_ e de nome _"fotogal_bucket_images"_:

```
darmbrust@hoodwink:~$ oci os bucket create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq" \
> --name "fotogal_bucket_images" \
> --public-access-type "NoPublicAccess" \
> --storage-tier "Standard" \
> --versioning "Disabled"
{
  "data": {
    "approximate-count": null,
    "approximate-size": null,
    "auto-tiering": null,
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq",
    "created-by": "ocid1.user.oc1..aaaaaaaagpov2dclzaxb4hoyapkwnwsdcymlvsl3fgrjuhdzka34kd4fmxbq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "oracleidentitycloudservice/daniel.armbrust@algumdominio.com",
        "CreatedOn": "2021-10-28T23:45:00.417Z"
      }
    },
    "etag": "7606d054-31cf-40dd-a6c1-ed0111ca703c",
    "freeform-tags": {},
    "id": "ocid1.bucket.oc1.sa-saopaulo-1.aaaaaaaa5ccdq7qpbw3rhjsijmpc5ln6rzl25deizdmytenlhvofzipfpclq",
    "is-read-only": false,
    "kms-key-id": null,
    "metadata": {},
    "name": "fotogal_bucket_images",
    "namespace": "idreywyoj0pu",
    "object-events-enabled": false,
    "object-lifecycle-policy-etag": null,
    "public-access-type": "NoPublicAccess",
    "replication-enabled": false,
    "storage-tier": "Standard",
    "time-created": "2021-10-28T23:45:00.530000+00:00",
    "versioning": "Disabled"
  },
  "etag": "7606d054-31cf-40dd-a6c1-ed0111ca703c"
}
```

### __NoSQL como catálogo de URL__

O serviço _[NoSQL](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-7/7-6_nosql.md)_ é utilizado pela aplicação com o propósito de _catalogar_ as imagens dos usuários. Ou seja, toda vez que um usuário faz _[upload](https://en.wikipedia.org/wiki/Upload)_ de uma imagem, esta após de ser salva no _[Object Storage](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-6/6-1_intro-object-storage.md)_, será inserido um registro no _[NoSQL](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-7/7-6_nosql.md)_ que identifica que determinada imagem pertence a determinado usuário.

Estas informações são salvas na tabela _"fotogal_ntable_images"_ que será criada com o comando abaixo:

```
darmbrust@hoodwink:~$ oci nosql table create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq" \
> --name "fotogal_ntable_images" \
> --table-limits '{"maxReadUnits": 10, "maxWriteUnits": 5, "maxStorageInGBs": 1}' \
> --ddl-statement 'CREATE TABLE IF NOT EXISTS fotogal_ntable_images (
>     id INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1),
>     image_url STRING,
>     image_filename STRING,
>     image_original_filename STRING,
>     image_host_fqdn STRING,
>     image_uri STRING,
>     image_type ENUM (png, jpeg, gif),
>     user_id INTEGER,
>     created_ts INTEGER,
>     liked_list ARRAY(INTEGER),
>     disliked_list ARRAY(INTEGER),
>     main_comment STRING,
>     is_profile BOOLEAN,
>     PRIMARY KEY(id))' \
> --wait-for-state "SUCCEEDED"
Action completed. Waiting until the work request has entered state: ('SUCCEEDED',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq",
    "id": "ocid1.nosqltableworkrequest.oc1.sa-saopaulo-1.amaaaaaa6noke4qaczm6mffrmhbydqbddm2joepgsg52z2gtwoyt27dn7nba",
    "operation-type": "CREATE_TABLE",
    "percent-complete": 100.0,
    "resources": [
      {
        "action-type": "CREATED",
        "entity-type": "TABLE",
        "entity-uri": "/20190828/tables/fotogal_ntable_images?compartmentId=ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq",
        "identifier": "ocid1.nosqltable.oc1.sa-saopaulo-1.amaaaaaa6noke4qarhpsq2rcwanyzysacan4f34lwi2rz76oejsxn2jfgmra"
      }
    ],
    "status": "SUCCEEDED",
    "time-accepted": "2021-10-29T11:52:28.923000+00:00",
    "time-finished": "2021-10-29T11:52:32.574000+00:00",
    "time-started": "2021-10-29T11:52:29.119000+00:00"
  }
}
```

Para a tabela _"fotogal_ntable_images"_ serão criados dois _[índices](https://docs.oracle.com/pt-br/iaas/nosql-database/doc/using-tables-java.html#GUID-4382BC75-5448-440E-B9DF-13E6FEC764C1)_:

```
darmbrust@hoodwink:~$ oci nosql index create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq" \
> --table-name-or-id "fotogal_ntable_images" \
> --keys '[{"columnName": "user_id"}]' \
> --index-name "user_id_idx" \
> --wait-for-state "SUCCEEDED"

darmbrust@hoodwink:~$ oci nosql index create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq" \
> --table-name-or-id "fotogal_ntable_images" \
> --keys '[{"columnName": "created_ts"}]' \
> --index-name "created_ts_idx" \
> --wait-for-state "SUCCEEDED"
```

_[Índices](https://docs.oracle.com/pt-br/iaas/nosql-database/doc/using-tables-java.html#GUID-4382BC75-5448-440E-B9DF-13E6FEC764C1)_ representam uma maneira alternativa de recuperar linhas da tabela. Ao criar um _[índice](https://docs.oracle.com/pt-br/iaas/nosql-database/doc/using-tables-java.html#GUID-4382BC75-5448-440E-B9DF-13E6FEC764C1)_, você pode recuperar linhas com mais eficiência e com base em campos que não fazem parte da _[chave primária](https://pt.wikipedia.org/wiki/Chave_prim%C3%A1ria)_.

Após, serão criadas outras duas tabelas. A tabela _"fotogal_ntable_users"_ armazena os usuários da aplicação:

```
darmbrust@hoodwink:~$ oci nosql table create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq" \
> --name "fotogal_ntable_users" \
> --table-limits '{"maxReadUnits": 10, "maxWriteUnits": 5, "maxStorageInGBs": 1}' \
> --ddl-statement 'CREATE TABLE IF NOT EXISTS fotogal_ntable_users (
>     id INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1),
>     email STRING,
>     full_name STRING,
>     username STRING,
>     password STRING,
>     follow_list ARRAY(INTEGER),
>     follow_sent_list ARRAY(INTEGER),
>     follow_you_list ARRAY(INTEGER),
>     follow_received_list ARRAY(INTEGER),
>     created_ts INTEGER,
>     is_private BOOLEAN,
>     is_professional_account BOOLEAN,
>     profile_image_url STRING,
>     user_data JSON,
>     PRIMARY KEY(id, email, username))' \
> --wait-for-state "SUCCEEDED"
Action completed. Waiting until the work request has entered state: ('SUCCEEDED',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq",
    "id": "ocid1.nosqltableworkrequest.oc1.sa-saopaulo-1.amaaaaaa6noke4qa6j4uk5swvt35k5tzyn47taik234ahujh6kofv4gk7zla",
    "operation-type": "CREATE_TABLE",
    "percent-complete": 100.0,
    "resources": [
      {
        "action-type": "CREATED",
        "entity-type": "TABLE",
        "entity-uri": "/20190828/tables/fotogal_ntable_users?compartmentId=ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq",
        "identifier": "ocid1.nosqltable.oc1.sa-saopaulo-1.amaaaaaa6noke4qapqjxifq5jgdub4sqfnibp4tjjr7tnobmhttctppf2eka"
      }
    ],
    "status": "SUCCEEDED",
    "time-accepted": "2021-10-29T12:03:50.761000+00:00",
    "time-finished": "2021-10-29T12:03:54.119000+00:00",
    "time-started": "2021-10-29T12:03:50.771000+00:00"
  }
}
```

Por último, a tabela _"fotogal_ntable_authsession"_ é para controle da _[sessão web](https://en.wikipedia.org/wiki/Session_ID)_ dos usuários que foram autenticados com sucesso:

```
darmbrust@hoodwink:~$ oci nosql table create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq" \
> --name "fotogal_ntable_authsession" \
> --table-limits '{"maxReadUnits": 10, "maxWriteUnits": 5, "maxStorageInGBs": 1}' \
> --ddl-statement 'CREATE TABLE IF NOT EXISTS fotogal_ntable_authsession (
>     random_token STRING,
>     created_ts INTEGER,
>     expire_ts INTEGER,
>     user_id INTEGER,
>     PRIMARY KEY(random_token))' \
> --wait-for-state "SUCCEEDED"
Action completed. Waiting until the work request has entered state: ('SUCCEEDED',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq",
    "id": "ocid1.nosqltableworkrequest.oc1.sa-saopaulo-1.amaaaaaa6noke4qapz4kogzvky5mx2euzmti3cvtcnespwdppy4b5zweociq",
    "operation-type": "CREATE_TABLE",
    "percent-complete": 100.0,
    "resources": [
      {
        "action-type": "CREATED",
        "entity-type": "TABLE",
        "entity-uri": "/20190828/tables/fotogal_ntable_authsession?compartmentId=ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq",
        "identifier": "ocid1.nosqltable.oc1.sa-saopaulo-1.amaaaaaa6noke4qajhtd5vur4sdfathqo6f2p35q7eb3brbrbjtzoweeodma"
      }
    ],
    "status": "SUCCEEDED",
    "time-accepted": "2021-10-29T12:29:13.369000+00:00",
    "time-finished": "2021-10-29T12:29:16.780000+00:00",
    "time-started": "2021-10-29T12:29:13.379000+00:00"
  }
}
```

Esta tabela também possui um _[índice](https://docs.oracle.com/pt-br/iaas/nosql-database/doc/using-tables-java.html#GUID-4382BC75-5448-440E-B9DF-13E6FEC764C1)_ para uma melhor eficiência na recuperação dos seus dados:

```
darmbrust@hoodwink:~$  oci nosql index create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq" \
> --table-name-or-id "fotogal_ntable_authsession" \
> --keys '[{"columnName": "user_id"}]' \
> --index-name "user_id_idx" \
> --wait-for-state "SUCCEEDED"
```

Pronto! A infraestrutura para persistência dos dodos foi criada.

### __Serviço de Logging__

O _[serviço Logging](https://docs.oracle.com/pt-br/iaas/Content/Logging/home.htm)_ disponível no _[OCI](https://www.oracle.com/br/cloud/)_, possibilita armazenar de forma centralizada os _logs_ gerados pela aplicação.

Para usarmos o serviço, primeiramente devemos criar um _[grupo de logs](https://docs.oracle.com/pt-br/iaas/Content/Logging/Task/managinglogs.htm)_. Este nada mais é do que um contêiner lógico para organizar _logs_ que podem ser gerados de vários recursos diferentes.

```
darmbrust@hoodwink:~$ oci logging log-group create \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq" \
> --display-name "fotogal_loggroup" \
> --wait-for-state "SUCCEEDED"
Action completed. Waiting until the work request has entered state: ('SUCCEEDED',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq",
    "id": "ocid1.logworkrequest.oc1.sa-saopaulo-1.aaaaaaaanvzeowcll4gfldb6voj3nemfbs6u7ur6vyivsan4is4sv6snanga",
    "operation-type": "CREATE_LOG_GROUP",
    "percent-complete": 100.0,
    "resources": [
      {
        "action-type": "CREATED",
        "entity-type": "loggroup",
        "entity-uri": "/logGroups/ocid1.loggroup.oc1.sa-saopaulo-1.amaaaaaa6noke4qax3f3icuckaccm522v3qnn7d2iib3lxnegr2aanf6k5va",
        "identifier": "ocid1.loggroup.oc1.sa-saopaulo-1.amaaaaaa6noke4qax3f3icuckaccm522v3qnn7d2iib3lxnegr2aanf6k5va"
      }
    ],
    "status": "SUCCEEDED",
    "time-accepted": "2021-10-29T14:35:22.184000+00:00",
    "time-finished": "2021-10-29T14:35:22.184000+00:00",
    "time-started": "2021-10-29T14:35:22.184000+00:00"
  }
}
```

Após o _[grupo de logs](https://docs.oracle.com/pt-br/iaas/Content/Logging/Task/managinglogs.htm)_ ser criado, vamos obter o seu _OCID_:

```
darmbrust@hoodwink:~$ oci logging log-group list \
> --compartment-id "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq" \
> --all \
> --display-name "fotogal_loggroup" \
> --query 'data[].id'
[
  "ocid1.loggroup.oc1.sa-saopaulo-1.amaaaaaa6noke4qax3f3icuckaccm522v3qnn7d2iib3lxnegr2aanf6k5va"
]
```

Agora, é possível criar um _canal_ para receber _logs_:

```
darmbrust@hoodwink:~$ oci logging log create \
> --display-name "fotogal_customlog_app" \
> --log-group-id "ocid1.loggroup.oc1.sa-saopaulo-1.amaaaaaa6noke4qax3f3icuckaccm522v3qnn7d2iib3lxnegr2aanf6k5va" \
> --log-type "CUSTOM" \
> --is-enabled "true" \
> --wait-for-state "SUCCEEDED"
Action completed. Waiting until the work request has entered state: ('SUCCEEDED',)
{
  "data": {
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq",
    "id": "ocid1.logworkrequest.oc1.sa-saopaulo-1.aaaaaaaa3dt7ookm6puvgaqctenyqqnkwocxipkx7jq35qme76dl2gtivcoa",
    "operation-type": "CREATE_LOG",
    "percent-complete": 100.0,
    "resources": [
      {
        "action-type": "CREATED",
        "entity-type": "log",
        "entity-uri": "/logs/ocid1.log.oc1.sa-saopaulo-1.amaaaaaa6noke4qag4aomc72aibongjjvewvenncatpz5tivuughkjmp5mmq",
        "identifier": "ocid1.log.oc1.sa-saopaulo-1.amaaaaaa6noke4qag4aomc72aibongjjvewvenncatpz5tivuughkjmp5mmq"
      }
    ],
    "status": "SUCCEEDED",
    "time-accepted": "2021-10-29T14:44:52.205000+00:00",
    "time-finished": "2021-10-29T14:44:52.205000+00:00",
    "time-started": "2021-10-29T14:44:52.205000+00:00"
  }
}
```

### __Desenvolvimento Conteinerizado__

_Conteinerização_ é um termo usado no qual se refere a ação de _"empacotar o código de um software"_ junto com suas bibliotecas, arquivos de configuração e demais dependências, gerando assim uma _[imagem](https://docs.docker.com/language/python/build-images/)_ que pode ser implantada _(deploy)_ e executada em qualquer infraestrutura que suporte a execução de contêineres _("written once and run anywhere")_. 

Os _contêineres_ por serem portáveis e mais eficientes do que _máquinas virtuais (VMs)_, sobre a perspectiva de utilização de recursos, tornaram-se o padrão para desenvolvimento de aplicações modernas, _"nativos da nuvem"_ _[(Cloud Native)](https://en.wikipedia.org/wiki/Cloud_native_computing)_, além de trazer a tona um novo estilo arquitetural chamado de _[microsserviços](https://en.wikipedia.org/wiki/Microservices)_.

Métodos de desenvolvimentos antigos, onde o código era desenvolvido em um ambiente específico e quando era transferido para _"rodar"_ em produção por exemplo, sempre ocasionavam erros, _[bugs](https://en.wikipedia.org/wiki/Software_bug)_ e exigiam diferentes adequações. Uma das grandes vantagens no _"desenvolvimento conteinerizado"_ está na sua _portabilidade_. O _contêiner_ por ser uma unidade de software _"empacotada"_ com todas as suas dependências, permite que sua execução seja feita em diferentes infraestruturas. Eu posso desenvolver localmente na minha máquina desktop, move e executar este _contêiner_ no _[OCI](https://www.oracle.com/br/cloud/)_, por exemplo.

>_**__NOTA:__** Para saber mais sobre [Docker](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-2/2-6_docker-howto.md) e seus detalhes, consulte o capítulo [2.6 - Docker HOWTO](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-2/2-6_docker-howto.md)._

Irei apresentar como é desenvolver uma aplicação em _contêiner_ e como realizar o _deploy_ no _[Serviço Container Engine for Kubernetes](https://docs.oracle.com/pt-br/iaas/Content/ContEng/Concepts/contengoverview.htm)_ do _[OCI](https://www.oracle.com/br/cloud/)_. O intuíto não é falar da linguagem de programação _[Python](https://www.python.org/)_ ou do framework _[Flask](https://pt.wikipedia.org/wiki/Flask_(framework_web))_ que foram utilizados na programação da aplicação _FotoGal_. Mas sim, mostrar como é feito o desenvolvimento de uma aplicação que usa os serviços do _[OCI](https://www.oracle.com/br/cloud/)_.

Como todo o código já está pronto, irei primeiramente _"clonar"_ o _[repositório](https://github.com/daniel-armbrust/fotogal)_ da aplicação _FotoGal_:

```
darmbrust@hoodwink:~$ git clone https://github.com/daniel-armbrust/fotogal.git
darmbrust@hoodwink:~$ cd fotogal
darmbrust@hoodwink:~/fotogal$ ls -aFl
total 96
drwxr-xr-x  8 darmbrust darmbrust  4096 Oct 29 15:33 ./
drwxr-xr-x 12 darmbrust darmbrust  4096 Oct 28 07:56 ../
drwxr-xr-x  8 darmbrust darmbrust  4096 Oct 29 20:49 .git/
-rw-r--r--  1 darmbrust darmbrust  2726 Oct 29 15:38 .gitignore
-rw-r--r--  1 darmbrust darmbrust   723 Oct 29 15:29 Dockerfile
-rw-r--r--  1 darmbrust darmbrust 35149 Oct 24 08:06 LICENSE
-rw-r--r--  1 darmbrust darmbrust     0 Oct 29 15:28 Makefile
-rw-r--r--  1 darmbrust darmbrust 12509 Oct 29 15:55 README.md
drwxr-xr-x  4 darmbrust darmbrust  4096 Oct 29 15:37 fotogal/
drwxr-xr-x  2 darmbrust darmbrust  4096 Oct 29 15:34 gthimgs/
-rw-r--r--  1 darmbrust darmbrust   422 Oct 30 08:46 requirements.txt
drwxr-xr-x  4 darmbrust darmbrust  4096 Oct 28 08:33 terraform/
drwxr-xr-x  2 darmbrust darmbrust  4096 Oct 29 15:32 tools/
```

A aplicação necessita de dois arquivos para comunicar-se com os serviços do _[OCI](https://www.oracle.com/br/cloud/)_ através do _[SDK para Python](https://docs.oracle.com/pt-br/iaas/Content/API/SDKDocs/pythonsdk.htm)_. Estes dois arquivos, após o _"clone"_ do _[repositório](https://github.com/daniel-armbrust/fotogal)_, devem ser criados antes da construção da _[imagem](https://docs.docker.com/language/python/build-images/)_.

```
darmbrust@hoodwink:~/fotogal$ ls -laF fotogal/oci_config/
total 20
drwxr-xr-x 2 darmbrust darmbrust 4096 Oct 31 10:11 ./
drwxr-xr-x 4 darmbrust darmbrust 4096 Oct 31 10:11 ../
-rw-r--r-- 1 darmbrust darmbrust  356 Oct 31 10:08 oci.conf
-r-------- 1 darmbrust darmbrust 1679 Oct 31 10:11 oci_api_key.pem
```

O arquivo _"fotogal/oci_config/oci.conf"_ possui algumas informações básica sobre o _tenant_, _OCID_ do usuário que possui os privilégios necessários para usar os serviços que a aplicação necessita, além do compartimento onde residem esses recursos:

```
darmbrust@hoodwink:~/fotogal$ cat fotogal/oci_config/oci.conf
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaagpov2dclzaxb4hoyapkwnwsdcymlvsl3fgrjuhdzka34kd4fmxbq
fingerprint=2e:c4:dd:57:c2:df:e6:17:7f:da:e7:6c:e4:74:97:18
tenancy=ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua
region=sa-saopaulo-1
compartment=ocid1.compartment.oc1..aaaaaaaabuevop234bdezdv6wrfzw4us35yugjjqezyck23tdl2qja3c4ixq
```

Já o arquivo _"fotogal/oci_config/oci_api_key.pem"_, possui a _[chave privada](https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/apisigningkey.htm)_ do usuário no formato _[PEM](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail)_:

```
darmbrust@hoodwink:~/fotogal$ cat fotogal/oci_config/oci_api_key.pem
-----BEGIN RSA PRIVATE KEY-----
-----END RSA PRIVATE KEY-----
```

>_**__NOTA:__** Todas essas informações básicas (OCID, tenant, chaves de acesso, etc) já foram vistas no setup inicial do [OCI CLI](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-1/1-5_ocicli-cloudshell.md) que estão no capítulo [1.5 - OCI CLI e Cloud Shell](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-1/1-5_ocicli-cloudshell.md)._

Uma vez que todo o ferramental _[Docker](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-2/2-6_docker-howto.md)_ já está instalado, posso me atentar aos detalhes que envolvem a construção da _[imagem](https://docs.docker.com/language/python/build-images/)_ desta aplicação.

Antes de seguirmos, iremos verificar uma obrigatoriedade que envolve sua _TAG_. 

Toda _[imagem](https://docs.docker.com/language/python/build-images/)_ deve necessáriamente possuir uma _TAG_ que basicamente indica sua versão. Porém, uma _[imagem](https://docs.docker.com/language/python/build-images/)_ que será enviada ao _[Container Registry](https://docs.oracle.com/pt-br/iaas/Content/Registry/Concepts/registryoverview.htm)_ do _[OCI](https://www.oracle.com/br/cloud/)_, necessita seguir um padrão específico de _TAG_ conforme exibido abaixo:

```
<Chave da Região>.ocir.io/<Tenancy Namespace>/<Usuário/Repositório>/<Nome/Versão da Aplicação>
```

Para o valor _"\<Chave da Região\>"_, este nada mais é do que o identificador da _[região](https://www.oracle.com/cloud/data-regions/)_ onde esta _[imagem](https://docs.docker.com/language/python/build-images/)_ estará disponível para _deploy_.

Em nosso caso, queremos levar a _[imagem](https://docs.docker.com/language/python/build-images/)_ para a _[região](https://www.oracle.com/cloud/data-regions/)_ de São Paulo. Para obter sua chave, usamos o comando abaixo:

```
darmbrust@hoodwink:~/fotogal$ oci iam region-subscription list \
> --all \
> --query "data[?\"region-name\"=='sa-saopaulo-1']" \
> --output table
+----------------+------------+---------------+--------+
| is-home-region | region-key | region-name   | status |
+----------------+------------+---------------+--------+
| True           | GRU        | sa-saopaulo-1 | READY  |
+----------------+------------+---------------+--------+
```

>_**__NOTA:__** As [regiões](https://www.oracle.com/cloud/data-regions/) e URLs onde o serviço [Container Registry](https://docs.oracle.com/pt-br/iaas/Content/Registry/Concepts/registryoverview.htm) encontra-se disponível, podem ser visualizadas neste [link aqui](https://docs.oracle.com/pt-br/iaas/Content/Registry/Concepts/registryprerequisites.htm#regional-availability)._

O próximo valor _"\<Tenancy Namespace\>"_ está ligado ao serviço _[Object Storage](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-6/6-1_intro-object-storage.md)_. Todo _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_ recebe um valor único, exclusivo e não editável de _[namespace](https://docs.oracle.com/pt-br/iaas/Content/Object/Tasks/understandingnamespaces.htm)_. Este serve como o _"contêiner pai"_ (uma espécie de pasta raíz) para todos os buckets e objetos que forem criados, inclusive a _[imagem Docker](https://docs.docker.com/language/python/build-images/)_ que criaremos aqui.

Para obtermos o valor _[namespace](https://docs.oracle.com/pt-br/iaas/Content/Object/Tasks/understandingnamespaces.htm)_ do nosso _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_, usamos o comando abaixo:

```
darmbrust@hoodwink:~/fotogal$ oci os ns get
{
  "data": "iwreyhyoj0puy"
}
```

Os próximos dois valores _"\<Usuário/Repositório\>"_ e  _"\<Nome/Versão da Aplicação\>"_, são o nome do meu usuário criado pelo _[Serviço IAM](https://docs.oracle.com/pt-br/iaas/Content/Identity/Concepts/overview.htm)_ e uma string simples que indica o nome da aplicação e sua versão.

Juntando todas essas informações, temos:

```
gru.ocir.io/iwreyhyoj0puy/daniel.armbrust/fotogal:1.0.0
```

Para a _[imagem](https://docs.docker.com/language/python/build-images/)_, os dois arquivos abaixo merecem destaque e serão usados na sua construção:

- **Dockerfile**
    - Arquivo no qual contém a sequência dos comandos usados na construção da _[imagem](https://docs.docker.com/language/python/build-images/)_.
    
- **requirements.txt**
    - Contém todas as dependências _[Python](https://www.python.org/)_ que são necessários para execução da aplicação. Cada pacote listado neste arquivo será instalado pela ferramenta _[pip](https://pt.wikipedia.org/wiki/Pip_(gerenciador_de_pacotes))_.

Usamos o comando _"docker build"_, informando a _TAG_ que compomos como valor do parâmetro _"-t"_. Lembrando que estamos no diretório _"raíz"_ da aplicação, onde residem os arquivos _Dockerfile_ e _requirements.txt_, por isto temos um _ponto final_ após a _TAG_:

```
darmbrust@hoodwink:~/fotogal$ docker build -t gru.ocir.io/iwreyhyoj0puy/daniel.armbrust/fotogal:1.0.0 .
[+] Building 130.7s (12/12) FINISHED
 => [internal] load build definition from Dockerfile                                                                                                                    0.0s
 => => transferring dockerfile: 38B                                                                                                                                     0.0s
 => [internal] load .dockerignore                                                                                                                                       0.0s
 => => transferring context: 2B                                                                                                                                         0.0s
 => [internal] load metadata for docker.io/library/python:3.8-alpine                                                                                                    2.1s
 => [internal] load build context                                                                                                                                       0.0s
 => => transferring context: 6.62kB                                                                                                                                     0.0s
 => [1/7] FROM docker.io/library/python:3.8-alpine@sha256:661ad93defe82c3255b59bab8e16dd6c73e5c98411f97272b1780fac0406344c                                              0.0s
 => CACHED [2/7] WORKDIR /opt/fotogal                                                                                                                                   0.0s
 => [3/7] RUN apk update --no-cache &&     apk add --no-cache --virtual .build-deps gcc python3-dev libc-dev libffi-dev openssl-dev                                     8.5s
 => [4/7] COPY requirements.txt ./                                                                                                                                      0.3s
 => [5/7] RUN python -m pip install --no-cache-dir --upgrade pip &&     pip install --no-cache-dir -r requirements.txt &&     apk del .build-deps && rm -rf /var/cach  70.8s
 => [6/7] RUN adduser -D -H -h /opt/fotogal fotogal                                                                                                                     1.3s
 => [7/7] COPY --chown=fotogal:fotogal ./fotogal /opt/fotogal/                                                                                                          0.3s
 => exporting to image                                                                                                                                                  2.0s
 => => exporting layers                                                                                                                                                 1.9s
 => => writing image sha256:bfcccb7a760222a36407c68cc8a4cdea2a634802fceb2a6d7749bbf3a7a16e04                                                                            0.0s
 => => naming to gru.ocir.io/iwreyhyoj0puy/daniel.armbrust/fotogal:1.0.0
```

Pelo comando _"docker images"_ é possível ver a _[imagem](https://docs.docker.com/language/python/build-images/)_ que acabamos de criar:

```
darmbrust@hoodwink:~/fotogal$ docker images
REPOSITORY                                         TAG       IMAGE ID       CREATED          SIZE
gru.ocir.io/iwreyhyoj0puy/daniel.armbrust/fotogal  1.0.0     bfcccb7a7602   13 minutes ago   420MB
```

### __Enviando a imagem ao Container Registry__

Para poder enviar e baixar _[imagens Docker](https://docs.docker.com/language/python/build-images/)_ do _[Serviço Container Registry](https://docs.oracle.com/pt-br/iaas/Content/Registry/Concepts/registryoverview.htm)_, primeiramente temos que criar um _[Token de Autenticação](https://docs.oracle.com/pt-br/iaas/Content/Registry/Tasks/registrygettingauthtoken.htm)_.

Para criar o _[Token de Autenticação](https://docs.oracle.com/pt-br/iaas/Content/Registry/Tasks/registrygettingauthtoken.htm)_ específico do meu usuário, uso o comando abaixo:

```
darmbrust@hoodwink:~$ oci iam auth-token create \
> --user-id "ocid1.user.oc1..aaaaaaaagpov2dclzaxb4hoyapkwnwsdcymlvsl3fgrjuhdzka34kd4fmxbq" \
> --description "Auth Token para OCI Registry"
{
  "data": {
    "description": "Auth Token para OCI Registry",
    "id": "ocid1.credential.oc1..aaaaasaaau4z47bnsiirxmpii3lm44dwh3hzbgjzg43all5khy6twl2f7qpa",
    "inactive-status": null,
    "lifecycle-state": "ACTIVE",
    "time-created": "2021-11-01T13:53:49.220000+00:00",
    "time-expires": null,
    "token": "VwP}p7YcjZ213-LaPsSPmMaUOot",
    "user-id": "ocid1.user.oc1..aaaaaaaagpov2dclzaxb4hoyapkwnwsdcymlvsl3fgrjuhdzka34kd4fmxbq"
  },
  "etag": "d35c84478c65e6af000d637b007b8b461f42805d"
}
```

Lembrando que o valor do _"token"_ não pode ser recuperado depois que foi criado. Caso você perca este valor, você terá que gerar outro _[Token de Autenticação](https://docs.oracle.com/pt-br/iaas/Content/Registry/Tasks/registrygettingauthtoken.htm)_.

Com o _[Token de Autenticação](https://docs.oracle.com/pt-br/iaas/Content/Registry/Tasks/registrygettingauthtoken.htm)_ em mãos, podemos efetuar um login no _[Container Registry](https://docs.oracle.com/pt-br/iaas/Content/Registry/Concepts/registryoverview.htm)_ do _[OCI](https://www.oracle.com/br/cloud/)_ para realizarmos o _[upload](https://en.wikipedia.org/wiki/Upload)_ da _[imagem](https://docs.docker.com/language/python/build-images/)_ que criamos.

```
darmbrust@hoodwink:~$ docker login -u iwreyhyoj0puy/oracleidentitycloudservice/daniel.armbrust@algumdominio.com gru.ocir.io
Password:
Login Succeeded
``` 

>_**__NOTA:__** Para a [região](https://www.oracle.com/cloud/data-regions/) de São Paulo o [Container Registry](https://docs.oracle.com/pt-br/iaas/Content/Registry/Concepts/registryoverview.htm) é acessado pelo endereço "gru.ocir.io". Para outras [regiões](https://www.oracle.com/cloud/data-regions/) verifique os endereços neste [link aqui](https://docs.oracle.com/pt-br/iaas/Content/Registry/Concepts/registryprerequisites.htm#regional-availability)._

Agora basta realizar _[upload](https://en.wikipedia.org/wiki/Upload)_ especificando o nome da _[imagem](https://docs.docker.com/language/python/build-images/)_:

```
darmbrust@hoodwink:~$ docker push gru.ocir.io/iwreyhyoj0puy/daniel.armbrust/fotogal:1.0.0
The push refers to repository [gru.ocir.io/iwreyhyoj0puy/daniel.armbrust/fotogal]
1ef465084843: Pushed
5aa8c349681f: Pushed
82c520e19575: Pushed
ae07538520ed: Pushed
8f0c06de869c: Pushed
4ec58225ca47: Pushed
902e02e83d8d: Pushed
2ff754c2db47: Pushed
2308a80e3ab3: Pushed
a2f23be74558: Pushed
e2eb06d8af82: Pushed
1.0.0: digest: sha256:b19aa75b1f0289061a77e011eebc4fcfe85068fe72dbacbbd493cd508dd2bd73 size: 2625
```

Pronto! É possível verificar que a _[imagem](https://docs.docker.com/language/python/build-images/)_ que subimos já encontra-se no _[Container Registry](https://docs.oracle.com/pt-br/iaas/Content/Registry/Concepts/registryoverview.htm)_ do _[OCI](https://www.oracle.com/br/cloud/)_:

```
darmbrust@hoodwink:~$ oci artifacts container image list \
> --compartment-id "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua" \
> --all \
> --compartment-id-in-subtree "true" \
> --display-name "daniel.armbrust/fotogal:1.0.0"
{
  "data": {
    "items": [
      {
        "compartment-id": "ocid1.tenancy.oc1..aaaaaaaavv2qh5asjdcoufmb6fzpnrfqgjxxdzlvjrgkrkytnyyz6zgvjnua",
        "digest": "sha256:b19aa75b1f0289061a77e011eebc4fcfe85068fe72dbacbbd493cd508dd2bd73",
        "display-name": "daniel.armbrust/fotogal:1.0.0",
        "id": "ocid1.containerimage.oc1.sa-saopaulo-1.0.idreywyoj0pu.aaaaaaaa5fjxtie3ufpmu3pxpwfld4pi4elz2cjsk2l3r20pufj5p2m4rstq",
        "lifecycle-state": "AVAILABLE",
        "repository-id": "ocid1.containerrepo.oc1.sa-saopaulo-1.0.idreywyoj0pu.aaaaaaaag6mljpekwtey3w4bxdjdfno2bwchnobw2a5ulcpiweutsksjeweq",
        "repository-name": "daniel.armbrust/fotogal",
        "time-created": "2021-11-01T14:28:01.136000+00:00",
        "version": "1.0.0"
      }
    ],
    "remaining-items-count": 0
  }
}
```

Para se deslogar do _[Container Registry](https://docs.oracle.com/pt-br/iaas/Content/Registry/Concepts/registryoverview.htm)_, usamos o comando abaixo:

```
darmbrust@hoodwink:~$ docker logout
Removing login credentials for https://index.docker.io/v1/
```

### __Conclusão__

Este capítulo apresentou os passos básicos envolvidos na criação da aplicação _FotoGal_. Agora que temos a _[imagem](https://docs.docker.com/language/python/build-images/)_ da aplicação já disponível no _[Container Registry](https://docs.oracle.com/pt-br/iaas/Content/Registry/Concepts/registryoverview.htm)_ do _[OCI](https://www.oracle.com/br/cloud/)_, no próximo capítulo iremos realizar seu _deploy_ no _[Serviço de Container Engine para Kubernetes](https://docs.oracle.com/pt-br/iaas/Content/ContEng/Concepts/contengoverview.htm)_, que é popularmente chamado também de _[OKE](https://docs.oracle.com/pt-br/iaas/Content/ContEng/Concepts/contengoverview.htm)_.