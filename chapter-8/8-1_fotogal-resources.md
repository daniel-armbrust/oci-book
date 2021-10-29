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

O serviço _[NoSQL](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-7/7-6_nosql.md)_ é utilizado pela aplicação com o propósito de _catalogar_ as imagens dos usuários (URL da imagem salva no _[Object Storage](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-6/6-1_intro-object-storage.md)_ para ser mais exato). Ou seja, toda vez que um usuário faz _[upload](https://en.wikipedia.org/wiki/Upload)_ de uma imagem, esta após de ser salva no _[Object Storage](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-6/6-1_intro-object-storage.md)_, será inserido um registro no _[NoSQL](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-7/7-6_nosql.md)_ que identifica que determinada imagem pertence a determinado usuário.

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

Para a tabela _"fotogal_ntable_images"_ serão criado dois _[índices](https://docs.oracle.com/pt-br/iaas/nosql-database/doc/using-tables-java.html#GUID-4382BC75-5448-440E-B9DF-13E6FEC764C1)_:

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

_[Índices](https://docs.oracle.com/pt-br/iaas/nosql-database/doc/using-tables-java.html#GUID-4382BC75-5448-440E-B9DF-13E6FEC764C1)_ representam uma maneira alternativa de recuperar linhas da tabela. Ao criar um _[índice](https://docs.oracle.com/pt-br/iaas/nosql-database/doc/using-tables-java.html#GUID-4382BC75-5448-440E-B9DF-13E6FEC764C1)_, você pode recuperar linhas com mais eficiência e com base em campos que não fazem parte da _chave primária_.

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

### __Desenvolvimento Conteinerizado__

Antes de começar vamos entender o que é _"desenvolvimento conteinerizado"_. 

_Conteinerização_ é um termo usado no qual se refere a ação de _"empacotar o código de um software"_ junto com suas bibliotecas, arquivos de configuração e demais dependências, gerando assim uma _[imagem](https://docs.docker.com/language/python/build-images/)_ que pode ser implantada e executada _(deploy)_ em qualquer infraestrutura que suporte a execução de contêineres _("written once and run anywhere")_. 

_Contêineres_, por serem portáveis e mais eficientes do que _máquinas virtuais (VMs)_, sobre a perspectiva de utilização de recursos, tornaram-se o padrão para desenvolvimento de aplicações modernas e _"nativos da nuvem"_ _[(Cloud Native)](https://en.wikipedia.org/wiki/Cloud_native_computing)_.

Métodos de desenvolvimentos antigos, onde o código era desenvolvido em um ambiente específico e quando era transferido para _"rodar"_ em produção por exemplo, sempre ocasionavam erros, bugs e exigiam diferentes adequações. Uma das grandes vantagens no _"desenvolvimento conteinerizado"_ está na sua _portabilidade_. O contêiner que é usado para desenvolver, é o mesmo usado na produção. O mesmo pacote _auto-contido_ ou _[imagem](https://docs.docker.com/language/python/build-images/)_, pode ser executado em diferentes infraestruturas. Eu posso desenvolver localmente na minha máquina desktop, move e executar no _[OCI](https://www.oracle.com/br/cloud/)_, por exemplo.

>_**__NOTA:__** Para saber mais sobre [Docker](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-2/2-6_docker-howto.md) e seus detalhes, consulte o capítulo [2.6 - Docker HOWTO](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-2/2-6_docker-howto.md)._

Irei apresentar como é desenvolver uma aplicação em _contêiner_ e como realizar o _deploy_ no _[Serviço Container Engine for Kubernetes](https://docs.oracle.com/pt-br/iaas/Content/ContEng/Concepts/contengoverview.htm)_ do _[OCI](https://www.oracle.com/br/cloud/)_. O intuíto não é falar da linguagem de programação _[Python](https://www.python.org/)_ ou do framework _[Flask](https://flask.palletsprojects.com)_, e sim mostrar como é feito o desenvolvimento de uma aplicação que usa os serviços do _[OCI](https://www.oracle.com/br/cloud/)_.

Por enquanto, a aplicação _FotoGal_ utiliza os seguintes serviços do _[OCI](https://www.oracle.com/br/cloud/)_:

- [Object Storage](https://docs.oracle.com/pt-br/iaas/Content/Object/Concepts/objectstorageoverview.htm)
- [Banco de Dados NoSQL](https://docs.oracle.com/pt-br/iaas/nosql-database/index.html)
- [Log](https://docs.oracle.com/pt-br/iaas/Content/Logging/Concepts/loggingoverview.htm)
- [Container Engine for Kubernetes](https://docs.oracle.com/pt-br/iaas/Content/ContEng/Concepts/contengoverview.htm)
- [Load Balancing](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)

A tendência, com o tempo, é aumentar as funcionalidades da aplicação através da utilização de mais serviços.


```
darmbrust@sladar:~$ git clone https://github.com/daniel-armbrust/fotogal.git
darmbrust@sladar:~$ cd fotogal
darmbrust@sladar:~/fotogal$
```

```
darmbrust@sladar:~/fotogal/terraform$ terraform init
```


