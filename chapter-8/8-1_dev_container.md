# Capítulo 8: A aplicação FotoGal

## 8.1 - Desenvolvimento Conteinerizado

### __Visão Geral__

Antes de começar vamos entender o que é _"desenvolvimento conteinerizado"_. 

_Conteinerização_ é um termo usado no qual se refere a ação de _"empacotar o código de um software"_ junto com suas bibliotecas, arquivos de configuração e demais dependências, gerando assim uma _[imagem](https://docs.docker.com/language/python/build-images/)_ que pode ser implantada e executada _(deploy)_ em qualquer infraestrutura que suporte a execução de contêineres _("written once and run anywhere")_. 

_Contêineres_, por serem portáveis e mais eficientes do que _máquinas virtuais (VMs)_, sobre a perspectiva de utilização de recursos, tornaram-se o padrão para desenvolvimento de aplicações modernas e _"nativos da nuvem"_ _[(Cloud Native)](https://en.wikipedia.org/wiki/Cloud_native_computing)_.

Métodos de desenvolvimentos antigos, onde o código era desenvolvido em um ambiente específico e quando era transferido para _"rodar"_ em produção por exemplo, sempre ocasionavam erros, bugs e exigiam diferentes adequações. Uma das grandes vantagens no _"desenvolvimento conteinerizado"_ está na sua _portabilidade_. O contêiner que é usado para desenvolver, é o mesmo usado na produção. O mesmo pacote _auto-contido_ ou _[imagem](https://docs.docker.com/language/python/build-images/)_, pode ser executado em diferentes infraestruturas. Eu posso desenvolver localmente na minha máquina desktop, move e executar no _[OCI](https://www.oracle.com/br/cloud/)_, por exemplo.

>_**__NOTA:__** Para saber mais sobre [Docker](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-2/2-6_docker-howto.md) e seus detalhes, consulte o capítulo [2.6 - Docker HOWTO](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-2/2-6_docker-howto.md)._

Irei apresentar como é desenvolver uma aplicação em _contêiner_ e como realizar o _deploy_ no _[Serviço Container Engine for Kubernetes](https://docs.oracle.com/pt-br/iaas/Content/ContEng/Concepts/contengoverview.htm)_ do _[OCI](https://www.oracle.com/br/cloud/)_. O intuíto não é falar da linguagem de programação _[Python](https://www.python.org/)_ ou do framework _[Flask](https://flask.palletsprojects.com)_, e sim mostrar é feito o desenvolvimento de uma aplicação que usa os serviços do _[OCI](https://www.oracle.com/br/cloud/)_.

Os serviços que a aplicação _FotoGal_ utiliza hoje do _[OCI](https://www.oracle.com/br/cloud/)_ são:

- [Object Storage](https://docs.oracle.com/pt-br/iaas/Content/Object/Concepts/objectstorageoverview.htm)
- [Banco de Dados NoSQL](https://docs.oracle.com/pt-br/iaas/nosql-database/index.html)
- [Log](https://docs.oracle.com/pt-br/iaas/Content/Logging/Concepts/loggingoverview.htm)
- [Container Engine for Kubernetes](https://docs.oracle.com/pt-br/iaas/Content/ContEng/Concepts/contengoverview.htm)
- [Load Balancing](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)



```
darmbrust@sladar:~$ git clone https://github.com/daniel-armbrust/fotogal.git
darmbrust@sladar:~$ cd fotogal
darmbrust@sladar:~/fotogal$
```

```
darmbrust@sladar:~/fotogal/terraform$ terraform init
Initializing modules...
- gru_dhcp_vcn-prd in modules/networking/dhcp_options
- gru_igw_vcn-prd in modules/networking/internet_gateway
- gru_ngw_vcn-prd in modules/networking/nat_gateway
- gru_nosql-index_fotogal_authsession_userid in modules/nosql/index
- gru_nosql-index_fotogal_images_createdts in modules/nosql/index
- gru_nosql-index_fotogal_images_userid in modules/nosql/index
- gru_nosql-table_fotogal_authsession in modules/nosql/table
- gru_nosql-table_fotogal_images in modules/nosql/table
- gru_nosql-table_fotogal_users in modules/nosql/table
- gru_objectstorage_bucket in modules/objectstorage
- gru_rtb_subprv-backend_vcn-prd in modules/networking/route_table
- gru_rtb_subpub-frontend_vcn-prd in modules/networking/route_table
- gru_secl_subprv-backend_vcn-prd in modules/networking/security_list
- gru_secl_subpub-frontend_vcn-prd in modules/networking/security_list
- gru_sgw_vcn-prd in modules/networking/service_gateway
- gru_subprv-backend_vcn-prd in modules/networking/subnet
- gru_subpub-frontend_vcn-prd in modules/networking/subnet
- gru_vcn-prd in modules/networking/vcn

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/oci...
- Installing hashicorp/oci v4.49.0...
- Installed hashicorp/oci v4.49.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

╷
│ Warning: Experimental feature "module_variable_optional_attrs" is active
│
│   on modules/networking/security_list/main.tf line 7, in terraform:
│    7:   experiments = [module_variable_optional_attrs]
│
│ Experimental features are subject to breaking changes in future minor or patch releases, based on feedback.
│
│ If you have feedback on the design of this feature, please open a GitHub issue to discuss it.
│
│ (and one more similar warning elsewhere)
╵

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
darmbrust@sladar:~/fotogal/terraform$
```