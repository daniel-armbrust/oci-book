# Capítulo 2: Automação, Arquitetura e DevOps

## 2.5 - Usando o Terraform para criar sua Infraestrutura no OCI

### __Visão Geral__
_[Terraform](https://www.terraform.io/)_ é uma ferramenta que permite definir, provisionar e gerenciar sua infraestrutura através de código (criar, atualizar e destruir). O conceito por trás do termo _"infraestrutura como código"_ é simples: você define recursos cloud (vm, banco de dados, redes, etc) em um ou mais arquivos de configuração (infraestrutura em código). O código utiliza uma _"abordagem declarativa"_. Isto significa que é possível definir qual é o _“estado esperado”_ da sua infraestrutura, através de instruções simples e diretas.

Codificar em _[Terraform](https://www.terraform.io/)_, significa codificar em uma linguagem especifica chamada _HashiCorp Configuration Language (HCL)_. Esta foi criada pela _HashiCorp_ com o intuito de substituir configurações antes escritas em formato _[JSON](https://pt.wikipedia.org/wiki/JSON)_ ou _[XML](https://pt.wikipedia.org/wiki/XML)_. 

Quando falamos sobre a ação de provisionar infraestrutura, estamos nos referindo à criação ou implantação (deploy) dos componentes que formam uma infraestrutura. Isto é diferente do _“gerenciamento de configuração”_, feito por ferramentas como _[Ansible](https://docs.ansible.com/ansible/latest/index.html)_, por exemplo.

Ferramentas que atuam no _“gerenciamento de configuração”_, fazem deploy de software dentro de servidores existentes. Tais ferramentas são a favor do chamado _"infraestrutura mutável"_. Já ferramentas como o  _[Terraform](https://www.terraform.io/)_, são a favor da _"infraestrutura imutável"_.

>_**__NOTA:__** Tecnicamente tudo que pode ser controlado por uma API pode ser controlado e gerenciado pelo Terraform a partir de plugins específicos. A ferramenta não está limitada somente a operar em cloud computing._

Depois que você conhecer o _[Terraform](https://www.terraform.io/)_, nunca mais vai querer dar _cliques_ na _[Web Console](https://docs.oracle.com/pt-br/iaas/Content/GSG/Concepts/console.htm)_. O _[Terraform](https://www.terraform.io/)_ facilita e agiliza todo o _"lifecyle"_ da sua infraestrutura. Além disto, o código que provisiona sempre está atualizado, diferente da velha documentação, que sempre está desatualizada.

A ferramenta _[Terraform](https://www.terraform.io/)_ é independente de qualquer provedor Cloud. Ela se integra as APIs de um provedor em especifico através dos chamados _[providers](https://www.terraform.io/docs/language/providers/index.html)_. Estes nada mais são do que _plugins_ que capacitam o _[Terraform](https://www.terraform.io/)_ na comunicação com um sistema remoto em particular. Cada provedor, é responsável por manter seu código _(plugins)_ atualizado no _[Terraform Registry](https://registry.terraform.io/)_.

>_**__NOTA:__** A integração da ferramenta em um provedor depende da existência/escrita de um _pluging provider_. Atualmente, todos os grandes provedores de cloud pública já possuem _plugins_ prontos para uso. Estes podem ser verificados _[aqui](https://registry.terraform.io/browse/providers)_._

<br>

![alt_text](./images/ch2_2-5_1.jpg  "Terraform OCI Provider")

### __Instalação do Terraform__

Escrito na linguagem de programação _[Go](https://pt.wikipedia.org/wiki/Go_(linguagem_de_programa%C3%A7%C3%A3o))_, o _[Terraform](https://www.terraform.io/)_ é composto de apenas um binário executável. Ou seja, sua instalação é muito simples:

1. Baixe neste _[site](https://www.terraform.io/downloads.html)_ o binário do _[Terraform](https://www.terraform.io/)_ de acordo com o seu sistema operacional e arquitetura do seu processador.
2. Descompacte e mova o binário para algum lugar em que sua variável de ambiente _[PATH](https://en.wikipedia.org/wiki/PATH_(variable))_ faça referência.
3. Pronto!

No meu caso, estou usando um sistema operacional _[Linux](https://pt.wikipedia.org/wiki/Linux)_ em processador _[ARM 32-bits](https://pt.wikipedia.org/wiki/Arquitetura_ARM)_.

```linux
darmbrust@hoodwink:~/oci-tf$ sudo su -
[sudo] password for darmbrust:

root@hoodwink:~# cd /usr/src

root@hoodwink:/usr/src# wget https://releases.hashicorp.com/terraform/1.0.4/terraform_1.0.4_linux_arm.zip

root@hoodwink:/usr/src# unzip terraform_1.0.4_linux_arm.zip
Archive:  terraform_1.0.4_linux_arm.zip
  inflating: terraform

root@hoodwink:/usr/src# chown root:root terraform
root@hoodwink:/usr/src# chmod 0555 terraform

root@hoodwink:/usr/src# mv terraform /usr/local/bin/

root@hoodwink:/usr/src# terraform -v
Terraform v1.0.4
on linux_arm
```

### __Terraform e OCI__

O _[Terraform](https://www.terraform.io/)_ lê todos os arquivos com a extensão __.tf__ do diretório corrente (onde você está) e os concatena. O nome do arquivo não importa! Todos __*.tf__ serão concatenados! Você é livre para definir um nome de arquivo __variables.tf__ ou __vars.tf__, por exemplo.

Abaixo, apresento nosso projeto de exemplo para nos guiar neste entendimento:

```
darmbrust@hoodwink:~/oci-tf$ ls -1F
datasources.tf
keys/
main.tf
modules/
outputs.tf
providers.tf
terraform.tfvars
vars.tf
```

Para que o _[Terraform](https://www.terraform.io/)_ possa criar e gerenciar nossa infraestrutura no _[OCI](https://www.oracle.com/cloud/)_, devemos primeiramente parametrizar-lo com alguns valores.  

Toda comunicação com o _[OCI](https://www.oracle.com/cloud/)_ necessita de um _[usuário](https://docs.oracle.com/pt-br/iaas/Content/GSG/Tasks/addingusers.htm)_, _[credenciais](https://docs.oracle.com/pt-br/iaas/Content/Identity/Concepts/usercredentials.htm)_ válidas para _autenticação_, e _[políticas](https://docs.oracle.com/pt-br/iaas/Content/Identity/Concepts/policies.htm)_ que _autorizem_ a criação de recursos em uma _[região](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm)_ e _[tenancy](https://docs.oracle.com/pt-br/iaas/Content/GSG/Concepts/settinguptenancy.htm)_ específicos. O _[Terraform](https://www.terraform.io/)_ necessita que essas informações sejam especificadas de alguma forma via variáveis de ambiente, linha de comando ou em arquivo.

Particularmente, eu gosto de especificar esses valores utilizando o arquivo _"terraform.tfvars"_ que possui um significado especial. Ele será processado pelo _[Terraform](https://www.terraform.io/)_ toda vez que você precisar se comunicar com o _[OCI](https://www.oracle.com/cloud/)_.

O próprio _[OCI](https://www.oracle.com/cloud/)_ já facilita a criação das chaves de acesso e demais valores para preenchermos o arquivo _"terraform.tfvars"_:

<br>

![alt_text](./images/ch2_2-5_2.jpg  "OCI - Configuration File Preview")

<br>

Transportando os valores para o arquivo, nós temos:

```terraform
darmbrust@hoodwink:~/oci-tf$ cat terraform.tfvars
#
# terraform.tfvars
#

api_private_key_path = "./keys/oci.key"
api_fingerprint = "a6:73:ee:05:7e:56:47:ab:60:d3:76:f4:01:01:de:55"
user_id = "ocid1.user.oc1..aaaaaaaay3rey4zdxzyj1oz3rey267ovskbi72vix3reytptcyehqmqbsr76q"
tenancy_id = "ocid1.tenancy.oc1..aaaaaaaaz4oeus54ktfstpwc4z3muju5xec7nppp33rt4r4x2v1xydt4pf5qrrq"
compartment_id = "ocid1.compartment.oc1..aaaaaaaaro7baesc4z3untyqxajzotsthm4baa6bwumacmb1xydw6gvb2mq"
```

>_**__NOTA:__** Não versione o arquivo _"terraform.tfvars"_ nem o diretório _"keys/"_. Eles contém informações sensíveis para o acesso._

### __Variáveis de Input (entrada de dados)__

_[Variáveis de Input](https://www.terraform.io/docs/language/values/variables.html)_ ou para entrada de dados, é o meio pelo qual parametrizamos ou informamos ao código _[Terraform](https://www.terraform.io/)_, sobre um determinado valor. Em nosso exemplo, iremos informar ao _[Terraform](https://www.terraform.io/)_, através do conjunto _"nome variável = valor"_ contidos no arquivo _"terraform.tfvars"_, informações de autenticação necessárias para a construção da infraestrutura no _[OCI](https://www.oracle.com/cloud/)_.

<br>

```terraform
darmbrust@hoodwink:~/oci-tf$ cat vars.tf
#
# vars.tf
#

variable "api_private_key_path" {
  description = "The path to oci api private key."
  type = string
}

variable "api_fingerprint" {
  description = "Fingerprint of oci api private key."
  type = string
}

variable "user_id" {
  description = "The id of the user that terraform will use to create the resources."
  type = string
}

variable "tenancy_id" {
  description = "The tenancy id in which to create the resources."
  type = string
}

variable "compartment_id" {
  description = "The compartment id where to create all resources."
  type = string
}
```

<br>

Lembre-se: toda vez que eu desejar que o _[Terraform](https://www.terraform.io/)_ saiba de algo, eu devo utilizar uma _[Variáveis de Input](https://www.terraform.io/docs/language/values/variables.html)_.