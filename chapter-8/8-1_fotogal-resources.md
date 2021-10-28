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

Para a aplicação _FotoGal_, foi construído uma _camada_ na _"frente"_ do _[Object Storage](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-6/6-1_intro-object-storage.md)_, que permite somente usuários _autenticados_ a realizar _[upload](https://en.wikipedia.org/wiki/Upload)_ das _imagens_ de sua escolha. Estas por sua vez, são persistidas no _[Object Storage](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-6/6-1_intro-object-storage.md)_.

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
    "created-by": "ocid1.user.oc1..aaaaaaaauf3dvc2aou6z5wmrm225a5rwkmp2ncoaj3726gpzlqdwjgby5zya",
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

### __NoSQL__

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


